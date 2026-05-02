from typing import List, Dict, Any
from langchain_core.tools import tool
from neo4j import GraphDatabase
import os

# Base connectivity setup
URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
USER = os.getenv("NEO4J_USER", "neo4j")
PASS = os.getenv("NEO4J_PASSWORD", "yourpassword")

def _get_driver():
    return GraphDatabase.driver(URI, auth=(USER, PASS))

@tool
def get_prerequisite_path(concept_id: str) -> List[Dict[str, Any]]:
    """
    Retrieves an ordered list of prerequisite concepts for a given target concept.
    This traversal uses the Directed Acyclic Graph (DAG) formed by REQUIRES edges 
    to map the required foundational knowledge paths up to 5 levels deep.
    
    Args:
        concept_id (str): The unique identifier of the target concept (e.g., "chain_rule").
        
    Returns:
        List[Dict[str, Any]]: A list of dictionaries representing prerequisite concepts, 
        ordered by their shortest path of hops and curriculum layers:
        [{"id": "...", "name": "...", "layer": 1}, ...]
    """
    query = '''
    MATCH path = (c:Concept {id: $concept_id})-[:REQUIRES*1..5]->(p:Concept)
    RETURN DISTINCT p.id AS prereq_id, 
                    p.name AS prereq_name, 
                    p.curriculum_layer AS layer,
                    min(length(path)) AS shortest_path_hops
    ORDER BY shortest_path_hops, layer
    '''
    try:
        with _get_driver() as driver:
            with driver.session() as session:
                result = session.run(query, concept_id=concept_id)
                records = [
                    {"id": record["prereq_id"], "name": record["prereq_name"], "layer": record["layer"]} 
                    for record in result
                ]
                if not records:
                    return [{"error": f"No prerequisites found for '{concept_id}'. Please verify the concept ID or it may be a root foundational concept."}]
                return records
    except Exception as e:
        return [{"error": f"Graph DB connection or execution error: {str(e)}"}]


@tool
def get_concept_details(concept_name: str) -> Dict[str, Any]:
    """
    Retrieves a comprehensive contextual sub-graph for a mathematical concept using fuzzy string matching.
    It returns a clean, flat dictionary containing the concept's core theory, 
    its primary formula, and one real-world use case mapped directly from the graph.

    Args:
        concept_name (str): The name or part of the name of the concept (e.g., "derivative", "chain rule").

    Returns:
        Dict[str, Any]: A dictionary containing core concept details, primary formula, 
        and application domain. Includes an "error" key if no match is found.
    """
    query = '''
    MATCH (c:Concept)
    WHERE toLower(c.name) CONTAINS toLower($concept_name)
    WITH c LIMIT 1
    OPTIONAL MATCH (c)-[:HAS_FORMULA {primary: true}]->(f:Formula)
    OPTIONAL MATCH (c)-[:APPLIED_IN]->(u:UseCase)
    RETURN c {
        .id, 
        .name, 
        .core_theory, 
        .type,
        primary_formula: f.notation_plain,
        latex_formula: f.latex,
        use_case_domain: u.domain,
        use_case_example: u.problem_example
    } AS concept_data
    '''
    try:
        with _get_driver() as driver:
            with driver.session() as session:
                result = session.run(query, concept_name=concept_name.strip())
                record = result.single()
                if not record or not record.get("concept_data"):
                    return {"error": f"Concept matching '{concept_name}' not found in the Knowledge Graph."}
                return record["concept_data"]
    except Exception as e:
        return {"error": f"Graph DB connection or execution error: {str(e)}"}
