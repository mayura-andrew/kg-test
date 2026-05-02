# Unpack — Knowledge Graph (kg-test)

Complete Neo4j knowledge graph for the Unpack progressive disclosure
mathematics learning system. Loads 39 mathematical concepts with
formulas, multilingual labels, YouTube resources, and use cases.

## What gets built

| File | Nodes created | Relation |
|------|--------------|---------|
| `concepts.csv` | 39 `:Concept` nodes | core entity |
| `formulas.csv` | 58 `:Formula` nodes | `HAS_FORMULA` |
| `l2_labels.csv` | 156 `:L2Label` nodes | `HAS_LABEL` |
| `videos.csv` | 52 `:VideoResource` nodes | `HAS_RESOURCE` |
| `use_cases.csv` | 45 `:UseCase` nodes | `APPLIED_IN` |
| `edges.csv` | — | 63 `REQUIRES` + 16 `RELATED_TO` |

## Prerequisites

- Go 1.21+ (`go version`)
- Neo4j 5.x running locally **or** via Docker (see below)
- `GOOGLE_API_KEY` not needed for the KG — only for the ADK agent

## Option A — Docker (recommended, one command)

```bash
# 1. Copy env file and set your Neo4j password
cp .env.example .env

# 2. Start Neo4j + run migration automatically
docker-compose up

# 3. Open Neo4j Browser
open http://localhost:7474
# Username: neo4j   Password: (from your .env)
```

Docker will start Neo4j, wait for it to be ready, then run the
migration automatically. When you see:
```
unpack-migrate | ✓ Migration complete
```
the KG is fully loaded.

## Option B — Local Go run

```bash
# 1. Start Neo4j locally (or via Docker standalone)
docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/yourpassword \
  neo4j:5.20.0-community

# 2. Set env vars
export NEO4J_URI="bolt://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="yourpassword"

# 3. Install dependencies
go mod tidy

# 4. Run the migration
go run main.go

# 5. Run with verification queries
go run main.go --verify

# 6. Force a clean reload
go run main.go --clear --verify
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--data` | `./data/raw` | Directory containing CSV files |
| `--verify` | false | Run 6 verification queries after loading |
| `--clear` | false | Delete all nodes/edges before loading |

## Verification queries (run in Neo4j Browser)

```cypher
-- 1. Count all nodes by label
MATCH (n) RETURN labels(n)[0] AS label, COUNT(n) AS count ORDER BY count DESC;

-- 2. Full prerequisite chain for Related Rates
MATCH (c:Concept {id:"related_rates"})-[:REQUIRES*1..6]->(p:Concept)
RETURN DISTINCT p.name AS prerequisite, p.curriculum_layer AS layer
ORDER BY layer, prerequisite;

-- 3. Hover formula for chain_rule (UI agent query)
MATCH (c:Concept {id:"chain_rule"})-[:HAS_FORMULA]->(f:Formula)
WHERE f.display_level = 1
RETURN f.notation_plain, f.is_primary ORDER BY f.is_primary DESC;

-- 4. Sinhala label for chain_rule (multilingual agent query)
MATCH (c:Concept {id:"chain_rule"})-[:HAS_LABEL]->(l:L2Label {language_code:"si"})
RETURN l.label, l.curriculum_name, l.text_direction;

-- 5. English videos for related_rates
MATCH (c:Concept {id:"related_rates"})-[:HAS_RESOURCE]->(v:VideoResource {language:"en"})
RETURN v.title, v.channel, v.duration_sec ORDER BY v.duration_sec;

-- 6. Real-world use cases for optimization
MATCH (c:Concept {id:"optimization"})-[:APPLIED_IN]->(u:UseCase)
RETURN u.domain, u.description;
```

## Project structure

```
kg-test/
├── main.go                  ← complete loader (815 lines)
├── go.mod
├── docker-compose.yml       ← Neo4j + auto migration
├── Dockerfile               ← multi-stage Go build
├── docker/
│   └── wait-for-neo4j.sh   ← Bolt port health check
├── .env.example
├── README.md
└── data/
    └── raw/
        ├── concepts.csv     ← 39 core concept nodes
        ├── formulas.csv     ← 58 formula nodes (LaTeX + plain)
        ├── l2_labels.csv    ← 156 multilingual label nodes (si/ta/ar/zh)
        ├── videos.csv       ← 52 YouTube video nodes
        ├── use_cases.csv    ← 45 real-world application nodes
        └── edges.csv        ← 79 prerequisite + related edges
```

## ADK agent Cypher queries (copy into your agent tools)

```cypher
-- kg_prereqs: prerequisite chain for Phase 4 mind map
MATCH (c:Concept {id: $concept_id})-[:REQUIRES*1..4]->(p:Concept)
RETURN DISTINCT p.id, p.name, p.type, p.color, p.curriculum_layer
ORDER BY p.curriculum_layer;

-- kg_hover: formula for UI hover state 1
MATCH (c:Concept {id: $concept_id})-[:HAS_FORMULA {primary: true}]->(f:Formula)
WHERE f.display_level = 1
RETURN f.latex, f.notation_plain;

-- kg_l2: canonical name in student's L1 (multilingual agent B1)
MATCH (c:Concept {id: $concept_id})-[:HAS_LABEL]->(l:L2Label {language_code: $lang})
RETURN l.label, l.curriculum_name, l.text_direction;

-- kg_video: language-matched learning resource
MATCH (c:Concept {id: $concept_id})-[:HAS_RESOURCE]->(v:VideoResource {language: $lang})
RETURN v.url, v.title, v.channel, v.duration_sec
ORDER BY v.duration_sec LIMIT 1;

-- kg_usecase: real-world context ("why am I learning this?")
MATCH (c:Concept {id: $concept_id})-[:APPLIED_IN]->(u:UseCase)
RETURN u.domain, u.description, u.problem_example LIMIT 2;
```
