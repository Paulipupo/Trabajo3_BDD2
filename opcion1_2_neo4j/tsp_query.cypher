// ============================================================================
// OPCIONES 1 y 2 — TSP OPTIMO en Neo4j (Cypher PURO)
// ============================================================================
// Opcion 1: Neo4j Aura (nube, free tier) + Neo4j Browser.
// Opcion 2: Neo4j local (Neo4j Desktop o Docker) + Neo4j Browser.
// Ambas usan EXACTAMENTE estos mismos scripts. TODO en Cypher: nada de Python.
//
// FLUJO por cada tamano N (4,6,8,10,12,14):
//   1) Cargar el grafo: copia/pega artifacts/cypher_load_N.cypher en el Browser.
//   2) Verificar carga (conteos).
//   3) Ejecutar la consulta TSP correspondiente al N (cambia *N y el WHERE).
//   4) Capturar tiempo (footer "completed after X ms") + ruta + costo.
//
// IDEA: fijar la ciudad de inicio id:0, recorrer un camino NO dirigido de longitud N
// que vuelva al inicio, y quedarse con el de menor costo cuya secuencia visite N
// ciudades distintas => enumera TODOS los ciclos hamiltonianos => es EXACTO (optimo).
// Escala fatal (~ (N-1)! caminos), que es justo lo que el trabajo quiere observar.
// ============================================================================


// ----------------------------------------------------------------------------
// VERIFICACION DE CARGA (ejecutar despues de cargar cada cypher_load_N.cypher)
// ----------------------------------------------------------------------------
MATCH (c:City) RETURN count(c) AS ciudades;
MATCH (:City)-[r:ROAD]->(:City) RETURN count(r) AS aristas;  // debe ser N*(N-1)/2


// ============================================================================
// VERSION CON APOC (recomendada en Neo4j). Requiere el plugin APOC instalado.
// Cambia el numero de saltos *N y el "= N" del WHERE segun el tamano.
// ============================================================================

// ---- N = 4 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*4]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 4
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 6 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*6]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 6
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 8 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*8]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 8
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 10 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*10]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 10
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 12 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*12]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 12
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;

// ---- N = 14 ----
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*14]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 14
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;


// ============================================================================
// VARIANTE QUE AUTO-REPORTA EL TIEMPO (ms) DENTRO DE LA CONSULTA (con APOC)
// Util si no quieres leer el footer. Ejemplo para N=6:
// ============================================================================
WITH timestamp() AS t0
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*6]-(start)
WITH t0, nodes(path) AS ns, relationships(path) AS rs
WHERE size(apoc.coll.toSet(ns)) = 6
WITH t0, ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total, (timestamp() - t0) AS ms
ORDER BY total ASC LIMIT 1;


// ============================================================================
// VERSION SIN APOC (misma logica; sirve tambien para Memgraph).
// Para N ciudades usa [:ROAD*N] y range(0, N-1) en ambos range().
// Ejemplo para N=6: range(0,5).
// ============================================================================
MATCH (start:City {id:0})
MATCH path = (start)-[:ROAD*6]-(start)
WITH nodes(path) AS ns, relationships(path) AS rs
WHERE all(i IN range(0,5) WHERE all(j IN range(i+1,5) WHERE ns[i] <> ns[j]))
WITH ns, reduce(w = 0, r IN rs | w + r.dist) AS total
RETURN [x IN ns | x.name] AS ruta, total
ORDER BY total ASC LIMIT 1;


// ============================================================================
// QUE REPORTAR (Opciones 1 y 2)
// ----------------------------------------------------------------------------
// - Tiempo de ejecucion (footer del Browser) y ruta+costo por cada N.
// - El N en que FALLA al aumentar: OOM en Aura Free / >1 hora / error.
// - Comparacion nube (Op.1) vs local (Op.2): ¿local aguanta MAS ciudades?
//   ¿mejores/iguales/peores tiempos? Mide numeros REALES, no supongas.
// - COSTO OPTIMO esperado por N (debe coincidir con Opciones 3,4,5):
//     N=4 -> 193 | N=6 -> 276 | N=8 -> 308 | N=10 -> 330 | N=12 -> 397 | N=14 -> 448
//   Si tu Cypher da otro costo, hay error de carga del grafo.
// ============================================================================
