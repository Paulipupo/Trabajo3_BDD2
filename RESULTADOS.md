# Resultados — Trabajo 3 BD2 (TSP en 6 plataformas)

Grafo compartido: matriz simétrica canónica **14×14**, semilla `42`, grafos anidados
(4 ⊂ 6 ⊂ 8 ⊂ 10 ⊂ 12 ⊂ 14). El **mismo** grafo de N ciudades se usa en las 6 opciones.

**Costos óptimos (referencia, idénticos en las opciones 1–5):**

| N  | Costo óptimo | Ruta óptima (desde ciudad 0) |
|----|--------------|------------------------------|
| 4  | **193** | 0 → 2 → 3 → 1 → 0 |
| 6  | **276** | 0 → 5 → 1 → 3 → 2 → 4 → 0 |
| 8  | **308** | 0 → 6 → 5 → 7 → 1 → 3 → 2 → 4 → 0 |
| 10 | **330** | 0 → 9 → 6 → 2 → 3 → 1 → 7 → 5 → 8 → 4 → 0 |
| 12 | **397** | 0 → 9 → 11 → 4 → 8 → 5 → 7 → 1 → 3 → 2 → 10 → 6 → 0 |
| 14 | **448** | 0 → 9 → 11 → 13 → 4 → 8 → 5 → 7 → 1 → 12 → 2 → 3 → 10 → 6 → 0 |

> Verificación de consistencia: el Held–Karp en **Python (Opción 3)** y en **JavaScript
> (Opción 4)** produjeron exactamente estos mismos costos y rutas. Cualquier opción que
> dé un costo distinto para el mismo N tiene un error de carga del grafo.

---

## Opción 3 — Python óptimo (Held–Karp) — *ejecutado y verificado*

| N  | Costo óptimo | Tiempo (ms) |
|----|--------------|-------------|
| 4  | 193 | 0.063 |
| 6  | 276 | 0.088 |
| 8  | 308 | 0.520 |
| 10 | 330 | 5.731 |
| 12 | 397 | 17.800 |
| 14 | 448 | 93.445 |

Held–Karp es `O(2^n · n^2)`. El crecimiento del tiempo es exponencial pero llega
cómodo hasta 14–16 ciudades antes de que la memoria de `2^n·n` sea el límite.

## Opción 4 — MongoDB (Held–Karp en JavaScript) — *algoritmo verificado con Node.js*

| N  | Costo óptimo | Tiempo (ms)* |
|----|--------------|--------------|
| 4  | 193 | ~1 |
| 6  | 276 | ~0 |
| 8  | 308 | ~1 |
| 10 | 330 | ~21 |
| 12 | 397 | ~70 |
| 14 | 448 | ~46 |

\* Tiempos de una verificación con Node.js del **mismo** algoritmo (para confirmar que
los costos coinciden con la Opción 3). **Los tiempos y pantallazos oficiales debes
capturarlos ejecutando el script dentro de `mongosh`** en tu MongoDB local, con
`Date.now()`, tal como está en `opcion4_mongodb/opcion4_tsp.js`.

## Opción 6 — Python heurístico (Nearest Neighbor + 2-opt) — *ejecutado y verificado*

Calidad vs óptimo (mismo grafo canónico):

| N  | Heurístico | Óptimo | Gap    | Tiempo (ms) |
|----|-----------|--------|--------|-------------|
| 4  | 193 | 193 | 0.00% | 0.035 |
| 6  | 276 | 276 | 0.00% | 0.049 |
| 8  | 308 | 308 | 0.00% | 0.162 |
| 10 | 330 | 330 | 0.00% | 0.208 |
| 12 | 397 | 397 | 0.00% | 0.562 |
| 14 | 485 | 448 | **8.26%** | 0.940 |

Escalabilidad (N grande, ya no hay óptimo con qué comparar):

