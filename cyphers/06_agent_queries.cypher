// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 06_agent_queries.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Reference library of all parameterised Cypher queries used by the
//           ADK agent tools. This is NOT a migration script — it is documentation
//           and a test suite. Run each query manually in Neo4j Browser to verify
//           the graph is correctly answering each agent's access pattern.
//
// PARAMETERS: shown as $param_name — substitute real values when testing.
//
// AGENT MAPPING:
//   Agent 1 (Lexical Parser)       → SECTION 1: Fulltext search
//   Agent 2 (Symbolic Router)      → SECTION 2: Prerequisite traversal
//   Agent 3 (Gap Detector)         → SECTION 3: Null-token near-match search
//   Agent 4 (Graph Mutator)        → SECTION 4: MERGE new concept (HITL)
//   Agent 5 (Resource Curator)     → SECTION 5: Video attachment
//   UI Mapping Agent (Phase 5)     → SECTION 6: Progressive disclosure queries
//   Multilingual Agent (B1–B4)     → SECTION 7: L2 localisation queries
// ═══════════════════════════════════════════════════════════════════════════════


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 1 — AGENT 1: Lexical Parser
// Tool: kg_verify(token)
// Purpose: Check whether a token maps to a known concept in the KG.
//          Returns the concept if found, null if not (triggers Agent 3).
// ════════════════════════════════════════════════════════════════════════════════

// 1a. Exact ID match (fastest — used when Agent 1 is confident)
MATCH (c:Concept {id: $concept_id})
RETURN c.id, c.name, c.type, c.color, c.curriculum_layer;

// 1b. Fulltext name search (used when token is a natural language phrase)
CALL db.index.fulltext.queryNodes("concept_search", $search_query)
YIELD node, score
WHERE score > 1.0
RETURN node.id AS concept_id, node.name AS name, node.type AS type, score
ORDER BY score DESC
LIMIT 5;

// 1c. L2 label search (when student input is in native language)
CALL db.index.fulltext.queryNodes("l2label_search", $native_term)
YIELD node AS label_node, score
MATCH (c:Concept)-[:HAS_LABEL]->(label_node)
RETURN c.id AS concept_id, c.name AS name, label_node.language_code AS lang,
       label_node.label AS native_label, score
ORDER BY score DESC
LIMIT 5;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 2 — AGENT 2: Symbolic Router
// Tool: kg_prereqs(concept_id, depth)
// Purpose: Traverse the REQUIRES chain to build the prerequisite mind map.
//          Returns the full chain up to $depth hops.
// ════════════════════════════════════════════════════════════════════════════════

// 2a. Direct prerequisites only (depth = 1)
MATCH (c:Concept {id: $concept_id})-[:REQUIRES]->(p:Concept)
RETURN p.id, p.name, p.type, p.color, p.curriculum_layer
ORDER BY p.curriculum_layer;

// 2b. Full transitive chain (depth 1–4, the core Phase 4 query)
MATCH (c:Concept {id: $concept_id})-[:REQUIRES*1..4]->(p:Concept)
RETURN DISTINCT p.id      AS prereq_id,
                p.name    AS prereq_name,
                p.type    AS prereq_type,
                p.color   AS prereq_color,
                p.curriculum_layer AS layer
ORDER BY layer, prereq_name;

// 2c. Full prerequisite chain with path length (for mind map depth colouring)
MATCH path = (c:Concept {id: $concept_id})-[:REQUIRES*1..6]->(p:Concept)
RETURN DISTINCT p.id AS prereq_id,
                p.name AS prereq_name,
                min(length(path)) AS min_hops,
                p.curriculum_layer AS layer
ORDER BY min_hops, layer;

// 2d. Related concepts (RELATED_TO, for secondary mind map connections)
MATCH (c:Concept {id: $concept_id})-[:RELATED_TO]->(r:Concept)
RETURN r.id, r.name, r.type, r.color
ORDER BY r.name;

