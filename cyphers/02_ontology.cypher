// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 02_ontology.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Define the T-Box (Terminology Box) — the ontology layer that
//           formally declares what entity types and relation types exist and
//           what they mean. This is what separates a Knowledge Graph from a
//           plain property graph.
//
// THEORY  : In description logic, a KG has two layers:
//   T-Box (this file)  — Classes, Relations, Properties (the schema)
//   A-Box (03–08)      — Instances: actual Concept, Formula, Video nodes
//
// CITATION: Hevner et al. (2004); Hogan et al. (2021) ACM Computing Surveys
// ═══════════════════════════════════════════════════════════════════════════════


// ── CLASS NODES (entity type declarations) ────────────────────────────────────

MERGE (:Class {
  name:        "Concept",
  description: "A mathematical concept at undergraduate curriculum level (pre-calculus through multivariable calculus).",
  scope:       "undergraduate mathematics",
  valid_types: ["Foundation", "Calculus", "Geometry", "Rate of Change", "Goal", "Equation Type"]
});

MERGE (:Class {
  name:        "Formula",
  description: "A mathematical formula or notation associated with a Concept. Stored separately so the UI agent can fetch only the formula on hover without retrieving the full theory paragraph.",
  scope:       "mathematical notation"
});

MERGE (:Class {
  name:        "L2Label",
  description: "A canonical multilingual label for a Concept in a specific natural language. Stored as a node (not a flat property) so it can be queried by language_code without a full concept scan.",
  scope:       "multilingual localisation"
});

MERGE (:Class {
  name:        "VideoResource",
  description: "An educational video resource (YouTube) linked to a Concept. Stored as a node so Agent 5 can filter by language, difficulty, and channel authority without loading all concept properties.",
  scope:       "educational media"
});

MERGE (:Class {
  name:        "UseCase",
  description: "A real-world application of a mathematical concept. Answers the student question: why am I learning this?",
  scope:       "contextual scaffolding"
});

MERGE (:Class {
  name:        "ProblemType",
  description: "A category of mathematics word problem (e.g. Related Rates, Optimisation). Links to the primary Concept it tests via EXEMPLIFIES and to supporting concepts via INVOLVES.",
  scope:       "problem classification"
});

MERGE (:Class {
  name:        "Curriculum",
  description: "An academic curriculum or course that provides scope context for the graph.",
  scope:       "academic scope"
});


// ── RELATION NODES (edge type declarations with formal semantics) ──────────────

MERGE (:Relation {
  name:          "REQUIRES",
  domain:        "Concept",
  range:         "Concept",
  definition:    "A student cannot engage with the target Concept without prior mastery of the source Concept. Asymmetric and transitive: if A REQUIRES B and B REQUIRES C then A transitively REQUIRES C.",
  is_transitive: true,
  is_symmetric:  false,
  weight_meaning: "Strength of dependency: 1.0 = hard prerequisite, 0.7 = strongly recommended, below 0.7 = helpful but not blocking."
});

MERGE (:Relation {
  name:          "RELATED_TO",
  domain:        "Concept",
  range:         "Concept",
  definition:    "Two Concepts frequently co-occur in the same problem context or share deep mathematical structure, but neither is strictly prerequisite to the other. Symmetric and non-transitive.",
  is_transitive: false,
  is_symmetric:  true,
  weight_meaning: "Strength of conceptual relationship: 1.0 = definitionally linked, 0.8 = frequently combined."
});

MERGE (:Relation {
  name:          "HAS_FORMULA",
  domain:        "Concept",
  range:         "Formula",
  definition:    "A Concept has a mathematical formula. One concept can have multiple formulas (standard + Leibniz notation). The primary formula (is_primary: true) is shown at hover state 1.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "HAS_LABEL",
  domain:        "Concept",
  range:         "L2Label",
  definition:    "A Concept has a canonical name in a specific natural language. The Multilingual Agent B1 behaviour queries this by language_code to retrieve the textbook-canonical term rather than generating a translation.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "HAS_RESOURCE",
  domain:        "Concept",
  range:         "VideoResource",
  definition:    "A Concept has a linked educational video resource. Agent 5 (Resource Curator) attaches videos here. The UI agent queries by language to serve content in the student's L1.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "APPLIED_IN",
  domain:        "Concept",
  range:         "UseCase",
  definition:    "A Concept is applied in a real-world use case. Answers the student question: why am I learning this? Used in hover state 3 (high support) of the progressive disclosure UI.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "EXEMPLIFIES",
  domain:        "ProblemType",
  range:         "Concept",
  definition:    "A word problem of this ProblemType directly requires the student to apply this Concept as the primary mathematical operation. Used by Phase 1 agent to identify the core concept from a problem.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "INVOLVES",
  domain:        "ProblemType",
  range:         "Concept",
  definition:    "A word problem of this ProblemType uses this Concept as a supporting (not primary) operation. Used by Phase 4 agent to build the full prerequisite mind map.",
  is_transitive: false,
  is_symmetric:  false
});

