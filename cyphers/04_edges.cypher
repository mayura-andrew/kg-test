// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 04_edges.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Create all REQUIRES (prerequisite) and RELATED_TO (conceptual
//           sibling) edges between Concept nodes.
//
// REQUIRES semantics: asymmetric, transitive, weighted
//   weight 1.0 = hard prerequisite (student cannot proceed without this)
//   weight 0.8 = strongly recommended
//   weight 0.7 = helpful but not strictly blocking
//
// RELATED_TO semantics: symmetric, non-transitive, weighted
//   weight 1.0 = definitionally linked (inverse functions, FTC duality)
//   weight 0.9 = frequently co-occur in the same problem
//   weight 0.8 = share mathematical structure
//
// Run AFTER 03_concepts.cypher — nodes must exist before edges.
// ═══════════════════════════════════════════════════════════════════════════════


// ── REQUIRES: Layer 0 → Layer 0 (internal pre-calculus) ───────────────────────

MATCH (a:Concept {id:"arithmetic"}),           (b:Concept {id:"algebra"})              MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"algebra"}),              (b:Concept {id:"coordinate_geometry"})  MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"coordinate_geometry"}),  (b:Concept {id:"pythagorean_theorem"})  MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"pythagorean_theorem"}),  (b:Concept {id:"similar_triangles"})    MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"algebra"}),              (b:Concept {id:"trigonometry_basics"})  MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"trigonometry_basics"}),  (b:Concept {id:"unit_circle"})          MERGE (a)-[:REQUIRES {weight:1.0}]->(b);


// ── REQUIRES: Layer 0 → Layer 1 ───────────────────────────────────────────────

MATCH (a:Concept {id:"algebra"}),              (b:Concept {id:"func_basics"})          MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"coordinate_geometry"}),  (b:Concept {id:"func_basics"})          MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"algebra"}),              (b:Concept {id:"exponential_functions"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"algebra"}),              (b:Concept {id:"logarithmic_functions"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"unit_circle"}),          (b:Concept {id:"trigonometric_functions"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);


// ── REQUIRES: Layer 1 core chain ──────────────────────────────────────────────

MATCH (a:Concept {id:"func_basics"}),          (b:Concept {id:"limits"})               MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"continuity"})           MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"derivatives"})          MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"continuity"}),           (b:Concept {id:"derivatives"})          MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"power_rule"})           MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"product_rule"})         MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"quotient_rule"})        MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"chain_rule"})           MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"power_rule"}),           (b:Concept {id:"product_rule"})         MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"power_rule"}),           (b:Concept {id:"quotient_rule"})        MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"exponential_functions"}), (b:Concept {id:"logarithmic_functions"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"trigonometric_functions"}),(b:Concept {id:"trigonometric_derivatives"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"trigonometric_derivatives"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);


// ── REQUIRES: → Implicit Differentiation ──────────────────────────────────────

MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"implicit_differentiation"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"product_rule"}),         (b:Concept {id:"implicit_differentiation"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"implicit_differentiation"}) MERGE (a)-[:REQUIRES {weight:0.8}]->(b);


// ── REQUIRES: → Related Rates ─────────────────────────────────────────────────

MATCH (a:Concept {id:"implicit_differentiation"}),(b:Concept {id:"related_rates"})    MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"related_rates"})       MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"pythagorean_theorem"}),  (b:Concept {id:"related_rates"})       MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"similar_triangles"}),    (b:Concept {id:"related_rates"})       MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"trigonometric_derivatives"}),(b:Concept {id:"related_rates"})   MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"exponential_functions"}),(b:Concept {id:"related_rates"})       MERGE (a)-[:REQUIRES {weight:0.7}]->(b);
MATCH (a:Concept {id:"logarithmic_functions"}),(b:Concept {id:"related_rates"})       MERGE (a)-[:REQUIRES {weight:0.7}]->(b);


// ── REQUIRES: → Optimisation ──────────────────────────────────────────────────

MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"critical_points"})     MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"critical_points"}),      (b:Concept {id:"second_derivative_test"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"critical_points"}),      (b:Concept {id:"optimization"})        MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"second_derivative_test"}),(b:Concept {id:"optimization"})       MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"optimization"})        MERGE (a)-[:REQUIRES {weight:0.7}]->(b);


// ── REQUIRES: → Curve Sketching ───────────────────────────────────────────────

MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"curve_sketching"})     MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"curve_sketching"})     MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"continuity"}),           (b:Concept {id:"curve_sketching"})     MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"critical_points"}),      (b:Concept {id:"curve_sketching"})     MERGE (a)-[:REQUIRES {weight:0.9}]->(b);


// ── REQUIRES: Layer 1 → Layer 2 ───────────────────────────────────────────────

MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"integration"})         MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"integration"})         MERGE (a)-[:REQUIRES {weight:0.8}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"indefinite_integrals"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"definite_integrals"})  MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"substitution"})        MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"substitution"})        MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"product_rule"}),         (b:Concept {id:"integration_by_parts"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"integration_by_parts"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"fundamental_theorem"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"fundamental_theorem"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"definite_integrals"}),   (b:Concept {id:"area_between_curves"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"fundamental_theorem"}),  (b:Concept {id:"area_between_curves"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"definite_integrals"}),   (b:Concept {id:"volume_revolution"})   MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"similar_triangles"}),    (b:Concept {id:"volume_revolution"})   MERGE (a)-[:REQUIRES {weight:0.7}]->(b);


// ── REQUIRES: Layer 2 → Layer 3 ───────────────────────────────────────────────