// 2e. Full context query (all connected nodes for one concept — Phase 4 complete)
MATCH (c:Concept {id: $concept_id})
OPTIONAL MATCH (c)-[:REQUIRES*1..4]->(prereq:Concept)
OPTIONAL MATCH (c)-[:RELATED_TO]->(related:Concept)
OPTIONAL MATCH (c)-[:HAS_FORMULA {primary: true}]->(formula:Formula)
OPTIONAL MATCH (c)-[:HAS_LABEL]->(label:L2Label {language_code: $lang})
RETURN
  c.id              AS concept_id,
  c.name            AS concept_name,
  c.core_theory     AS theory,
  c.type            AS type,
  c.color           AS color,
  collect(DISTINCT prereq.id)      AS prerequisites,
  collect(DISTINCT related.id)     AS related_concepts,
  formula.notation_plain           AS primary_formula,
  label.label                      AS native_label,
  label.text_direction             AS text_direction;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 3 — AGENT 3: Gap Detector
// Tool: kg_near_match(token)
// Purpose: When a token returns null from Agent 2, Agent 3 checks if a
//          similar concept exists (near-miss) before proposing a new node.
// ════════════════════════════════════════════════════════════════════════════════

// 3a. Near-miss fulltext search (returns candidates with confidence scores)
CALL db.index.fulltext.queryNodes("concept_search", $unresolved_token)
YIELD node, score
RETURN node.id AS candidate_id, node.name AS candidate_name, score
ORDER BY score DESC
LIMIT 3;

// 3b. Check if a proposed new concept ID already exists
MATCH (c:Concept {id: $proposed_id})
RETURN c.id, c.name;

// 3c. Find the most appropriate prerequisite for a proposed new concept
// (Used to wire new nodes correctly into the graph)
MATCH (c:Concept)
WHERE c.curriculum_layer = $proposed_layer - 1
RETURN c.id, c.name, c.type
ORDER BY c.name;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 4 — AGENT 4: Graph Mutator (HITL)
// Tools: kg_merge_pending(concept), kg_approve_pending(id), kg_rollback(id)
// Purpose: Create :Pending nodes for HITL review, approve or rollback.
// ════════════════════════════════════════════════════════════════════════════════

// 4a. Create a pending concept (does NOT link to curriculum until approved)
MERGE (c:Concept:Pending {id: $proposed_id})
SET c.name              = $name,
    c.description       = $description,
    c.core_theory       = $core_theory,
    c.type              = $type,
    c.color             = $color,
    c.curriculum_layer  = $layer,
    c.confidence        = $confidence,
    c.proposed_by       = "Agent3",
    c.proposed_at       = datetime(),
    c.status            = "pending";

// 4b. Connect pending node to its proposed prerequisites
MATCH (pending:Concept:Pending {id: $proposed_id}),
      (prereq:Concept {id: $prereq_id})
MERGE (prereq)-[:REQUIRES {weight: $weight, status: "pending"}]->(pending);

// 4c. SME approves: remove :Pending label, link to curriculum
MATCH (c:Concept:Pending {id: $concept_id})
REMOVE c:Pending
SET c.status = "approved", c.approved_at = datetime();

MATCH (cur:Curriculum {id: "undergrad_calculus"}), (c:Concept {id: $concept_id})
MERGE (cur)-[:COVERS {layer: c.curriculum_layer}]->(c);

// 4d. SME rolls back: detach and delete a pending node
MATCH (c:Concept:Pending {id: $concept_id})
DETACH DELETE c;

// 4e. List all pending concepts for the admin dashboard
MATCH (c:Concept:Pending)
RETURN c.id, c.name, c.type, c.confidence, c.proposed_at, c.status
ORDER BY c.proposed_at DESC;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 5 — AGENT 5: Resource Curator
// Tool: kg_attach_video(concept_id, video_data)
// Purpose: Attach a new VideoResource node found by the web crawler.
// ════════════════════════════════════════════════════════════════════════════════

// 5a. Check if video already exists (avoid duplicates)
MATCH (v:VideoResource {url: $url})
RETURN v.id, v.title;

