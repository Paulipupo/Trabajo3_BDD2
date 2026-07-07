# Trabajo 3 — Bases de Datos 2: TSP en 6 plataformas

Solución del **Problema del Agente Viajero (TSP)** —problema NP-hard— resuelto sobre un
**grafo completo** en seis plataformas distintas, comparando tiempos, número máximo de
ciudades y punto de inviabilidad de cada una.

**Regla de oro del trabajo:** el **mismo grafo** de N ciudades se usa en TODAS las
opciones. Por eso todo parte de un único generador (`gen_grafo.py`) que produce una
matriz de distancias canónica y, a partir de ella, los scripts de carga para cada
plataforma. El grafo de N ciudades es la submatriz superior izquierda N×N de una matriz
14×14 con semilla fija (grafos anidados: 4 ⊂ 6 ⊂ 8 ⊂ 10 ⊂ 12 ⊂ 14).

## Las 6 opciones

| # | Plataforma | Lenguaje | Tipo de solución | Estado en este repo |
|---|-----------|----------|------------------|---------------------|
| 1 | Neo4j Aura (nube) | Cypher puro | Óptima (fuerza bruta) | Scripts listos — correr en tu cuenta |
| 2 | Neo4j local | Cypher puro | Óptima (fuerza bruta) | Scripts listos — correr local |
| 3 | Python (Colab) | Python | Óptima (Held–Karp) | ✅ Ejecutado y verificado |
| 4 | MongoDB local | JavaScript (mongosh) | Óptima (Held–Karp) | Script listo — algoritmo verificado con Node |
| 5 | Memgraph | Cypher puro | Óptima (fuerza bruta) | Scripts listos — correr en Docker |
| 6 | Python (Colab) | Python | Heurística (NN + 2-opt) | ✅ Ejecutado y verificado |

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
mongosh artifacts/mongo_load_6.js          # carga N=6 (repetir por tamaño)
mongosh opcion4_mongodb/opcion4_tsp.js     # resuelve (ajusta la constante N)
```

### 1 y 2 — Neo4j (Aura / local)

Cargar `artifacts/cypher_load_N.cypher` en el Neo4j Browser y correr las consultas de
`opcion1_2_neo4j/tsp_query.cypher` (versión con APOC). Docker local:

```bash
docker run --name neo4j-local -p7474:7474 -p7687:7687 \
  -e NEO4J_AUTH=neo4j/tsppassword -e NEO4J_PLUGINS='["apoc"]' neo4j:5
```

### 5 — Memgraph (Docker)

```bash
docker run -it -p 7687:7687 -p 7444:7444 -p 3000:3000 memgraph/memgraph-platform
```

Cargar el mismo `cypher_load_N.cypher` y correr `opcion5_memgraph/tsp_query_memgraph.cypher`
(versión sin APOC). Memgraph Lab: http://localhost:3000

## Resultados

Ver **[RESULTADOS.md](RESULTADOS.md)** — costos óptimos, tiempos medidos, gap de la
heurística, cuadro comparativo y conclusiones. Los costos óptimos (idénticos en las
opciones 1–5) son:

`N=4→193 · N=6→276 · N=8→308 · N=10→330 · N=12→397 · N=14→448`

## Orden de ejecución recomendado

1. `gen_grafo.py` (grafo compartido)
2. Opción 3 (óptimos de referencia)
3. Opción 6 (medir gap)
4. Opciones 1 y 2 (Neo4j)
5. Opción 5 (Memgraph)
6. Opción 4 (MongoDB)
7. Consolidar tiempos, cuadro y conclusiones

## Estructura

```
trabajo3_tsp/
├── gen_grafo.py                 # generador único del grafo compartido
├── requirements.txt
├── artifacts/                   # matriz canónica + scripts por plataforma (generados)
├── opcion1_2_neo4j/tsp_query.cypher
├── opcion3_python/opcion3_optimo.py
├── opcion4_mongodb/opcion4_tsp.js
├── opcion5_memgraph/tsp_query_memgraph.cypher
├── opcion6_python/opcion6_heuristica.py
├── informe/pantallazos/         # capturas de tiempos + soluciones
├── RESULTADOS.md
└── README.md
```

## Pendiente para la entrega

- Ejecutar opciones 1, 2, 4, 5 en tu entorno y **capturar pantallazos** de tiempo +
  solución por cada N en `informe/pantallazos/`.
- Completar los tiempos reales de 1, 2 y 5 en el cuadro comparativo de `RESULTADOS.md`.
- Redactar el informe **impreso** (portada con integrantes, una sección por opción,
  cuadro comparativo, conclusiones).
- Email a `fjmoreno@unal.edu.co` antes del **miércoles 8 de julio, 2:00 pm**.
```
