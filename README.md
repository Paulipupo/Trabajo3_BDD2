# Trabajo 3 — Bases de Datos 2: TSP en 6 opciones

Solución del **Problema del Agente Viajero (TSP)** —problema NP-hard— resuelto sobre un
**grafo completo** en seis opciones distintas, comparando tiempos y número máximo de
ciudades.

## Las 6 opciones

| # | Plataforma | Lenguaje | Tipo de solución | Estado en este repo |
|---|-----------|----------|------------------|---------------------|
| 1 | Neo4j Aura (nube) | Cypher puro | Óptima (fuerza bruta) | Scripts listos|
| 2 | Neo4j local | Cypher puro | Óptima (fuerza bruta) | Scripts listos |
| 3 | Python (Colab) | Python | Óptima (Held–Karp) |Ejecutado y verificado |
| 4 | MongoDB local | JavaScript (mongosh) | Óptima (Held–Karp) | Script listo|
| 5 | Memgraph | Cypher puro | Óptima (fuerza bruta) | Scripts listos — correr en Docker |
| 6 | Python (Colab) | Python | Heurística (NN + 2-opt) |Ejecutado y verificado |

> Cada plataforma se usa "pura": en Neo4j / Memgraph / MongoDB **no** se conecta desde
> Python; todo se resuelve dentro de la plataforma (Cypher / JavaScript de mongosh).

## Cómo usar este repo

### 0. Generar el grafo compartido (obligatorio primero)

```bash
pip install -r requirements.txt
python gen_grafo.py
```

Esto crea en `artifacts/`:
- `distances.json` — matriz canónica 14×14 (la leen Python y MongoDB).
- `cypher_load_{4..14}.cypher` — carga para Neo4j **y** Memgraph.
- `mongo_load_{4..14}.js` — carga para MongoDB.

### 3 y 6 — Python (ejecutables aquí mismo o en Colab)

```bash
python opcion3_python/opcion3_optimo.py      # óptimos de referencia -> artifacts/optimos.json
python opcion6_python/opcion6_heuristica.py  # gap vs óptimo + escalabilidad
```

### 4 — MongoDB (local)

```bash
  mongosh opcion4_mongodb/cargar_todos.js 
  mongosh opcion4_mongodb/benchmark_tsp.js 
```

### 1 y 2 — Neo4j (Aura / local)

Cargar `artifacts/cypher_load_N.cypher` en el Neo4j Browser y correr las consultas de
`opcion1_2_neo4j/tsp_query.cypher`


### 5 — Memgraph (Docker)

```bash
docker run -it -p 7687:7687 -p 7444:7444 -p 3000:3000 memgraph/memgraph-platform
```

Cargar el mismo `cypher_load_N.cypher` y correr `opcion5_memgraph/tsp_query_memgraph.cypher`
Memgraph Lab: http://localhost:3000


