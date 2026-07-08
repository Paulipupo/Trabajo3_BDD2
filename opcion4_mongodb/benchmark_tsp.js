// benchmark_tsp.js — OPCION 4: benchmark del TSP (Held-Karp) en MongoDB puro.
//
// Corre TODOS los tamanos cargados (N=4..20) de una sola vez, mide el tiempo de
// resolucion con Date.now() y arma la tabla final. Sin Python, sin conectores:
// 100% JavaScript dentro de mongosh.
//
// Requisito: haber cargado las matrices antes, p.ej.:
//   mongosh opcion4_mongodb/cargar_todos.js
// Ejecutar:
//   mongosh opcion4_mongodb/benchmark_tsp.js

const conn = new Mongo();
const tdb  = conn.getDB("tsp");

// --- Held-Karp: TSP optimo en O(2^n * n^2) tiempo y O(2^n * n) memoria ---
function heldKarp(D) {
  const n = D.length, FULL = (1 << n) - 1, INF = Infinity;
  const dp  = Array.from({ length: 1 << n }, () => new Array(n).fill(INF));
  const par = Array.from({ length: 1 << n }, () => new Array(n).fill(-1));
  dp[1][0] = 0;
  for (let mask = 0; mask <= FULL; mask++) {
    if (!(mask & 1)) continue;
    for (let j = 0; j < n; j++) {
      if (dp[mask][j] === INF || !((mask >> j) & 1)) continue;
      for (let k = 0; k < n; k++) {
        if ((mask >> k) & 1) continue;
        const nm = mask | (1 << k), nd = dp[mask][j] + D[j][k];
        if (nd < dp[nm][k]) { dp[nm][k] = nd; par[nm][k] = j; }
      }
    }
  }
  let best = INF, arg = -1;
  for (let j = 1; j < n; j++) {
    const v = dp[FULL][j] + D[j][0];
    if (v < best) { best = v; arg = j; }
  }
  let ruta = [], mask = FULL, j = arg;
  while (j !== -1) { ruta.push(j); const pj = par[mask][j]; mask ^= (1 << j); j = pj; }
  ruta.reverse(); ruta.push(0);
  return { costo: best, ruta: ruta };
}

const SIZES = [4, 6, 8, 10, 12, 14, 16, 18, 20];
const filas = [];

print("=== Opcion 4 — MongoDB (Held-Karp en mongosh) ===");
print("N\tcosto\ttiempo_ms\tstatus");
print("--------------------------------------------------");

for (const N of SIZES) {
  const doc = tdb.matrix.findOne({ _id: "D" + N });
  if (!doc) { print(`${N}\t-\t-\tNO CARGADO (corre cargar_todos.js)`); continue; }
  const D = doc.D;

  // Para N pequeno el tiempo es sub-milisegundo: repetimos y promediamos.
  const reps = N <= 12 ? 200 : 1;
  let res;
  try {
    const t0 = Date.now();
    for (let r = 0; r < reps; r++) res = heldKarp(D);
    const ms = (Date.now() - t0) / reps;
    print(`${N}\t${res.costo}\t${ms.toFixed(3)}\tOK  ruta=${res.ruta.join("->")}`);
    filas.push({ N, costo: res.costo, tiempo_ms: +ms.toFixed(3) });
  } catch (e) {
    // Aqui aparece el punto de inviabilidad (OOM) cuando 2^N*N ya no cabe en memoria.
    print(`${N}\t-\t-\tFALLO: ${e.message}`);
    filas.push({ N, error: e.message });
    break; // si N falla, N+2 fallara peor
  }
}

print("--------------------------------------------------");
print("Tabla (JSON) para pegar en RESULTADOS.md:");
printjson(filas);