MERGE (:Relation {
  name:          "COVERS",
  domain:        "Curriculum",
  range:         "Concept",
  definition:    "This Curriculum includes this Concept within its scope. Enables scope-bounded KG queries: only return concepts that belong to undergraduate calculus.",
  is_transitive: false,
  is_symmetric:  false
});


// ── PROPERTY NODES (typed property documentation) ─────────────────────────────
// These make every property machine-interpretable — a key KG requirement.

MERGE (:Property {
  name:        "id",
  applies_to:  "Concept",
  datatype:    "String",
  definition:  "Unique stable slug identifier. Used as graph_node_id in the Unpack UI JSON schema.",
  example:     "related_rates"
});

MERGE (:Property {
  name:        "core_theory",
  applies_to:  "Concept",
  datatype:    "String",
  definition:  "The strict mathematical definition of the concept in 1-2 sentences. Shown at hover state 2 (medium cognitive load) in the progressive disclosure UI.",
  example:     "The derivative f'(x) = lim(h→0)[f(x+h)-f(x)]/h measures instantaneous rate of change."
});

MERGE (:Property {
  name:        "type",
  applies_to:  "Concept",
  datatype:    "String",
  definition:  "Pedagogical category that controls token colour in the UI.",
  valid_values: ["Foundation", "Calculus", "Geometry", "Rate of Change", "Goal", "Equation Type"]
});

MERGE (:Property {
  name:        "color",
  applies_to:  "Concept",
  datatype:    "String",
  definition:  "Hex colour for the UI token underline and tooltip badge. Encodes semantic type.",
  example:     "#9B3ABB for Rate of Change, #B85010 for Goal, #2D5FCC for Calculus"
});

MERGE (:Property {
  name:        "curriculum_layer",
  applies_to:  "Concept",
  datatype:    "Integer",
  definition:  "Depth in the curriculum hierarchy: 0=pre-calculus, 1=differentiation, 2=integration, 3=series, 4=multivariable.",
  valid_values: [0, 1, 2, 3, 4]
});

MERGE (:Property {
  name:        "latex",
  applies_to:  "Formula",
  datatype:    "String",
  definition:  "Raw LaTeX string for the formula. Rendered by the UI using KaTeX or MathJax."
});

MERGE (:Property {
  name:        "notation_plain",
  applies_to:  "Formula",
  datatype:    "String",
  definition:  "ASCII plain-text representation of the formula. Shown in tooltip when LaTeX rendering is unavailable."
});

MERGE (:Property {
  name:        "display_level",
  applies_to:  "Formula",
  datatype:    "Integer",
  definition:  "Progressive disclosure level: 1 = shown on hover (low cognitive load), 2 = shown on click (medium cognitive load).",
  valid_values: [1, 2]
});

MERGE (:Property {
  name:        "language_code",
  applies_to:  "L2Label",
  datatype:    "String",
  definition:  "ISO 639-1 language code. Used by the Multilingual Agent to query the correct L2Label node.",
  example:     "si (Sinhala), ta (Tamil), ar (Arabic), zh (Mandarin)"
});

MERGE (:Property {
  name:        "text_direction",
  applies_to:  "L2Label",
  datatype:    "String",
  definition:  "Text rendering direction. RTL for Arabic and Hebrew; LTR for all others. The UI uses this to set CSS direction property.",
  valid_values: ["ltr", "rtl"]
});

MERGE (:Property {
  name:        "curriculum_name",
  applies_to:  "L2Label",
  datatype:    "String",
  definition:  "The canonical name as it appears in the student's home-country mathematics textbook. Not a translation — a proper curriculum term."
});


// ── CURRICULUM CONTEXT ────────────────────────────────────────────────────────

MERGE (:Curriculum {
  id:           "undergrad_calculus",
  name:         "Undergraduate Calculus",
  scope:        "First and second year university mathematics",
  covers:       ["pre-calculus foundations", "single-variable differentiation",
                 "single-variable integration", "sequences and series",
                 "multivariable calculus"],
  study_context: "Unpack RQ3 user study — non-native English speaking STEM students"
});
