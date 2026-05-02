// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 01_schema.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Create all uniqueness constraints, property indexes, and fulltext
//           indexes. Run this FIRST, before any data is loaded.
//
// IDEMPOTENT : Every statement uses IF NOT EXISTS — safe to re-run.
//
// EXECUTION ORDER:
//   01_schema.cypher        ← this file
//   02_ontology.cypher
//   03_concepts.cypher
//   04_formulas.cypher
//   05_l2_labels.cypher
//   06_videos.cypher
//   07_use_cases.cypher
//   08_edges.cypher
//   09_agent_queries.cypher
//   10_verify.cypher
// ═══════════════════════════════════════════════════════════════════════════════


// ── UNIQUENESS CONSTRAINTS ────────────────────────────────────────────────────
// Neo4j enforces these at write time. They also create an implicit index.

CREATE CONSTRAINT concept_id_unique IF NOT EXISTS
  FOR (c:Concept) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT formula_id_unique IF NOT EXISTS
  FOR (f:Formula) REQUIRE f.id IS UNIQUE;

CREATE CONSTRAINT l2label_id_unique IF NOT EXISTS
  FOR (l:L2Label) REQUIRE l.id IS UNIQUE;

CREATE CONSTRAINT video_id_unique IF NOT EXISTS
  FOR (v:VideoResource) REQUIRE v.id IS UNIQUE;

CREATE CONSTRAINT usecase_id_unique IF NOT EXISTS
  FOR (u:UseCase) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT class_name_unique IF NOT EXISTS
  FOR (c:Class) REQUIRE c.name IS UNIQUE;

CREATE CONSTRAINT relation_name_unique IF NOT EXISTS
  FOR (r:Relation) REQUIRE r.name IS UNIQUE;

CREATE CONSTRAINT property_name_unique IF NOT EXISTS
  FOR (p:Property) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT curriculum_id_unique IF NOT EXISTS
  FOR (c:Curriculum) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT problem_type_id_unique IF NOT EXISTS
  FOR (p:ProblemType) REQUIRE p.id IS UNIQUE;


// ── PROPERTY INDEXES ──────────────────────────────────────────────────────────
// Used by the ADK agent tool queries. Each index speeds up a specific
// agent access pattern.

// UI Mapping Agent — look up concepts by type for colour coding
CREATE INDEX concept_type IF NOT EXISTS
  FOR (c:Concept) ON (c.type);

// Concept explicit name lookup index
CREATE INDEX concept_name IF NOT EXISTS
  FOR (c:Concept) ON (c.name);

// Phase 4 Prereq Graph Builder — filter by curriculum layer
CREATE INDEX concept_layer IF NOT EXISTS
  FOR (c:Concept) ON (c.curriculum_layer);

// Multilingual Agent B1 — look up L2 labels by language code
CREATE INDEX l2label_language IF NOT EXISTS
  FOR (l:L2Label) ON (l.language_code);

// Resource Curator (Agent 5) — filter videos by language
CREATE INDEX video_language IF NOT EXISTS
  FOR (v:VideoResource) ON (v.language);

// Resource Curator — filter by difficulty
CREATE INDEX video_difficulty IF NOT EXISTS
  FOR (v:VideoResource) ON (v.difficulty);

// UI Mapping Agent — fetch only primary hover formula
CREATE INDEX formula_primary IF NOT EXISTS
  FOR (f:Formula) ON (f.is_primary);

// UI Mapping Agent — fetch formula by display level
CREATE INDEX formula_display_level IF NOT EXISTS
  FOR (f:Formula) ON (f.display_level);

// Use Case context agent — filter by domain
CREATE INDEX usecase_domain IF NOT EXISTS
  FOR (u:UseCase) ON (u.domain);


// ── FULLTEXT INDEXES ──────────────────────────────────────────────────────────
// Used by Agent 1 (Lexical Parser) for fuzzy concept name lookup and
// Agent 3 (Gap Detector) to search for near-matches when a token returns null.

CREATE FULLTEXT INDEX concept_search IF NOT EXISTS
  FOR (c:Concept)
  ON EACH [c.name, c.description, c.core_theory];

CREATE FULLTEXT INDEX l2label_search IF NOT EXISTS
  FOR (l:L2Label)
  ON EACH [l.label, l.description_l2, l.curriculum_name];

CREATE FULLTEXT INDEX usecase_search IF NOT EXISTS
  FOR (u:UseCase)
  ON EACH [u.description, u.problem_example, u.domain];


// ── VERIFY SCHEMA ─────────────────────────────────────────────────────────────
// Run this after the file to confirm everything was created:
//
//   SHOW CONSTRAINTS;
//   SHOW INDEXES;