| N   | Costo heurístico | Tiempo (ms) |
|-----|------------------|-------------|
| 50  | 785 | 41.65 |
| 100 | 1255 | 389.96 |
| 200 | 2267 | 5037.38 |
| 500 | 5218 | 79213.78 |

La heurística encuentra el óptimo exacto hasta N=12 y queda a 8.26% en N=14, pero
escala a cientos de ciudades donde las opciones exactas son inviables.

---

## Opciones 1, 2 y 5 — requieren tu entorno (pendientes de ejecutar)

Estas tres se resuelven **dentro de la plataforma** (Cypher puro) y necesitan tu cuenta
/ instalación. Los scripts ya están listos:

- **Opción 1 — Neo4j Aura:** cargar `artifacts/cypher_load_N.cypher`, luego correr las
  consultas de `opcion1_2_neo4j/tsp_query.cypher` (versión con APOC). Capturar el tiempo
  del footer del Browser ("completed after X ms") + ruta + costo.
- **Opción 2 — Neo4j local:** idéntico, con Neo4j Desktop o Docker. Comparar contra Aura.
- **Opción 5 — Memgraph:** cargar el mismo `cypher_load_N.cypher`, correr
  `opcion5_memgraph/tsp_query_memgraph.cypher` (versión sin APOC). Capturar la duración
  que muestra Memgraph Lab.

Para las tres, el **costo por N debe coincidir** con la tabla de óptimos de arriba.
Anota en cada una **hasta qué N** terminó y **qué falló** después (OOM / >1 hora / error).

---

## Cuadro comparativo (rellenar tiempos reales de 1, 2 y 5)

Tiempos en **ms**. "—" = ya no viable. Los tiempos de 1, 2 y 5 los completas tú con tus
mediciones reales.

| Opción | 4 | 6 | 8 | 10 | 12 | 14 | Máx N viable | ¿Óptimo? | Observaciones |
|---|---|---|---|---|---|---|---|---|---|
| 1. Neo4j Aura (Cypher) | · | · | · | · | · | · | · | Sí | límite RAM Aura Free |
| 2. Neo4j local (Cypher) | · | · | · | · | · | · | · | Sí | comparar vs Aura |
| 3. Python (Held–Karp) | 0.063 | 0.088 | 0.520 | 5.731 | 17.80 | 93.45 | ~15–16 | Sí | exacto, medido |
| 4. MongoDB (JS) | ~1 | ~0 | ~1 | ~21 | ~70 | ~46 | ~14–16 | Sí | no es grafo; tiempos en mongosh |
| 5. Memgraph (Cypher) | · | · | · | · | · | · | · | Sí | mismo Cypher que Neo4j |
| 6. Python (heurística) | 0.035 | 0.049 | 0.162 | 0.208 | 0.562 | 0.940 | cientos | No (gap %) | escala a 500+ |

---

## Conclusiones (borrador, ajusta con tus números de 1/2/5)

- **Exactas vs heurística:** las exactas (1–5) garantizan el óptimo pero su costo crece
  factorial/exponencialmente; la heurística (6) sacrifica exactitud (gap 0% hasta N=12,
  8.26% en N=14) a cambio de escalar a cientos de ciudades.
- **Fuerza bruta en Cypher (1, 2, 5):** enumera `~(N-1)!` caminos; es la que primero se
  vuelve inviable. Se espera que Aura Free (RAM limitada) falle antes que Neo4j local, y
  que Memgraph sea comparable a Neo4j local.
- **Programación dinámica (3, 4):** Held–Karp `O(2^n·n^2)` aguanta bastante más que la
  fuerza bruta en Cypher (llega a 14–16) porque no enumera todas las permutaciones.
- **MongoDB pese a no ser grafo:** resuelve igual que Python porque el trabajo real lo
  hace el mismo algoritmo Held–Karp en JS del shell; `$graphLookup` no sirve para TSP.
- **Nube vs local (Neo4j):** completa con tus mediciones; típicamente local aguanta un
  poco más por no tener el tope de RAM del tier gratuito.
