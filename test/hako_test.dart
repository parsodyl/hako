import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';

void main() {
  test('text example using event stream', () {
    final hako = CounterHako();
    final stream = hako.openEventStream();
    expect(hako.count, isZero);
    hako.increment();
    expect(hako.count, equals(1));
    hako.closeEventStream();
    expect(
      stream,
      emitsInOrder([
        const ValueGetEvent<int>(0),
        const ValueSetEvent<int>(0, 1),
        const ValueGetEvent<int>(1),
        emitsDone,
      ]),
    );
  });
}

class CounterHako extends Hako {
  CounterHako({int initialValue = 0})
      : super((register) {
          register<int>(initialValue);
        });

  int get count => get<int>();

  void increment() => set<int>((current) => current + 1);
}
