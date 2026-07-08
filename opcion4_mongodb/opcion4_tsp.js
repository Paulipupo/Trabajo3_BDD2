// opcion4_tsp.js — OPCION 4: TSP en MongoDB (JavaScript puro dentro de mongosh).
//
// Todo en MongoDB. MongoDB NO es una base de datos de grafos, pero se puede resolver:
// se guarda la matriz en una coleccion (ver artifacts/mongo_load_N.js) y se resuelve
// con JavaScript dentro de mongosh (Held-Karp en JS). No se usa Python ni Neo4j.
//
// Ejecutar (tras cargar el grafo del tamano deseado):
//   mongosh artifacts/mongo_load_6.js        // carga N=6
//   mongosh opcion4_mongodb/opcion4_tsp.js   // resuelve N=6 (cambia la constante N)
//
// $graphLookup de MongoDB NO resuelve TSP (no explora ciclos hamiltonianos de costo
// minimo). El camino correcto y honesto para "todo en MongoDB" es JS en el shell.

const N = 4;                                   // <- cambia por 4,6,8,10,12,14
const conn = new Mongo();
const db = conn.getDB("tsp");
const doc = db.matrix.findOne({ _id: "D" + N });
if (!doc) {
  print("ERROR: no existe el documento D" + N + ". Carga primero mongo_load_" + N + ".js");
  quit(1);
}
const D = doc.D, n = doc.n;

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

const t0 = Date.now();
const res = heldKarp(D);
const ms = Date.now() - t0;
print(`N=${n}  costo_optimo=${res.costo}  tiempo=${ms} ms  ruta=${res.ruta}`);
