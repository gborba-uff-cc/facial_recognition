import 'dart:io';

/*
call testBody, call postTest after it, show and return whether testBody succeded
*/
bool test(
  final String testName,
  final bool Function() testBody,
  {
    final void Function()? preTest,
    final void Function()? postTest
  }
) {
  if (preTest != null) {
    preTest();
  }
  bool succeded = false;
  try {
    succeded = testBody();
  } catch (e) {
    stdout.writeln('${'='*15}\n$e\n${'-'*15}');
    succeded = false;
  }
  finally {
    String logMessage = '$testName... ';
    if (succeded) {
      logMessage += 'OK';
    }
    else {
      logMessage += 'FAIL';
    }
    stdout.writeln(logMessage);
  }
  if (postTest != null) {
    postTest();
  }
  return succeded;
}

void showTestssucceded(bool allTestsSucceded) {
  String message = 'all tests succeded?';
  stdout.writeln('');
  stdout.writeln('-'*(message.length+5));
  if (allTestsSucceded) {
    stdout.writeln('$message Yes');
    exitCode = 0;
  }
  else {
    stdout.writeln('$message No');
    exitCode = 1;
  }
  stdout.writeln('='*(message.length+5));
}

bool equalMaps<K extends Comparable, V>(final Map<K,V> m1, final Map<K,V> m2) {
  if (m1.length != m2.length) {
    return false;
  }
  for (final key in m1.keys) {
    if (!m2.containsKey(key) || m2[key] != m1[key]) {
      return false;
    }
  }
  return true;
}
