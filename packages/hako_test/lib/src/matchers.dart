import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';

/// Returns a matcher that asserts a [GetEvent] of type [T] was emitted.
///
/// - If [name] is provided, verifies that [GetEvent.name] matches [name].
/// - If [state] is provided, verifies that [GetEvent.current] matches [state].
///
/// ### Example
/// ```dart
/// await expectHakoEmits<CounterHako>(
///   counterHako,
///   (hako) => hako.count,
///   [
///     isGetEvent<int>(state: 0),
///   ],
/// );
/// ```
Matcher isGetEvent<T>({String? name, dynamic state}) {
  var matcher = isA<GetEvent<T>>();
  if (name != null) {
    matcher = matcher.having((e) => e.name, 'name', name);
  }
  if (state != null) {
    matcher = matcher.having((e) => e.current, 'state', state);
  }
  return matcher;
}

/// Returns a matcher that asserts a [SetEvent] of type [T] was emitted.
///
/// - If [name] is provided, verifies that [SetEvent.name] matches [name].
/// - If [previous] is provided, verifies that [SetEvent.previous] matches [previous].
/// - If [current] is provided, verifies that [SetEvent.current] matches [current].
///
/// ### Example
/// ```dart
/// await expectHakoEmits<CounterHako>(
///   counterHako,
///   (hako) => hako.increment(),
///   [
///     isSetEvent<int>(previous: 0, current: 1),
///   ],
/// );
/// ```
Matcher isSetEvent<T>({String? name, dynamic previous, dynamic current}) {
  var matcher = isA<SetEvent<T>>();
  if (name != null) {
    matcher = matcher.having((e) => e.name, 'name', name);
  }
  if (previous != null) {
    matcher = matcher.having((e) => e.previous, 'previous', previous);
  }
  if (current != null) {
    matcher = matcher.having((e) => e.current, 'current', current);
  }
  return matcher;
}
