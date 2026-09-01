import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';
import 'package:hako_test/hako_test.dart';

class _TestCounterHako extends Hako {
  _TestCounterHako({int initialValue = 0})
      : super((register) {
          register<int>(initialValue);
          register<String>('initial', name: 'label');
        });

  int get count => get<int>();
  String get label => get<String>(name: 'label');

  void increment() => set<int>((current) => current + 1);
  void setLabel(String value) => set<String>((_) => value, name: 'label');

  Future<void> asyncIncrement() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    increment();
  }
}

void main() {
  group('expectHakoEmits', () {
    test('verifies synchronous state changes emitting SetEvent in order', () async {
      final hako = _TestCounterHako();

      await expectHakoEmits<_TestCounterHako>(
        hako,
        (h) => h.increment(),
        [
          const SetEvent<int>(0, 1),
        ],
      );

      expect(hako.isEventStreamOpen, isFalse);
      expect(hako.count, equals(1));
    });

    test('verifies multiple synchronous events including GetEvent and SetEvent', () async {
      final hako = _TestCounterHako();

      await expectHakoEmits<_TestCounterHako>(
        hako,
        (h) {
          h.get<int>();
          h.increment();
          h.setLabel('updated');
        },
        [
          const GetEvent<int>(0),
          const SetEvent<int>(0, 1),
          const SetEvent<String>('initial', 'updated', name: 'label'),
        ],
      );

      expect(hako.isEventStreamOpen, isFalse);
    });

    test('verifies asynchronous state execution', () async {
      final hako = _TestCounterHako();

      await expectHakoEmits<_TestCounterHako>(
        hako,
        (h) => h.asyncIncrement(),
        [
          const SetEvent<int>(0, 1),
        ],
      );

      expect(hako.isEventStreamOpen, isFalse);
      expect(hako.count, equals(1));
    });

    test('verifies custom matchers (e.g. isA)', () async {
      final hako = _TestCounterHako();

      await expectHakoEmits<_TestCounterHako>(
        hako,
        (h) => h.increment(),
        [
          isA<SetEvent<int>>()
              .having((e) => e.previous, 'previous', 0)
              .having((e) => e.current, 'current', 1),
        ],
      );

      expect(hako.isEventStreamOpen, isFalse);
    });

    test('verifies empty matchers list when no events are emitted', () async {
      final hako = _TestCounterHako();

      await expectHakoEmits<_TestCounterHako>(
        hako,
        (h) {
          // No actions performed
        },
        [],
      );

      expect(hako.isEventStreamOpen, isFalse);
    });

    test('ensures stream is closed even when execution callback throws', () async {
      final hako = _TestCounterHako();

      await expectLater(
        () => expectHakoEmits<_TestCounterHako>(
          hako,
          (h) {
            h.increment();
            throw StateError('Simulated error');
          },
          [
            const SetEvent<int>(0, 1),
          ],
        ),
        throwsA(isA<StateError>()),
      );

      expect(hako.isEventStreamOpen, isFalse);
    });
  });
}
