// ============================================================================
// OPCIONES 1 y 2 — TSP OPTIMO en Neo4j
// ============================================================================
// Opcion 1: Neo4j Aura (nube, free tier) + Neo4j Browser.
// Opcion 2: Neo4j local (Neo4j Desktop 2) + Neo4j Browser.
// Ambas usan EXACTAMENTE estos mismos scripts. TODO en Cypher.
//
// FLUJO por cada tamano N (4,6,8,10,12,14,16,18,20):
//   1) Cargar el grafo: copia/pega artifacts/cypher_load_N.cypher en el Browser.
//   2) Verificar carga (conteos).
//   3) Ejecutar la consulta TSP correspondiente al N (cambia *N y el WHERE).
//   4) Capturar tiempo (footer "completed after X ms") + ruta + costo.
// ============================================================================

// ----------------------------------------------------------------------------
// VERIFICACION DE CARGA 
// ----------------------------------------------------------------------------
MATCH (c:City) RETURN count(c) AS ciudades;
MATCH (:City)-[r:ROAD]->(:City) RETURN count(r) AS aristas;  // debe ser N*(N-1)/2

// ============================================================================
// CONSULTA
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