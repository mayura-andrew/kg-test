// =============================================================================
// Phase 2: Graph Topology Validation
// =============================================================================

// Detect cycles in REQUIRES topological hierarchy
// Returns any paths where a concept implicitly REQUIRES itself
MATCH path = (c:Concept)-[:REQUIRES*1..5]->(c)
RETURN c.id AS cycle_node, length(path) as cycle_length, [n IN nodes(path) | n.id] AS cycle_path
LIMIT 10;

// Detect orphaned concept nodes (isolated from the entire graph logic)
MATCH (c:Concept)
WHERE NOT (c)-[]-()
RETURN c.id AS orphan_id, c.name AS orphan_name;
