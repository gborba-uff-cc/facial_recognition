/// return a string in the form 'dd/mm/yyyy hh:mm'
String dateTimeToString(DateTime dt) {
  final String year = switch (dt.year) {
    < 10 => '000${dt.year}',
    < 100 => '00${dt.year}',
    < 1000 => '0${dt.year}',
    _ => '${dt.year}'
  };
  final String month = switch (dt.month) {
    < 10 => '0${dt.month}',
    _ => '${dt.month}'
  };
  final String day = switch (dt.day) {
    < 10 => '0${dt.day}',
    _ => '${dt.day}'
  };
  final String hour = switch (dt.hour) {
    < 10 => '0${dt.hour}',
    _ => '${dt.hour}'
  };
  final String minute = switch (dt.minute) {
    < 10 => '0${dt.minute}',
    _ => '${dt.minute}'
  };
  return '$day/$month/$year $hour:$minute';
}

/// return a string in the form 'yyyymmddhhmmss'
String dateTimeToString2(DateTime dt) {
    final String year = switch (dt.year) {
    < 10 => '000${dt.year}',
    < 100 => '00${dt.year}',
    < 1000 => '0${dt.year}',
    _ => '${dt.year}'
  };
  final String month = switch (dt.month) {
    < 10 => '0${dt.month}',
    _ => '${dt.month}'
  };
  final String day = switch (dt.day) {
    < 10 => '0${dt.day}',
    _ => '${dt.day}'
  };
  final String hour = switch (dt.hour) {
    < 10 => '0${dt.hour}',
    _ => '${dt.hour}'
  };
  final String minute = switch (dt.minute) {
    < 10 => '0${dt.minute}',
    _ => '${dt.minute}'
  };
  final String seconds = switch (dt.second) {
    < 10 => '0${dt.second}',
    _ => '${dt.second}'
  };
  return '$year$month$day$hour$minute$seconds';
}