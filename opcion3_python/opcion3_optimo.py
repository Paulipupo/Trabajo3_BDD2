# opcion3_optimo.py — OPCION 3: TSP OPTIMO en Python puro (Google Colab).
#
# Todo en Python. No se toca Neo4j ni MongoDB. Se lee la MISMA matriz canonica
# (artifacts/distances.json) y se resuelve el optimo con programacion dinamica de
# Held-Karp: O(2^n * n^2). Llega comodo a 14-16 ciudades. Se mide el tiempo.
#
# Estos optimos son la REFERENCIA para validar las opciones 1,2,4,5 y para medir
# el gap de la opcion 6.
import json
import time
import math
from pathlib import Path

ART = Path(__file__).resolve().parent.parent / "artifacts" / "distances.json"
DATA = json.load(open(ART))["D"]


def sub(n):
    return [row[:n] for row in DATA[:n]]


def held_karp(D):
    """TSP exacto. Devuelve (costo_optimo, ruta) empezando y terminando en 0."""
    n = len(D)
    FULL = (1 << n) - 1
    INF = math.inf
    dp = [[INF] * n for _ in range(1 << n)]
    par = [[-1] * n for _ in range(1 << n)]
    dp[1][0] = 0                                   # solo el nodo 0 visitado, en 0
    for mask in range(1 << n):
        if not (mask & 1):
            continue                               # 0 siempre incluido
        for j in range(n):
            if dp[mask][j] == INF or not (mask >> j) & 1:
                continue
            for k in range(n):
                if (mask >> k) & 1:
                    continue                       # k no visitado aun
                nm = mask | (1 << k)
                nd = dp[mask][j] + D[j][k]
                if nd < dp[nm][k]:
                    dp[nm][k] = nd
                    par[nm][k] = j
    best, arg = INF, -1
    for j in range(1, n):
        v = dp[FULL][j] + D[j][0]
        if v < best:
            best, arg = v, j
    ruta, mask, j = [], FULL, arg                   # reconstruccion
    while j != -1:
        ruta.append(j)
        pj = par[mask][j]
        mask ^= (1 << j)
        j = pj
    ruta.reverse()
    ruta.append(0)
    return best, ruta


if __name__ == "__main__":
    resultados = {}
    print(f"{'N':>3}  {'costo_optimo':>12}  {'tiempo_ms':>12}  ruta")
    print("-" * 70)
    for n in [4, 6, 8, 10, 12, 14]:
        D = sub(n)
        t0 = time.perf_counter()
        costo, ruta = held_karp(D)
        ms = (time.perf_counter() - t0) * 1000
        resultados[n] = {"costo": costo, "tiempo_ms": round(ms, 3), "ruta": ruta}
        print(f"{n:>3}  {costo:>12}  {ms:>12.3f}  {ruta}")

    # Persistir los optimos para que la opcion 6 los use como referencia
    out = Path(__file__).resolve().parent.parent / "artifacts" / "optimos.json"
    out.write_text(json.dumps(resultados, indent=2))
    print(f"\nOptimos guardados en {out}")
