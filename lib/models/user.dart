class User {
  int? _id;
  String? name;

  User({int? id, this.name}): _id = id;

  int? get id => _id;

  set id(int? newId) {
    _id ??= newId;
  }
}