// 5b. Attach a new ranked video to a concept
MATCH (c:Concept {id: $concept_id})
MERGE (v:VideoResource {id: $video_id})
SET v.platform    = $platform,
    v.title       = $title,
    v.url         = $url,
    v.language    = $language,
    v.duration_sec = $duration_sec,
    v.difficulty  = $difficulty,
    v.channel     = $channel,
    v.rank_score  = $rank_score,
    v.added_by    = "Agent5",
    v.added_at    = datetime()
MERGE (c)-[:HAS_RESOURCE {rank: $rank_score}]->(v);

// 5c. Get concepts that have no videos in a specific language
//     (Used by Agent 5 to prioritise crawl targets)
MATCH (c:Concept)
WHERE NOT EXISTS {
  MATCH (c)-[:HAS_RESOURCE]->(v:VideoResource {language: $lang})
}
RETURN c.id, c.name, c.curriculum_layer
ORDER BY c.curriculum_layer;

// 5d. Get all videos for a concept ordered by rank
MATCH (c:Concept {id: $concept_id})-[r:HAS_RESOURCE]->(v:VideoResource)
WHERE v.language = $lang
RETURN v.title, v.url, v.channel, v.duration_sec, v.difficulty, r.rank
ORDER BY r.rank DESC
LIMIT 3;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 6 — UI MAPPING AGENT (Phase 5)
// Progressive disclosure: 3 hover states with increasing cognitive load
// ════════════════════════════════════════════════════════════════════════════════

// 6a. HOVER STATE 1 (low CL) — formula only, no theory
//     Triggered: student hovers over a highlighted token
MATCH (c:Concept {id: $concept_id})-[:HAS_FORMULA]->(f:Formula)
WHERE f.display_level = 1 AND f.is_primary = true
RETURN c.name, c.type, c.color,
       f.latex AS formula_latex,
       f.notation_plain AS formula_plain;

// 6b. HOVER STATE 2 (medium CL) — theory explanation
//     Triggered: student clicks "explain this"
MATCH (c:Concept {id: $concept_id})
RETURN c.name, c.description, c.core_theory, c.type, c.color;

// 6c. HOVER STATE 3 (high support) — video in student's language
//     Triggered: student clicks "show me a video"
MATCH (c:Concept {id: $concept_id})-[:HAS_RESOURCE]->(v:VideoResource)
WHERE v.language = $student_lang
RETURN v.title, v.url, v.channel, v.duration_sec, v.difficulty
ORDER BY v.duration_sec
LIMIT 1;

// 6d. HOVER STATE 3 fallback — if no L1 video, return English
MATCH (c:Concept {id: $concept_id})-[:HAS_RESOURCE]->(v:VideoResource)
WHERE v.language IN [$student_lang, "en"]
RETURN v.title, v.url, v.language, v.channel
ORDER BY CASE v.language WHEN $student_lang THEN 0 ELSE 1 END, v.duration_sec
LIMIT 1;

// 6e. HOVER STATE 3 — use case context ("why am I learning this?")
MATCH (c:Concept {id: $concept_id})-[:APPLIED_IN]->(u:UseCase)
RETURN u.domain, u.description, u.problem_example
LIMIT 2;

// 6f. Full ui_text_blocks payload for a single concept
//     (Combines everything the Phase 5 UI mapping agent needs in one query)
MATCH (c:Concept {id: $concept_id})
OPTIONAL MATCH (c)-[:HAS_FORMULA {primary: true}]->(pf:Formula) WHERE pf.display_level = 1
OPTIONAL MATCH (c)-[:HAS_FORMULA]->(af:Formula)
OPTIONAL MATCH (c)-[:HAS_LABEL]->(l:L2Label {language_code: $student_lang})
OPTIONAL MATCH (c)-[:REQUIRES*1..4]->(prereq:Concept)
RETURN
  c.id              AS graph_node_id,
  c.name            AS concept_name,
  c.description     AS description,
  c.core_theory     AS theory,
  c.type            AS token_type,
  c.color           AS token_color,
  pf.notation_plain AS primary_formula,
  pf.latex          AS primary_formula_latex,
  collect(DISTINCT af.notation_plain) AS all_formulas,
  l.label           AS native_label,
  l.curriculum_name AS native_curriculum_name,
  l.text_direction  AS text_direction,
  collect(DISTINCT prereq.id) AS prerequisite_ids;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 7 — MULTILINGUAL AGENT (B1–B4 behaviours)
