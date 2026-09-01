import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';
import 'package:hako_test/src/expect_hako_emits.dart';
import 'package:meta/meta.dart';

/// Creates a new [BaseHako]-specific test case with the given [description].
///
/// {@template hako_test}
/// [hakoTest] simplifies testing [BaseHako] state containers by managing the
/// container's lifecycle, setting up event stream expectations, executing actions,
/// running post-assertion verifications, and disposing the container.
///
/// ### Example
/// ```dart
/// hakoTest<CounterHako>(
///   'emits [SetEvent(0, 1)] when increment is called',
///   build: () => CounterHako(),
///   act: (hako) => hako.increment(),
///   expect: () => [
///     const SetEvent<int>(0, 1),
///   ],
///   verify: (hako) {
///     expect(hako.count, equals(1));
///   },
/// );
/// ```
///
/// - [build]: Returns a new instance of the [BaseHako] container under test.
/// - [setUp]: An optional callback executed before [act] and before event stream
///   listeners are attached.
/// - [act]: An optional callback where actions/mutations on the container are performed.
/// - [expect]: An optional callback returning an [Iterable] of expected [HakoEvent]s
///   or matchers that should be emitted in order during [act].
/// - [verify]: An optional callback executed after [act] and [expect] have completed,
///   allowing custom assertions on the container's final state.
/// - [tearDown]: An optional callback executed after the test completes.
/// - [skip]: An optional flag or reason string to skip this test.
/// - [tags]: Optional test tags passed to [test].
/// - [retry]: Optional retry count for flakiness mitigation.
/// - [timeout]: Optional custom timeout for this test.
/// {@endtemplate}
@isTest
void hakoTest<H extends BaseHako>(
  String description, {
  required H Function() build,
  FutureOr<void> Function(H hako)? setUp,
  FutureOr<void> Function(H hako)? act,
  dynamic Function()? expect,
  FutureOr<void> Function(H hako)? verify,
  FutureOr<void> Function(H hako)? tearDown,
  dynamic skip,
  dynamic tags,
  int? retry,
  Duration? timeout,
}) {
  test(
    description,
    () async {
      final hako = build();
      try {
        await setUp?.call(hako);

        if (expect != null) {
          final dynamic expected = expect();
          final Iterable<dynamic> matchers =
              expected is Iterable ? expected : [expected];
          await expectHakoEmits<H>(
            hako,
            (h) async => await act?.call(h),
            matchers,
          );
        } else {
          await act?.call(hako);
        }

        await verify?.call(hako);
      } finally {
        try {
          await tearDown?.call(hako);
        } finally {
          hako.dispose();
        }
      }
    },
    skip: skip,
    tags: tags,
    retry: retry,
    timeout: timeout != null ? Timeout(timeout) : null,
  );
}
