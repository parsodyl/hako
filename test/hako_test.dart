import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/hako.dart';
import 'package:hako/src/hako_events_contract.dart';
import 'package:hako/src/hako_state_events.dart';

void main() {
  test('something1', () {
    final hako = CounterHako();
    final stream = hako.openEventStream();
    stream.forEach(print);
    hako.count;
    hako.increment();
    hako.closeEventStream();
    expect(
      stream,
      emitsInOrder([
        ValueGetEvent<int>(0),
        ValueSetEvent<int>(0, 1),
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
