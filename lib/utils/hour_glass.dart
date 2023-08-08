class HourGlass {
  final int _capacity;
  int _counter;

  HourGlass(grains):
    _capacity = grains,
    _counter = grains;

  int get capacity => _capacity;

  int get left => _counter;

  bool get isEmpty => _counter == 0;

  void dropGrain() {
    _counter = (_counter-1) % _capacity;
  }
}
