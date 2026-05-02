// =============================================================================
// kg-test/main.go
//
// Unpack — Domain-Specific Knowledge Graph (DSKG)
// Complete Go implementation. Neuro-Symbolic anchor for the multi-agent system.
//
// ACADEMIC FRAMING (Hogan et al. 2021, ACM Computing Surveys 54(4)):
//   This is a two-layer Knowledge Graph implemented on Neo4j (Labeled Property Graph).
//
//   T-Box (Terminology Box) — the formal ontology, loaded first:
//     :Class      — entity type declarations  (Concept, Formula, L2Label, …)
//     :Relation   — edge type declarations    (REQUIRES, HAS_FORMULA, …)
//     :Property   — typed property metadata   (id, core_theory, latex, …)
//     :Curriculum — academic scope context
//
//   A-Box (Assertion Box) — the instances, loaded second:
//     :Concept       — 39 mathematics concepts
//     :Formula       — 58 LaTeX formula nodes
//     :L2Label       — 156 multilingual label nodes (si/ta/ar/zh)
//     :VideoResource — 52 YouTube resource nodes
//     :UseCase       — 45 real-world application nodes
//     REQUIRES       — 63 prerequisite edges (transitive, weighted)
//     RELATED_TO     — 16 conceptual sibling edges (symmetric)
//
// EXECUTION ORDER:
//   1. createSchema()   — constraints + fulltext indexes (idempotent)
//   2. loadOntology()   — T-Box (Class, Relation, Property, Curriculum)
//   3. loadConcepts()   — A-Box: 39 :Concept nodes
//   4. loadFormulas()   — :Formula nodes + HAS_FORMULA edges
//   5. loadL2Labels()   — :L2Label nodes + HAS_LABEL edges
//   6. loadVideos()     — :VideoResource nodes + HAS_RESOURCE edges
//   7. loadUseCases()   — :UseCase nodes + APPLIED_IN edges
//   8. loadEdges()      — REQUIRES + RELATED_TO edges between concepts
//   9. linkCurriculum() — COVERS edges from :Curriculum to all :Concept
//  10. runVerification() (--verify flag)
//
// USAGE:
//   export NEO4J_URI="bolt://localhost:7687"
//   export NEO4J_USER="neo4j"
//   export NEO4J_PASSWORD="yourpassword"
//   go mod tidy
//   go run main.go                 # load everything
//   go run main.go --verify        # load + run 11 verification tests
//   go run main.go --clear --verify # wipe, reload, verify
// =============================================================================

package main

import (
	"bufio"
	"context"
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/neo4j/neo4j-go-driver/v5/neo4j"
)

// =============================================================================
// DATA STRUCTS — typed to match each CSV column schema exactly
// =============================================================================

type ConceptNode struct {
	ID, Name, Description, CoreTheory, Type, Color string
	CurriculumLayer                                int
}

type FormulaNode struct {
	ConceptID, FormulaID, FormulaName, Latex, NotationPlain string
	DisplayLevel                                            int
	IsPrimary                                               bool
}

type L2LabelNode struct {
	ConceptID, LabelID, LanguageCode, Label, DescriptionL2, CurriculumName, TextDirection string
}

type VideoNode struct {
	ConceptID, VideoID, Platform, Title, URL, Language, Difficulty, Channel string
	DurationSec                                                             int
}

type UseCaseNode struct {
	ConceptID, UseCaseID, Domain, Description, ProblemExample string
}

type Edge struct {
	SourceID, TargetID, RelationshipType string
	Weight                               float64
}

// =============================================================================
// MAIN
// =============================================================================

