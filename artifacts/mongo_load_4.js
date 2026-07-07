use tsp
db.matrix.deleteOne({_id:'D4'});
db.matrix.insertOne({_id:'D4', n:4, D:[[0, 76, 63, 61], [76, 0, 52, 31], [63, 52, 0, 23], [61, 31, 23, 0]]});
