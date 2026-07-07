use tsp
db.matrix.deleteOne({_id:'D4'});
db.matrix.insertOne({_id:'D4', n:4, D:[[0, 63, 44, 44], [63, 0, 45, 60], [44, 45, 0, 77], [44, 60, 77, 0]]});