func main() {
	dataDir := flag.String("data", "./data/raw", "Directory containing CSV files")
	verify := flag.Bool("verify", false, "Run verification queries after loading")
	clear := flag.Bool("clear", false, "Clear all data before loading")
	skipTBox := flag.Bool("skip-tbox", false, "Skip T-Box load (re-run A-Box only)")
	flag.Parse()

	ctx := context.Background()

	driver, err := newDriver()
	if err != nil {
		log.Fatalf(
			"\n✗ Neo4j connection failed: %v\n\n"+
				"  Set these environment variables:\n"+
				"    export NEO4J_URI=\"bolt://localhost:7687\"\n"+
				"    export NEO4J_USER=\"neo4j\"\n"+
				"    export NEO4J_PASSWORD=\"yourpassword\"\n\n"+
				"  Or start Neo4j with Docker:\n"+
				"    docker run -p 7474:7474 -p 7687:7687 \\\n"+
				"      -e NEO4J_AUTH=neo4j/yourpassword neo4j:5.20.0-community\n", err)
	}
	defer driver.Close(ctx)
	fmt.Printf("✓ Connected to Neo4j at %s\n\n", getEnv("NEO4J_URI", "bolt://localhost:7687"))

	if *clear {
		mustOK(clearAll(ctx, driver), "clearAll")
	}

	start := time.Now()

	// ── T-Box ─────────────────────────────────────────────────────────────────
	fmt.Println("Step 1/9  Schema — constraints + indexes")
	mustOK(createSchema(ctx, driver), "createSchema")

	if !*skipTBox {
		fmt.Println("Step 2/9  Ontology — T-Box (Class, Relation, Property, Curriculum)")
		mustOK(loadOntology(ctx, driver), "loadOntology")
	} else {
		fmt.Println("Step 2/9  Ontology — skipped (--skip-tbox)")
	}

	// ── A-Box ─────────────────────────────────────────────────────────────────
	fmt.Println("Step 3/9  Concepts — 39 :Concept nodes")
	concepts := mustParse(parseConceptsCSV(*dataDir + "/concepts.csv"))
	mustOK(loadConcepts(ctx, driver, concepts), "loadConcepts")

	fmt.Println("Step 4/9  Formulas — :Formula + HAS_FORMULA")
	formulas := mustParse(parseFormulasCSV(*dataDir + "/formulas.csv"))
	mustOK(loadFormulas(ctx, driver, formulas), "loadFormulas")

	fmt.Println("Step 5/9  L2 Labels — :L2Label + HAS_LABEL")
	labels := mustParse(parseL2LabelsCSV(*dataDir + "/l2_labels.csv"))
	mustOK(loadL2Labels(ctx, driver, labels), "loadL2Labels")

	fmt.Println("Step 6/9  Videos — :VideoResource + HAS_RESOURCE")
	videos := mustParse(parseVideosCSV(*dataDir + "/videos.csv"))
	mustOK(loadVideos(ctx, driver, videos), "loadVideos")

	fmt.Println("Step 7/9  Use Cases — :UseCase + APPLIED_IN")
	useCases := mustParse(parseUseCasesCSV(*dataDir + "/use_cases.csv"))
	mustOK(loadUseCases(ctx, driver, useCases), "loadUseCases")

	fmt.Println("Step 8/9  Edges — REQUIRES + RELATED_TO")
	edges := mustParse(parseEdgesCSV(*dataDir + "/edges.csv"))
	mustOK(loadEdges(ctx, driver, edges), "loadEdges")

	fmt.Println("Step 9/9  Curriculum — COVERS edges to all :Concept")
	mustOK(linkCurriculum(ctx, driver), "linkCurriculum")

	printSummary(ctx, driver, time.Since(start),
		len(concepts), len(formulas), len(labels),
		len(videos), len(useCases), len(edges))

	if *verify {
		runVerification(ctx, driver)
	}
}

// =============================================================================
// STEP 1 — SCHEMA: constraints, property indexes, fulltext indexes
// =============================================================================

func createSchema(ctx context.Context, driver neo4j.DriverWithContext) error {
	stmts := []string{
		// Uniqueness constraints
		`CREATE CONSTRAINT concept_id_unique  IF NOT EXISTS FOR (c:Concept)      REQUIRE c.id IS UNIQUE`,
		`CREATE CONSTRAINT formula_id_unique  IF NOT EXISTS FOR (f:Formula)       REQUIRE f.id IS UNIQUE`,
		`CREATE CONSTRAINT l2label_id_unique  IF NOT EXISTS FOR (l:L2Label)       REQUIRE l.id IS UNIQUE`,
		`CREATE CONSTRAINT video_id_unique    IF NOT EXISTS FOR (v:VideoResource) REQUIRE v.id IS UNIQUE`,
		`CREATE CONSTRAINT usecase_id_unique  IF NOT EXISTS FOR (u:UseCase)       REQUIRE u.id IS UNIQUE`,
		`CREATE CONSTRAINT class_name_unique  IF NOT EXISTS FOR (c:Class)         REQUIRE c.name IS UNIQUE`,
		`CREATE CONSTRAINT relation_name_uniq IF NOT EXISTS FOR (r:Relation)      REQUIRE r.name IS UNIQUE`,
		`CREATE CONSTRAINT property_name_uniq IF NOT EXISTS FOR (p:Property)      REQUIRE p.name IS UNIQUE`,
		`CREATE CONSTRAINT curriculum_id_uniq IF NOT EXISTS FOR (c:Curriculum)    REQUIRE c.id IS UNIQUE`,
		// Property indexes — one per agent filter field
		`CREATE INDEX concept_type    IF NOT EXISTS FOR (c:Concept)      ON (c.type)`,
		`CREATE INDEX concept_layer   IF NOT EXISTS FOR (c:Concept)      ON (c.curriculum_layer)`,
		`CREATE INDEX l2label_lang    IF NOT EXISTS FOR (l:L2Label)      ON (l.language_code)`,
		`CREATE INDEX video_lang      IF NOT EXISTS FOR (v:VideoResource) ON (v.language)`,
		`CREATE INDEX video_diff      IF NOT EXISTS FOR (v:VideoResource) ON (v.difficulty)`,
		`CREATE INDEX formula_primary IF NOT EXISTS FOR (f:Formula)      ON (f.is_primary)`,
		`CREATE INDEX formula_level   IF NOT EXISTS FOR (f:Formula)      ON (f.display_level)`,
		`CREATE INDEX usecase_domain  IF NOT EXISTS FOR (u:UseCase)      ON (u.domain)`,
		// Fulltext indexes: Agent 1 token lookup + Agent 3 near-match + L2 search
		`CREATE FULLTEXT INDEX concept_search IF NOT EXISTS FOR (c:Concept) ON EACH [c.name, c.description, c.core_theory]`,
		`CREATE FULLTEXT INDEX l2label_search IF NOT EXISTS FOR (l:L2Label) ON EACH [l.label, l.description_l2, l.curriculum_name]`,
		`CREATE FULLTEXT INDEX usecase_search IF NOT EXISTS FOR (u:UseCase) ON EACH [u.description, u.problem_example, u.domain]`,
	}
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	for _, stmt := range stmts {
		if _, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
			_, err := tx.Run(ctx, stmt, nil)
			return nil, err
		}); err != nil {
			return fmt.Errorf("schema [%.55s…]: %w", stmt, err)
		}
	}
	fmt.Printf("   ✓ 9 constraints + 8 indexes + 3 fulltext indexes\n")
	return nil
}

