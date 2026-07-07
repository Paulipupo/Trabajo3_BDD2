# opcion6_heuristica.py — OPCION 6: TSP HEURISTICO en Python puro (Google Colab).
#
# Todo en Python. Heuristica escalable (NO garantiza optimo): Nearest Neighbor + 2-opt.
# Se compara con el optimo de la Opcion 3 y se reporta que tan cerca quedo (gap %).
# Debe soportar MUCHAS mas ciudades que las opciones exactas.
import json
import time
import random
from pathlib import Path

RUTA_RAIZ = Path(".")

try:
    DATA = json.load(open(RUTA_RAIZ / "distances.json"))["D"]
except FileNotFoundError:
    print("ERROR: No hay 'distances.json' subido")
    raise

# Óptimos de referencia calculados por la Opción 3 (Held-Karp)
try:
    OPTIMOS = {int(k): v["costo"] for k, v in json.load(open(RUTA_RAIZ / "optimos.json")).items()}
except FileNotFoundError:
    OPTIMOS = {}
    print("AVISO: No se encontró 'optimos.json' en colab")


def sub(n):
    return [row[:n] for row in DATA[:n]]


def largo(ruta, D):
    return sum(D[ruta[i]][ruta[(i + 1) % len(ruta)]] for i in range(len(ruta)))


def nearest_neighbor(D, start=0):
    n = len(D)
    vis = {start}
    ruta = [start]
    cur = start
    while len(ruta) < n:
        nxt = min((j for j in range(n) if j not in vis), key=lambda j: D[cur][j])
        ruta.append(nxt)
        vis.add(nxt)
        cur = nxt
    return ruta


def two_opt(ruta, D):
    mejor = ruta[:]
    mejora = True
    while mejora:
        mejora = False
        for i in range(1, len(mejor) - 1):
            for j in range(i + 1, len(mejor)):
                if j - i == 1:
                    continue
                cand = mejor[:i] + mejor[i:j][::-1] + mejor[j:]
                if largo(cand, D) < largo(mejor, D):
                    mejor = cand
                    mejora = True
    return mejor


def matriz_aleatoria(n, seed=123):
    """Matriz simétrica NxN para demostrar escalabilidad (N grande sin óptimo conocido)."""
    rng = random.Random(seed)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            d = rng.randint(10, 99)
            M[i][j] = M[j][i] = d
    return M


# En Colab podemos ejecutar el bloque directamente
if __name__ == "__main__":
    # --- Parte 1: gap vs optimo (mismos grafos 4..14) ---
    print("== Calidad de la heurística vs óptimo (mismo grafo canónico) ==")
    print(f"{'N':>3}  {'heurístico':>10}  {'óptimo':>7}  {'gap':>7}  {'tiempo_ms':>10}")
    print("-" * 50)
    for n in [4, 6, 8, 10, 12, 14, 16, 18, 20]:
        D = sub(n)
        t0 = time.perf_counter()
        ruta = two_opt(nearest_neighbor(D), D)
        ms = (time.perf_counter() - t0) * 1000
        costo = largo(ruta, D)
        opt = OPTIMOS.get(n)
        gap = f"{100 * (costo - opt) / opt:5.2f}%" if opt else "  n/d"
        print(f"{n:>3}  {costo:>10}  {str(opt):>7}  {gap:>7}  {ms:>10.3f}")

    # --- Parte 2: escalabilidad ---
    print("\n== Escalabilidad: N grande, solo tiempo + costo heurístico ==")
    print(f"{'N':>4}  {'costo_heur':>10}  {'tiempo_ms':>10}")
    print("-" * 32)
    for n in [50, 100, 200, 500]:
        D = matriz_aleatoria(n)
        t0 = time.perf_counter()
        ruta = two_opt(nearest_neighbor(D), D)
        ms = (time.perf_counter() - t0) * 1000
        print(f"{n:>4}  {largo(ruta, D):>10}  {ms:>10.2f}")