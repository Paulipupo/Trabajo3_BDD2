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
// Resolver: version SIN APOC (Memgraph no tiene apoc.coll.toSet, pero si all(),
// range(), reduce(), nodes(), relationships()).
//
// REGLA: para N ciudades usa [:ROAD*N] y range(0, N-1) en ambos range().
// ============================================================================


// ---- VERIFICACION DE CARGA ----
MATCH (c:City) RETURN count(c) AS ciudades;
MATCH (:City)-[r:ROAD]->(:City) RETURN count(r) AS aristas;  // debe ser N*(N-1)/2


// ---- N = 4  ->  *4 y range(0,3) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*4]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,3) WHERE all(j IN range(i+1,3) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 6  ->  *6 y range(0,5) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*6]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,5) WHERE all(j IN range(i+1,5) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 8  ->  *8 y range(0,7) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*8]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,7) WHERE all(j IN range(i+1,7) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 10  ->  *10 y range(0,9) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*10]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,9) WHERE all(j IN range(i+1,9) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 12  ->  *12 y range(0,11) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*12]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,11) WHERE all(j IN range(i+1,11) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 14  ->  *14 y range(0,13) ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*14]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,13) WHERE all(j IN range(i+1,13) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;


// ============================================================================
// NOTAS
// ----------------------------------------------------------------------------
// - Memgraph tiene un modulo MAGE tsp, pero es APROXIMADO -> NO sirve para el
//   requisito de optimo (opciones 1-5). Para la respuesta optima usa la fuerza
//   bruta en Cypher de arriba. Usa MAGE solo como comparacion extra, dejandolo claro.
// - Memgraph Lab muestra la duracion de cada consulta -> ese es el tiempo a capturar.
// - OBJETIVO: ¿Memgraph aguanta MAS ciudades que Neo4j? ¿tiempos mejores/iguales/peores?
// - COSTO OPTIMO esperado por N (debe coincidir con Opciones 1,2,3,4):
//     N=4 -> 193 | N=6 -> 276 | N=8 -> 308 | N=10 -> 330 | N=12 -> 397 | N=14 -> 448
// ============================================================================