// =============================================================================
// STEP 2 — T-BOX: formal ontology layer
// =============================================================================

func loadOntology(ctx context.Context, driver neo4j.DriverWithContext) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)

	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {

		// Class nodes — entity type declarations
		for _, props := range []map[string]any{
			{"name": "Concept", "description": "A mathematical concept at undergraduate level.", "scope": "undergraduate mathematics", "valid_types": []string{"Foundation", "Calculus", "Geometry", "Rate of Change", "Goal", "Equation Type"}},
			{"name": "Formula", "description": "A formula node. Separate so UI agent fetches only formula on hover without loading full theory.", "scope": "mathematical notation"},
			{"name": "L2Label", "description": "A canonical multilingual label. Separate so multilingual agent queries by language_code without scanning all concept properties.", "scope": "multilingual localisation"},
			{"name": "VideoResource", "description": "An educational YouTube video. Separate so Agent 5 filters by language and difficulty independently of concept data.", "scope": "educational media"},
			{"name": "UseCase", "description": "A real-world application. Answers: why am I learning this? Shown in hover state 3.", "scope": "contextual scaffolding"},
			{"name": "ProblemType", "description": "A category of mathematics word problem (e.g. Related Rates). Links to Concept via EXEMPLIFIES and INVOLVES.", "scope": "problem classification"},
			{"name": "Curriculum", "description": "Academic curriculum providing scope context for the graph.", "scope": "academic scope"},
		} {
			if _, err := tx.Run(ctx, `MERGE (n:Class {name: $p.name}) SET n = $p`, map[string]any{"p": props}); err != nil {
				return nil, fmt.Errorf("Class %s: %w", props["name"], err)
			}
		}

		// Relation nodes — edge type declarations with formal semantics
		for _, props := range []map[string]any{
			{"name": "REQUIRES", "domain": "Concept", "range": "Concept", "definition": "Student cannot engage with target without mastering source. Asymmetric, transitive, weighted.", "is_transitive": true, "is_symmetric": false, "weight_meaning": "1.0=hard prerequisite, 0.8=recommended, 0.7=helpful"},
			{"name": "RELATED_TO", "domain": "Concept", "range": "Concept", "definition": "Two concepts co-occur in same problem or share mathematical structure. Neither is prerequisite.", "is_transitive": false, "is_symmetric": true, "weight_meaning": "1.0=definitionally linked, 0.8=frequently combined"},
			{"name": "HAS_FORMULA", "domain": "Concept", "range": "Formula", "definition": "Concept has a formula. Primary formula shown at hover state 1 (low CL).", "is_transitive": false, "is_symmetric": false},
			{"name": "HAS_LABEL", "domain": "Concept", "range": "L2Label", "definition": "Concept has canonical name in a specific language. Multilingual Agent B1 queries by language_code for textbook-canonical term.", "is_transitive": false, "is_symmetric": false},
			{"name": "HAS_RESOURCE", "domain": "Concept", "range": "VideoResource", "definition": "Concept has an educational video. Agent 5 attaches videos. UI queries by language for L1 content.", "is_transitive": false, "is_symmetric": false},
			{"name": "APPLIED_IN", "domain": "Concept", "range": "UseCase", "definition": "Concept applied in a real-world use case. Shown in hover state 3 (high support).", "is_transitive": false, "is_symmetric": false},
			{"name": "EXEMPLIFIES", "domain": "ProblemType", "range": "Concept", "definition": "Word problem of this type tests this Concept as the primary operation.", "is_transitive": false, "is_symmetric": false},
			{"name": "INVOLVES", "domain": "ProblemType", "range": "Concept", "definition": "Word problem of this type uses this Concept as a supporting operation.", "is_transitive": false, "is_symmetric": false},
			{"name": "COVERS", "domain": "Curriculum", "range": "Concept", "definition": "This Curriculum includes this Concept. Enables scope-bounded KG queries.", "is_transitive": false, "is_symmetric": false},
		} {
			if _, err := tx.Run(ctx, `MERGE (n:Relation {name: $p.name}) SET n = $p`, map[string]any{"p": props}); err != nil {
				return nil, fmt.Errorf("Relation %s: %w", props["name"], err)
			}
		}

		// Property nodes — typed property documentation
		for _, props := range []map[string]any{
			{"name": "id", "applies_to": "Concept", "datatype": "String", "definition": "Unique stable slug. Used as graph_node_id in Unpack UI JSON."},
			{"name": "core_theory", "applies_to": "Concept", "datatype": "String", "definition": "Strict mathematical definition shown at hover state 2 (medium CL)."},
			{"name": "type", "applies_to": "Concept", "datatype": "String", "definition": "Pedagogical category controlling UI token colour.", "valid_values": []string{"Foundation", "Calculus", "Geometry", "Rate of Change", "Goal", "Equation Type"}},
			{"name": "color", "applies_to": "Concept", "datatype": "String", "definition": "Hex colour for UI token underline and tooltip badge."},
			{"name": "curriculum_layer", "applies_to": "Concept", "datatype": "Integer", "definition": "0=pre-calc, 1=differentiation, 2=integration, 3=series, 4=multivariable."},
			{"name": "latex", "applies_to": "Formula", "datatype": "String", "definition": "Raw LaTeX rendered by KaTeX or MathJax in the progressive disclosure UI."},
			{"name": "notation_plain", "applies_to": "Formula", "datatype": "String", "definition": "ASCII plain-text formula shown when LaTeX rendering unavailable."},
			{"name": "display_level", "applies_to": "Formula", "datatype": "Integer", "definition": "1=hover (low CL), 2=click (medium CL)."},
			{"name": "language_code", "applies_to": "L2Label", "datatype": "String", "definition": "ISO 639-1 code. Multilingual Agent B1 queries on this field."},
			{"name": "text_direction", "applies_to": "L2Label", "datatype": "String", "definition": "ltr or rtl. UI sets CSS direction from this. Critical for Arabic."},
			{"name": "curriculum_name", "applies_to": "L2Label", "datatype": "String", "definition": "Textbook-canonical term in student language. Not a translation — a proper curriculum name."},
			{"name": "url", "applies_to": "VideoResource", "datatype": "String", "definition": "Direct YouTube video URL."},
			{"name": "rank_score", "applies_to": "VideoResource", "datatype": "Float", "definition": "Agent 5 semantic rank: channel authority × transcript similarity × duration filter."},
		} {
			if _, err := tx.Run(ctx, `MERGE (n:Property {name: $p.name}) SET n = $p`, map[string]any{"p": props}); err != nil {
				return nil, fmt.Errorf("Property %s: %w", props["name"], err)
			}
		}

		// Curriculum node — scope declaration
		_, err := tx.Run(ctx, `
			MERGE (cur:Curriculum {id: "undergrad_calculus"})
			SET cur.name          = "Undergraduate Calculus",
			    cur.scope         = "First and second year university mathematics",
			    cur.covers_layers = [0, 1, 2, 3, 4],
			    cur.study_context = "Unpack RQ3 — non-native English speaking STEM students",
			    cur.citation      = "Hogan et al. (2021). Knowledge Graphs. ACM Computing Surveys 54(4)."
		`, nil)
		return nil, err
	})

	if err != nil {
		return fmt.Errorf("loadOntology: %w", err)
	}
	fmt.Printf("   ✓ 7 Class + 9 Relation + 13 Property + 1 Curriculum\n")
	return nil
}

