// ============================================================================
// OPCION 5 — TSP OPTIMO en Memgraph (Cypher PURO, sin APOC)
// ============================================================================
// De la lista db-engines.com/en/ranking/graph+dbms, Memgraph es la mejor eleccion:
// su columna "Database Model" dice GRAPH (no multi-model) y habla Cypher, asi que la
// solucion de Neo4j se reutiliza casi igual. TODO en Memgraph: nada de Python.
//
// Instalar (Docker):
//   docker run -it -p 7687:7687 -p 7444:7444 -p 3000:3000 memgraph/memgraph-platform
//   Memgraph Lab: http://localhost:3000
//
// Cargar: usa los mismos artifacts/cypher_load_N.cypher.
// Resolver: Se usa el mismo codigo Cypher de la Opción 1 y 2
//
// REGLA: para N ciudades usa [:ROAD*N] y range(0, N-1) en ambos range().
// ============================================================================


// ---- VERIFICACION DE CARGA ----
MATCH (c:City) RETURN count(c) AS ciudades;
MATCH (:City)-[r:ROAD]->(:City) RETURN count(r) AS aristas;  // debe ser N*(N-1)/2

// ============================================================================
// CONSULTA
// Para N ciudades usa [:ROAD*N] y range(0, N-1) en ambos range().
// Ejemplo ---- N = 4  ->  *4 y range(0,3) ----

MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*4]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,3) WHERE all(j IN range(i+1,3) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

