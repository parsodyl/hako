import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';
import 'package:hako_test/hako_test.dart';

class _CounterHako extends Hako {
  _CounterHako({int initialValue = 0})
      : super((register) {
          register<int>(initialValue);
          register<String>('initial', name: 'tag');
        });

  int get count => get<int>();
  String get tag => get<String>(name: 'tag');

  void increment() => set<int>((current) => current + 1);
  void setTag(String value) => set<String>((_) => value, name: 'tag');

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

void main() {
  group('hakoTest', () {
    hakoTest<_CounterHako>(
      'runs act and verifies emitted SetEvents with expect',
      build: () => _CounterHako(),
      act: (hako) => hako.increment(),
      expect: () => [
        const SetEvent<int>(0, 1),
      ],
      verify: (hako) {
        expect(hako.count, equals(1));
      },
    );

    hakoTest<_CounterHako>(
      'supports setUp before act is executed',
      build: () => _CounterHako(),
      setUp: (hako) {
        hako.increment(); // count is now 1, but this is not in expect
      },
      act: (hako) => hako.increment(),
      expect: () => [
        const SetEvent<int>(1, 2),
      ],
      verify: (hako) {
        expect(hako.count, equals(2));
      },
    );

    hakoTest<_CounterHako>(
      'supports multiple operations in act with multiple events',
      build: () => _CounterHako(),
      act: (hako) {
        hako.increment();
        hako.setTag('updated');
      },
      expect: () => [
        const SetEvent<int>(0, 1),
        const SetEvent<String>('initial', 'updated', name: 'tag'),
      ],
      verify: (hako) {
        expect(hako.count, equals(1));
        expect(hako.tag, equals('updated'));
      },
    );

    hakoTest<_CounterHako>(
      'runs without expect when only verify is needed',
      build: () => _CounterHako(),
      act: (hako) => hako.increment(),
      verify: (hako) {
        expect(hako.count, equals(1));
      },
    );

    test('disposes hako instance after test completion', () async {
      _CounterHako? capturedHako;

      // We run a test inside and verify tearDown/dispose
      final hako = _CounterHako();
      capturedHako = hako;
      expect(capturedHako.isDisposed, isFalse);

      hako.dispose();
      expect(capturedHako.isDisposed, isTrue);
    });
  });
}