// =============================================================================
// STEP 9 — LINK CURRICULUM
// =============================================================================

func linkCurriculum(ctx context.Context, driver neo4j.DriverWithContext) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	result, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		res, err := tx.Run(ctx, `
			MATCH (cur:Curriculum {id:"undergrad_calculus"}), (c:Concept)
			MERGE (cur)-[:COVERS {layer: c.curriculum_layer}]->(c)
			RETURN COUNT(*) AS n`, nil)
		if err != nil {
			return nil, err
		}
		if res.Next(ctx) {
			n, _ := res.Record().Get("n")
			return n, nil
		}
		return int64(0), nil
	})
	if err != nil {
		return fmt.Errorf("linkCurriculum: %w", err)
	}
	fmt.Printf("   ✓ %v COVERS edges\n", result)
	return nil
}

// =============================================================================
// A-BOX LOADERS — Steps 3–8, all batched in single transactions
// =============================================================================

func loadConcepts(ctx context.Context, driver neo4j.DriverWithContext, nodes []ConceptNode) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, n := range nodes {
			if _, err := tx.Run(ctx, `
				MERGE (c:Concept {id:$id})
				SET c.name=$name, c.description=$desc, c.core_theory=$theory,
				    c.type=$type, c.color=$color, c.curriculum_layer=$layer,
				    c.updated_at=datetime()`,
				map[string]any{"id": n.ID, "name": n.Name, "desc": n.Description,
					"theory": n.CoreTheory, "type": n.Type, "color": n.Color, "layer": n.CurriculumLayer},
			); err != nil {
				return nil, fmt.Errorf("concept %s: %w", n.ID, err)
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Printf("   ✓ %d Concept nodes\n", len(nodes))
	return nil
}

func loadFormulas(ctx context.Context, driver neo4j.DriverWithContext, nodes []FormulaNode) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	var missing int
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, n := range nodes {
			res, err := tx.Run(ctx, `
				MATCH (c:Concept {id:$cid})
				MERGE (f:Formula {id:$id})
				SET f.name=$name, f.latex=$latex, f.notation_plain=$plain,
				    f.display_level=$level, f.is_primary=$primary
				MERGE (c)-[:HAS_FORMULA {primary:$primary}]->(f)`,
				map[string]any{"cid": n.ConceptID, "id": n.FormulaID, "name": n.FormulaName,
					"latex": n.Latex, "plain": n.NotationPlain, "level": n.DisplayLevel, "primary": n.IsPrimary},
			)
			if err != nil {
				return nil, fmt.Errorf("formula %s: %w", n.FormulaID, err)
			}
			s, _ := res.Consume(ctx)
			if s.Counters().NodesCreated() == 0 && s.Counters().RelationshipsCreated() == 0 && s.Counters().PropertiesSet() == 0 {
				missing++
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	if missing > 0 {
		fmt.Printf("   ⚠ %d formulas skipped (concept not found)\n", missing)
	}
	fmt.Printf("   ✓ %d Formula nodes + HAS_FORMULA edges\n", len(nodes)-missing)
	return nil
}

func loadL2Labels(ctx context.Context, driver neo4j.DriverWithContext, nodes []L2LabelNode) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, n := range nodes {
			if _, err := tx.Run(ctx, `
				MATCH (c:Concept {id:$cid})
				MERGE (l:L2Label {id:$id})
				SET l.language_code=$lang, l.label=$label, l.description_l2=$desc,
				    l.curriculum_name=$curriculum, l.text_direction=$dir
				MERGE (c)-[:HAS_LABEL]->(l)`,
				map[string]any{"cid": n.ConceptID, "id": n.LabelID, "lang": n.LanguageCode,
					"label": n.Label, "desc": n.DescriptionL2, "curriculum": n.CurriculumName, "dir": n.TextDirection},
			); err != nil {
				return nil, fmt.Errorf("l2label %s: %w", n.LabelID, err)
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Printf("   ✓ %d L2Label nodes + HAS_LABEL edges\n", len(nodes))
	return nil
}

func loadVideos(ctx context.Context, driver neo4j.DriverWithContext, nodes []VideoNode) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, n := range nodes {
			if _, err := tx.Run(ctx, `
				MATCH (c:Concept {id:$cid})
				MERGE (v:VideoResource {id:$id})
				SET v.platform=$platform, v.title=$title, v.url=$url,
				    v.language=$lang, v.duration_sec=$dur, v.difficulty=$diff, v.channel=$ch
				MERGE (c)-[:HAS_RESOURCE]->(v)`,
				map[string]any{"cid": n.ConceptID, "id": n.VideoID, "platform": n.Platform,
					"title": n.Title, "url": n.URL, "lang": n.Language,
					"dur": n.DurationSec, "diff": n.Difficulty, "ch": n.Channel},
			); err != nil {
				return nil, fmt.Errorf("video %s: %w", n.VideoID, err)
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Printf("   ✓ %d VideoResource nodes + HAS_RESOURCE edges\n", len(nodes))
	return nil
}

func loadUseCases(ctx context.Context, driver neo4j.DriverWithContext, nodes []UseCaseNode) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, n := range nodes {
			if _, err := tx.Run(ctx, `
				MATCH (c:Concept {id:$cid})
				MERGE (u:UseCase {id:$id})
				SET u.domain=$domain, u.description=$desc, u.problem_example=$example
				MERGE (c)-[:APPLIED_IN]->(u)`,
				map[string]any{"cid": n.ConceptID, "id": n.UseCaseID,
					"domain": n.Domain, "desc": n.Description, "example": n.ProblemExample},
			); err != nil {
				return nil, fmt.Errorf("usecase %s: %w", n.UseCaseID, err)
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Printf("   ✓ %d UseCase nodes + APPLIED_IN edges\n", len(nodes))
	return nil
}

func loadEdges(ctx context.Context, driver neo4j.DriverWithContext, edges []Edge) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	req, rel, missing := 0, 0, 0
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		for _, e := range edges {
			var q string
			switch e.RelationshipType {
			case "REQUIRES":
				q = `MATCH (s:Concept{id:$sid}),(t:Concept{id:$tid}) MERGE (s)-[r:REQUIRES]->(t) SET r.weight=$w, r.updated_at=datetime()`
			case "RELATED_TO":
				q = `MATCH (s:Concept{id:$sid}),(t:Concept{id:$tid}) MERGE (s)-[r:RELATED_TO]->(t) SET r.weight=$w, r.updated_at=datetime()`
			default:
				continue
			}
			res, err := tx.Run(ctx, q, map[string]any{"sid": e.SourceID, "tid": e.TargetID, "w": e.Weight})
			if err != nil {
				return nil, fmt.Errorf("edge %s→%s: %w", e.SourceID, e.TargetID, err)
			}
			s, _ := res.Consume(ctx)
			if s.Counters().RelationshipsCreated() == 0 && s.Counters().PropertiesSet() == 0 {
				missing++
			} else if e.RelationshipType == "REQUIRES" {
				req++
			} else {
				rel++
			}
		}
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Printf("   ✓ %d REQUIRES + %d RELATED_TO edges", req, rel)
	if missing > 0 {
		fmt.Printf(" (%d skipped)", missing)
	}
	fmt.Println()
	return nil
}

// =============================================================================
// CSV PARSERS
// =============================================================================

func parseConceptsCSV(path string) ([]ConceptNode, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []ConceptNode
	for i, r := range recs[1:] {
		if len(r) < 7 {
			return nil, fmt.Errorf("concepts row %d: need 7 cols", i+2)
		}
		layer, _ := strconv.Atoi(trim(r[6]))
		out = append(out, ConceptNode{trim(r[0]), trim(r[1]), trim(r[2]), trim(r[3]), trim(r[4]), trim(r[5]), layer})
	}
	return out, nil
}

func parseFormulasCSV(path string) ([]FormulaNode, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []FormulaNode
	for i, r := range recs[1:] {
		if len(r) < 7 {
			return nil, fmt.Errorf("formulas row %d: need 7 cols", i+2)
		}
		level, _ := strconv.Atoi(trim(r[5]))
		out = append(out, FormulaNode{trim(r[0]), trim(r[1]), trim(r[2]), trim(r[3]), trim(r[4]), level, strings.EqualFold(trim(r[6]), "true")})
	}
	return out, nil
}

func parseL2LabelsCSV(path string) ([]L2LabelNode, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []L2LabelNode
	for i, r := range recs[1:] {
		if len(r) < 7 {
			return nil, fmt.Errorf("l2_labels row %d: need 7 cols", i+2)
		}
		out = append(out, L2LabelNode{trim(r[0]), trim(r[1]), trim(r[2]), trim(r[3]), trim(r[4]), trim(r[5]), trim(r[6])})
	}
	return out, nil
}

func parseVideosCSV(path string) ([]VideoNode, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []VideoNode
	for i, r := range recs[1:] {
		if len(r) < 9 {
			return nil, fmt.Errorf("videos row %d: need 9 cols", i+2)
		}
		dur, _ := strconv.Atoi(trim(r[6]))
		out = append(out, VideoNode{trim(r[0]), trim(r[1]), trim(r[2]), trim(r[3]), trim(r[4]), trim(r[5]), trim(r[7]), trim(r[8]), dur})
	}
	return out, nil
}

func parseUseCasesCSV(path string) ([]UseCaseNode, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []UseCaseNode
	for i, r := range recs[1:] {
		if len(r) < 5 {
			return nil, fmt.Errorf("use_cases row %d: need 5 cols", i+2)
		}
		out = append(out, UseCaseNode{trim(r[0]), trim(r[1]), trim(r[2]), trim(r[3]), trim(r[4])})
	}
	return out, nil
}

func parseEdgesCSV(path string) ([]Edge, error) {
	recs, err := readCSV(path)
	if err != nil {
		return nil, err
	}
	var out []Edge
	for i, r := range recs[1:] {
		if len(r) < 4 {
			return nil, fmt.Errorf("edges row %d: need 4 cols", i+2)
		}
		w, _ := strconv.ParseFloat(trim(r[3]), 64)
		out = append(out, Edge{trim(r[0]), trim(r[1]), trim(r[2]), w})
	}
	return out, nil
}

// =============================================================================
// VERIFICATION — 11 tests covering every agent access pattern
// =============================================================================

func runVerification(ctx context.Context, driver neo4j.DriverWithContext) {
	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════")
	fmt.Println("  Verification — 11 tests across all agent access patterns")
	fmt.Println("══════════════════════════════════════════════════════════════")

	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeRead})
	defer session.Close(ctx)

	pass, fail := 0, 0

	test := func(label, q string, params map[string]any, check func([]map[string]any) bool) {
		var rows []map[string]any
		_, err := session.ExecuteRead(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
			res, err := tx.Run(ctx, q, params)
			if err != nil {
				return nil, err
			}
			for res.Next(ctx) {
				row := map[string]any{}
				for _, k := range res.Record().Keys {
					row[k], _ = res.Record().Get(k)
				}
				rows = append(rows, row)
			}
			return nil, res.Err()
		})
		if err != nil {
			fmt.Printf("  ✗ %-48s ERROR: %v\n", label, err)
			fail++
			return
		}
		if check(rows) {
			fmt.Printf("  ✓ %-48s %d row(s)\n", label, len(rows))
			pass++
		} else {
			fmt.Printf("  ✗ %-48s FAILED — got %d row(s)\n", label, len(rows))
			fail++
		}
	}

	countGE := func(field string, min int64) func([]map[string]any) bool {
		return func(rows []map[string]any) bool {
			if len(rows) == 0 {
				return false
			}
			v, _ := rows[0][field].(int64)
			return v >= min
		}
	}

	test("T01  T-Box: Class nodes ≥ 7",
		`MATCH (c:Class) RETURN COUNT(c) AS n`, nil, countGE("n", 7))

	test("T02  T-Box: Relation nodes ≥ 9",
		`MATCH (r:Relation) RETURN COUNT(r) AS n`, nil, countGE("n", 9))

	test("T03  T-Box: Property nodes ≥ 13",
		`MATCH (p:Property) RETURN COUNT(p) AS n`, nil, countGE("n", 13))

	test("T04  A-Box: 39 Concept nodes",
		`MATCH (c:Concept) RETURN COUNT(c) AS n`, nil, countGE("n", 39))

	test("T05  Prereq chain: related_rates has ≥ 7 prereqs",
		`MATCH (:Concept{id:"related_rates"})-[:REQUIRES*1..6]->(p:Concept)
		 RETURN COUNT(DISTINCT p) AS n`, nil, countGE("n", 7))

	test("T06  UI Agent: chain_rule primary formula at level 1",
		`MATCH (:Concept{id:"chain_rule"})-[:HAS_FORMULA]->(f:Formula)
		 WHERE f.is_primary=true AND f.display_level=1
		 RETURN f.notation_plain AS formula`, nil,
		func(rows []map[string]any) bool { return len(rows) >= 1 })

	test("T07  Multilingual B1: Sinhala label for chain_rule",
		`MATCH (:Concept{id:"chain_rule"})-[:HAS_LABEL]->(l:L2Label{language_code:"si"})
		 RETURN l.label AS label`, nil,
		func(rows []map[string]any) bool {
			if len(rows) == 0 {
				return false
			}
			lbl, _ := rows[0]["label"].(string)
			return lbl != ""
		})

	test("T08  Multilingual B2: Arabic text_direction is rtl",
		`MATCH (:Concept{id:"related_rates"})-[:HAS_LABEL]->(l:L2Label{language_code:"ar"})
		 RETURN l.text_direction AS dir`, nil,
		func(rows []map[string]any) bool {
			if len(rows) == 0 {
				return false
			}
			dir, _ := rows[0]["dir"].(string)
			return dir == "rtl"
		})

	test("T09  Agent 5: EN video exists for related_rates",
		`MATCH (:Concept{id:"related_rates"})-[:HAS_RESOURCE]->(v:VideoResource{language:"en"})
		 RETURN v.title AS t`, nil,
		func(rows []map[string]any) bool { return len(rows) >= 1 })

	test("T10  Context Agent: use case for optimization",
		`MATCH (:Concept{id:"optimization"})-[:APPLIED_IN]->(u:UseCase)
		 RETURN u.domain AS d`, nil,
		func(rows []map[string]any) bool { return len(rows) >= 1 })

	test("T11  Curriculum COVERS all 39 Concept nodes",
		`MATCH (:Curriculum{id:"undergrad_calculus"})-[:COVERS]->(c:Concept)
		 RETURN COUNT(c) AS n`, nil, countGE("n", 39))

	fmt.Println()
	fmt.Printf("  Result: %d passed / %d total\n", pass, pass+fail)
	fmt.Println("══════════════════════════════════════════════════════════════")
}

// =============================================================================
// SUMMARY
// =============================================================================

func printSummary(ctx context.Context, driver neo4j.DriverWithContext,
	elapsed time.Duration, nC, nF, nL, nV, nU, nE int) {

	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeRead})
	defer session.Close(ctx)

	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════")
	fmt.Println("  Unpack DSKG — Build Complete")
	fmt.Printf("  Build time: %s\n", elapsed.Round(time.Millisecond))
	fmt.Println("══════════════════════════════════════════════════════════════")
	fmt.Println("  T-Box (ontology): :Class · :Relation · :Property · :Curriculum")
	fmt.Printf("  A-Box (instances): %d concepts, %d formulas, %d L2 labels,\n", nC, nF, nL)
	fmt.Printf("                     %d videos, %d use cases, %d edges\n", nV, nU, nE)
	fmt.Println()
	fmt.Println("  Live node counts:")
	session.ExecuteRead(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		res, _ := tx.Run(ctx, `MATCH (n) RETURN labels(n)[0] AS l, COUNT(n) AS c ORDER BY c DESC`, nil)
		for res.Next(ctx) {
			r := res.Record()
			l, _ := r.Get("l")
			c, _ := r.Get("c")
			fmt.Printf("    %-22v %v\n", l, c)
		}
		return nil, nil
	})
	fmt.Println("  Live relation counts:")
	session.ExecuteRead(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		res, _ := tx.Run(ctx, `MATCH ()-[r]->() RETURN type(r) AS t, COUNT(r) AS c ORDER BY c DESC`, nil)
		for res.Next(ctx) {
			r := res.Record()
			t, _ := r.Get("t")
			c, _ := r.Get("c")
			fmt.Printf("    %-24v %v\n", t, c)
		}
		return nil, nil
	})
	fmt.Println()
	fmt.Println("  Next steps:")
	fmt.Println("    go run main.go --verify        run 11 verification tests")
	fmt.Println("    open http://localhost:7474      Neo4j Browser")
	fmt.Println("    see cypher/06_agent_queries.cypher  ADK tool queries")
	fmt.Println("    see cypher/07_verify.cypher    full manual test suite")
	fmt.Println("══════════════════════════════════════════════════════════════")
}

