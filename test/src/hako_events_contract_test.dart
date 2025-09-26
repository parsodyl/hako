import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/contracts/hako_events_contract.dart';
import 'package:hako/src/foundation/foundation.dart';

void main() {
  group(
    'HakoEvent',
    () {
      const textData = 'test data';
      test(
        'should allow creating concrete event subclasses that extend the base class',
        () {
          // Arrange & Act
          const customEvent = _TestHakoEvent(textData);

          // Assert
          expect(customEvent, isA<HakoEvent>());
          expect(customEvent.data, equals(textData));
        },
      );
      test(
        'should allow creating concrete HakoEventDelegate implementations that can receive events',
        () {
          // Arrange
          final delegate = _TestHakoEventDelegate();
          const event = _TestHakoEvent('test event data');

          // Act
          delegate.onEvent(event);

          // Assert
          expect(delegate, isA<HakoEventDelegate>());
          expect(delegate.receivedEvent, equals(event));
        },
      );
    },
  );
}

class _TestHakoEvent extends HakoEvent {
  const _TestHakoEvent(this.data);

  final String data;
}

class _TestHakoEventDelegate implements HakoEventDelegate {
  HakoEvent? receivedEvent;

  @override
  void onEvent(HakoEvent event) {
    receivedEvent = event;
  }
}
