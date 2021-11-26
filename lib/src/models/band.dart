class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

// Y Regresa una nueva instancia de mi banda o clase
// Es un constructor que recibe cierto tipo de argumento
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