MATCH (a:Concept {id:"func_basics"}),          (b:Concept {id:"sequences_series"})    MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"limits"}),               (b:Concept {id:"sequences_series"})    MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"sequences_series"}),     (b:Concept {id:"convergence_tests"})   MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"sequences_series"}),     (b:Concept {id:"taylor_series"})       MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"taylor_series"})       MERGE (a)-[:REQUIRES {weight:1.0}]->(b);


// ── REQUIRES: → Layer 4 ───────────────────────────────────────────────────────

MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"partial_derivatives"}) MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"func_basics"}),          (b:Concept {id:"partial_derivatives"}) MERGE (a)-[:REQUIRES {weight:0.9}]->(b);
MATCH (a:Concept {id:"integration"}),          (b:Concept {id:"multiple_integrals"})  MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"partial_derivatives"}),  (b:Concept {id:"multiple_integrals"})  MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"partial_derivatives"}),  (b:Concept {id:"vector_calculus"})     MERGE (a)-[:REQUIRES {weight:1.0}]->(b);
MATCH (a:Concept {id:"multiple_integrals"}),   (b:Concept {id:"vector_calculus"})     MERGE (a)-[:REQUIRES {weight:0.9}]->(b);


// ── RELATED_TO: Differentiation ↔ Integration duality ────────────────────────

MATCH (a:Concept {id:"derivatives"}),          (b:Concept {id:"integration"})         MERGE (a)-[:RELATED_TO {weight:1.0, reason:"fundamental_theorem_duality"}]->(b);
MATCH (a:Concept {id:"indefinite_integrals"}), (b:Concept {id:"derivatives"})         MERGE (a)-[:RELATED_TO {weight:0.9, reason:"antiderivative_relationship"}]->(b);
MATCH (a:Concept {id:"definite_integrals"}),   (b:Concept {id:"fundamental_theorem"}) MERGE (a)-[:RELATED_TO {weight:1.0, reason:"definitional_link"}]->(b);
MATCH (a:Concept {id:"substitution"}),         (b:Concept {id:"chain_rule"})          MERGE (a)-[:RELATED_TO {weight:0.9, reason:"chain_rule_in_reverse"}]->(b);
MATCH (a:Concept {id:"integration_by_parts"}), (b:Concept {id:"product_rule"})        MERGE (a)-[:RELATED_TO {weight:0.9, reason:"product_rule_in_reverse"}]->(b);


// ── RELATED_TO: Differentiation rules cluster ─────────────────────────────────

MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"product_rule"})        MERGE (a)-[:RELATED_TO {weight:0.8, reason:"frequently_combined"}]->(b);
MATCH (a:Concept {id:"chain_rule"}),           (b:Concept {id:"implicit_differentiation"}) MERGE (a)-[:RELATED_TO {weight:0.9, reason:"core_technique"}]->(b);
MATCH (a:Concept {id:"product_rule"}),         (b:Concept {id:"quotient_rule"})       MERGE (a)-[:RELATED_TO {weight:0.9, reason:"algebraically_equivalent"}]->(b);


// ── RELATED_TO: Trigonometry cluster ─────────────────────────────────────────

MATCH (a:Concept {id:"unit_circle"}),          (b:Concept {id:"trigonometric_functions"}) MERGE (a)-[:RELATED_TO {weight:1.0, reason:"definitional"}]->(b);
MATCH (a:Concept {id:"trigonometric_functions"}),(b:Concept {id:"trigonometric_derivatives"}) MERGE (a)-[:RELATED_TO {weight:1.0, reason:"direct_application"}]->(b);


// ── RELATED_TO: Exponential/Log duality ──────────────────────────────────────

MATCH (a:Concept {id:"exponential_functions"}),(b:Concept {id:"logarithmic_functions"}) MERGE (a)-[:RELATED_TO {weight:1.0, reason:"inverse_function_pair"}]->(b);


// ── RELATED_TO: Geometry cluster ─────────────────────────────────────────────

MATCH (a:Concept {id:"pythagorean_theorem"}),  (b:Concept {id:"similar_triangles"})   MERGE (a)-[:RELATED_TO {weight:0.85, reason:"right_triangle_geometry"}]->(b);
MATCH (a:Concept {id:"coordinate_geometry"}),  (b:Concept {id:"func_basics"})         MERGE (a)-[:RELATED_TO {weight:0.8, reason:"graphical_representation"}]->(b);


// ── RELATED_TO: Optimisation cluster ─────────────────────────────────────────

MATCH (a:Concept {id:"optimization"}),         (b:Concept {id:"curve_sketching"})     MERGE (a)-[:RELATED_TO {weight:0.85, reason:"share_critical_point_analysis"}]->(b);
MATCH (a:Concept {id:"critical_points"}),      (b:Concept {id:"second_derivative_test"}) MERGE (a)-[:RELATED_TO {weight:1.0, reason:"classification_pair"}]->(b);


// ── RELATED_TO: Series cluster ────────────────────────────────────────────────

MATCH (a:Concept {id:"taylor_series"}),        (b:Concept {id:"convergence_tests"})   MERGE (a)-[:RELATED_TO {weight:0.9, reason:"convergence_required"}]->(b);
MATCH (a:Concept {id:"sequences_series"}),     (b:Concept {id:"limits"})              MERGE (a)-[:RELATED_TO {weight:0.9, reason:"limit_of_partial_sums"}]->(b);


// ── RELATED_TO: Multivariable cluster ────────────────────────────────────────

MATCH (a:Concept {id:"partial_derivatives"}),  (b:Concept {id:"vector_calculus"})     MERGE (a)-[:RELATED_TO {weight:0.9, reason:"multivariable_domain"}]->(b);
MATCH (a:Concept {id:"multiple_integrals"}),   (b:Concept {id:"vector_calculus"})     MERGE (a)-[:RELATED_TO {weight:0.9, reason:"multivariable_domain"}]->(b);
