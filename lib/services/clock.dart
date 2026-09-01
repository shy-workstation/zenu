/// Injectable wall clock so scheduling logic is testable at fixed times.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();

  int nowMs() => now().millisecondsSinceEpoch;
}
