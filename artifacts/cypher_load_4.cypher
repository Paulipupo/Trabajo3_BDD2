// Grafo completo de 4 ciudades (submatriz canonica, semilla=18)
MATCH (x) DETACH DELETE x;
CREATE (c0:City {id:0, name:'C0'}), (c1:City {id:1, name:'C1'}), (c2:City {id:2, name:'C2'}), (c3:City {id:3, name:'C3'});
MATCH (a:City {id:0}),(b:City {id:1}) CREATE (a)-[:ROAD {dist:63}]->(b);
MATCH (a:City {id:0}),(b:City {id:2}) CREATE (a)-[:ROAD {dist:44}]->(b);
MATCH (a:City {id:0}),(b:City {id:3}) CREATE (a)-[:ROAD {dist:44}]->(b);
MATCH (a:City {id:1}),(b:City {id:2}) CREATE (a)-[:ROAD {dist:45}]->(b);
MATCH (a:City {id:1}),(b:City {id:3}) CREATE (a)-[:ROAD {dist:60}]->(b);
MATCH (a:City {id:2}),(b:City {id:3}) CREATE (a)-[:ROAD {dist:77}]->(b);