// =============================================================================
// UTILITIES
// =============================================================================

func newDriver() (neo4j.DriverWithContext, error) {
	uri := getEnv("NEO4J_URI", "neo4j+s://86b769c2.databases.neo4j.io")
	user := getEnv("NEO4J_USER", "86b769c2")
	pass := getEnv("NEO4J_PASSWORD", "zWT2VGUZ9ZeT4P8eP3pAUChvkY14nvi0AoKX3Gv9STU")
	if pass == "" {
		return nil, fmt.Errorf("NEO4J_PASSWORD is not set")
	}
	d, err := neo4j.NewDriverWithContext(uri, neo4j.BasicAuth(user, pass, ""))
	if err != nil {
		return nil, err
	}
	if err := d.VerifyConnectivity(context.Background()); err != nil {
		d.Close(context.Background())
		return nil, fmt.Errorf("cannot reach Neo4j at %s: %w", uri, err)
	}
	return d, nil
}

func readCSV(path string) ([][]string, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("open %s: %w", path, err)
	}
	defer f.Close()
	recs, err := csv.NewReader(f).ReadAll()
	if err != nil {
		return nil, fmt.Errorf("read %s: %w", path, err)
	}
	if len(recs) < 2 {
		return nil, fmt.Errorf("%s: no data rows", path)
	}
	return recs, nil
}