// ════════════════════════════════════════════════════════════════════════════════

// 7a. B1: KG-grounded canonical name retrieval
//     Returns the textbook-canonical term, NOT a translation
MATCH (c:Concept {id: $concept_id})-[:HAS_LABEL]->(l:L2Label {language_code: $lang})
RETURN l.label            AS canonical_label,
       l.curriculum_name  AS curriculum_name,
       l.description_l2   AS native_description,
       l.text_direction    AS direction;

// 7b. B2: RTL detection for Arabic and Hebrew
MATCH (c:Concept {id: $concept_id})-[:HAS_LABEL]->(l:L2Label {language_code: $lang})
RETURN l.text_direction AS direction,
       CASE l.text_direction WHEN "rtl" THEN true ELSE false END AS is_rtl;

// 7c. B3: Confidence gate — check if L2Label exists before attempting localisation
//     If no HAS_LABEL edge exists → fallback to English
OPTIONAL MATCH (c:Concept {id: $concept_id})-[:HAS_LABEL]->(l:L2Label {language_code: $lang})
RETURN c.name          AS english_name,
       l.label         AS native_label,
       l IS NOT NULL   AS has_native_label;

// 7d. B4: Formal register — return curriculum_name (textbook term) not label
//     (label may be colloquial; curriculum_name is always the formal textbook term)
MATCH (c:Concept {id: $concept_id})-[:HAS_LABEL]->(l:L2Label {language_code: $lang})
RETURN l.curriculum_name AS formal_term,
       l.label           AS common_term,
       l.text_direction  AS direction;


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ADMINISTRATION AND MONITORING
// ════════════════════════════════════════════════════════════════════════════════

// 8a. Full KG statistics dashboard
MATCH (n)
RETURN labels(n)[0] AS node_label, COUNT(n) AS count
ORDER BY count DESC;

MATCH ()-[r]->()
RETURN type(r) AS relation_type, COUNT(r) AS count
ORDER BY count DESC;

// 8b. Coverage report — which concepts have which node types attached
MATCH (c:Concept)
OPTIONAL MATCH (c)-[:HAS_FORMULA]->(f:Formula)
OPTIONAL MATCH (c)-[:HAS_LABEL]->(l:L2Label {language_code: "si"})
OPTIONAL MATCH (c)-[:HAS_RESOURCE]->(v:VideoResource {language: "en"})
OPTIONAL MATCH (c)-[:APPLIED_IN]->(u:UseCase)
RETURN c.id,
       c.curriculum_layer AS layer,
       f IS NOT NULL AS has_formula,
       l IS NOT NULL AS has_sinhala_label,
       v IS NOT NULL AS has_en_video,
       u IS NOT NULL AS has_use_case
ORDER BY layer, c.id;

// 8c. Find concepts with no incoming REQUIRES edges (true root concepts)
MATCH (c:Concept)
WHERE NOT ()-[:REQUIRES]->(c)
RETURN c.id, c.name, c.curriculum_layer
ORDER BY c.curriculum_layer;

// 8d. Find concept orphans (no edges of any kind)
MATCH (c:Concept)
WHERE NOT (c)-[]-()
RETURN c.id, c.name;

// 8e. Longest prerequisite chain in the graph
MATCH path = (root:Concept)-[:REQUIRES*]->(leaf:Concept)
WHERE NOT ()-[:REQUIRES]->(root) AND NOT (leaf)-[:REQUIRES]->()
RETURN root.name AS start, leaf.name AS end, length(path) AS chain_length
ORDER BY chain_length DESC
LIMIT 5;
