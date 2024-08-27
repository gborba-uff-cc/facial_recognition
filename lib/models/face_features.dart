class FaceFeatures {
  int? _id;
  int? userId;
  List<int>? data;

  FaceFeatures({int? id, this.userId, this.data}): _id = id;

  int? get id => _id;

  set id(int? newId) {
    _id ??= newId;
  }
}
