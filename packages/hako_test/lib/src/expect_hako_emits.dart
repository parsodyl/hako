import 'dart:async';

import 'package:flutter_test/flutter_test.dart'
    show emitsDone, emitsInOrder, expectLater;
import 'package:hako/hako.dart';

/// Asserts that executing [execution] on a [hako] instance emits a sequence
/// of [HakoEvent]s matching [matchers] in order, followed by stream completion.
///
/// {@template expect_hako_emits}
/// This testing utility streamlines verifying reactive state changes and event
/// streams emitted by any [BaseHako] state container:
///
/// 1. Opens the event stream on [hako] via [BaseHako.openEventStream].
/// 2. Sets up an expectation with [expectLater] waiting for [matchers] in order,
///    ending with [emitsDone].
/// 3. Executes the [execution] callback (synchronous or asynchronous).
/// 4. Ensures [BaseHako.closeEventStream] is always called inside a `finally`
///    block to properly clean up the stream controller even if [execution] throws.
/// 5. Awaits and returns the expectation future.
///
/// ### Example
/// ```dart
/// test('counter increments state and emits SetEvent', () async {
///   final counterHako = CounterHako();
///
///   await expectHakoEmits<CounterHako>(
///     counterHako,
///     (hako) => hako.increment(),
///     [
///       const SetEvent<int>(0, 1),
///     ],
///   );
/// });
/// ```
///
/// Passing an empty [matchers] collection asserts that no events are emitted
/// before the stream completes.
///
/// - [hako]: The [BaseHako] instance under test.
/// - [execution]: An action (synchronous or asynchronous callback) performed on
///   the [hako] instance that is expected to trigger state changes or events.
/// - [matchers]: An ordered collection of expected [HakoEvent] instances or
///   test matchers (e.g. `isA<SetEvent<int>>()`).
/// - [reason]: An optional failure reason message if the expectation fails.
/// - [skip]: An optional flag ([bool] or [String] explanation) to skip this
///   expectation.
/// {@endtemplate}
Future<void> expectHakoEmits<T extends BaseHako>(
  T hako,
  FutureOr<void> Function(T hako) execution,
  Iterable<dynamic> matchers, {
  String? reason,
  dynamic skip,
}) async {
  final stream = hako.openEventStream();
  final expectation = expectLater(
    stream,
    emitsInOrder([...matchers, emitsDone]),
    reason: reason,
    skip: skip,
  );
  try {
    await execution(hako);
  } finally {
    hako.closeEventStream();
  }
  return await expectation;
}
