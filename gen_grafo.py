# gen_grafo.py — genera la matriz canónica y los scripts de carga por plataforma.
#
# Regla de oro del trabajo: EL MISMO GRAFO de N ciudades se usa en TODAS las opciones.
# Por eso todo parte de este único generador. El grafo de N ciudades es la submatriz
# superior izquierda N x N de una matriz canónica de 20x20 con semilla fija
# (grafos anidados: 4 ⊂ 6 ⊂ 8 ⊂ 10 ⊂ 12 ⊂ 14 ⊂ 16 ⊂ 18 ⊂ 20).
#
# Ejecutar:  python gen_grafo.py
import json
import numpy as np
from pathlib import Path

SEED = 18
MAX_N = 20
SIZES = [4, 6, 8, 10, 12, 14, 16, 18, 20]
OUT = Path(__file__).parent / "artifacts"
OUT.mkdir(exist_ok=True)

# --- Matriz simétrica de enteros, diagonal 0 ---
rng = np.random.default_rng(SEED)
A = rng.integers(10, 100, size=(MAX_N, MAX_N))
D = (A + A.T) // 2                 # simetrizar -> dist(i,j) == dist(j,i)
np.fill_diagonal(D, 0)
D = D.astype(int).tolist()

# Guardar matriz canónica completa (20x20) en JSON para referencia y depuración
(OUT / "distances.json").write_text(json.dumps({"n": MAX_N, "D": D}, indent=2))
print("Matriz 20x20 guardada en artifacts/distances.json")


def submatrix(n):
    return [row[:n] for row in D[:n]]


# --- Cypher (Neo4j y Memgraph usan el mismo formato) ---
def emit_cypher(n):
    lines = ["// Grafo completo de %d ciudades (submatriz canonica, semilla=%d)" % (n, SEED),
             "MATCH (x) DETACH DELETE x;"]
    # nodos
    creates = ", ".join(f"(c{i}:City {{id:{i}, name:'C{i}'}})" for i in range(n))
    lines.append(f"CREATE {creates};")
    # aristas i<j (grafo no dirigido: una relacion por par, se recorre no-dirigida)
    M = submatrix(n)
    for i in range(n):
        for j in range(i + 1, n):
            lines.append(
                f"MATCH (a:City {{id:{i}}}),(b:City {{id:{j}}}) "
                f"CREATE (a)-[:ROAD {{dist:{M[i][j]}}}]->(b);"
            )
    (OUT / f"cypher_load_{n}.cypher").write_text("\n".join(lines) + "\n")


# --- MongoDB: un documento con la matriz ---
def emit_mongo(n):
    M = submatrix(n)
    js = (
        "use tsp\n"
        f"db.matrix.deleteOne({{_id:'D{n}'}});\n"
        f"db.matrix.insertOne({{_id:'D{n}', n:{n}, D:{json.dumps(M)}}});\n"
    )
    (OUT / f"mongo_load_{n}.js").write_text(js)


for n in SIZES:
    emit_cypher(n)
    emit_mongo(n)
    print(f"  scripts generados para N={n}")

print("Listo. Revisa la carpeta artifacts/")