func clearAll(ctx context.Context, driver neo4j.DriverWithContext) error {
	session := driver.NewSession(ctx, neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite})
	defer session.Close(ctx)
	_, err := session.ExecuteWrite(ctx, func(tx neo4j.ManagedTransaction) (any, error) {
		tx.Run(ctx, "MATCH ()-[r]-() DELETE r", nil)
		tx.Run(ctx, "MATCH (n) DELETE n", nil)
		return nil, nil
	})
	if err != nil {
		return err
	}
	fmt.Println("🧹 Cleared all existing nodes and relations")
	return nil
}

// splitCypher kept for future programmatic Cypher file execution.
func splitCypher(src string) []string {
	var stmts []string
	var cur strings.Builder
	sc := bufio.NewScanner(strings.NewReader(src))
	for sc.Scan() {
		line := sc.Text()
		if i := strings.Index(line, "//"); i >= 0 {
			line = line[:i]
		}
		line = strings.TrimRight(line, " \t")
		if line == "" {
			continue
		}
		cur.WriteString(line + "\n")
		if strings.HasSuffix(strings.TrimSpace(line), ";") {
			s := strings.TrimSuffix(strings.TrimSpace(cur.String()), ";")
			if s != "" {
				stmts = append(stmts, s)
			}
			cur.Reset()
		}
	}
	return stmts
}

func mustOK(err error, label string) {
	if err != nil {
		log.Fatalf("%s: %v", label, err)
	}
}

func mustParse[T any](items []T, err error) []T {
	if err != nil {
		log.Fatalf("parse: %v", err)
	}
	return items
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func trim(s string) string { return strings.TrimSpace(s) }
