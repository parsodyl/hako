import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/event_stream/hako_event_stream_mixin.dart';
import 'package:hako/src/foundation/foundation.dart';

void main() {
  group(
    'HakoEventStreamMixin',
    () {
      test(
        'should initialize with the internal sink as null and isEventStreamOpen as false',
        () {
          // Arrange & Act
          final testMixin = _TestHakoEventStreamMixin();

          // Assert
          expect(testMixin.isEventStreamOpen, false);
        },
      );
      test(
        'should return a new stream when openEventStream is called for the first time',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();

          // Act
          final stream = testMixin.openEventStream();

          // Assert
          expect(stream, isA<Stream<HakoEvent>>());
          expect(testMixin.isEventStreamOpen, true);

          // Clean up
          testMixin.closeEventStream();
        },
      );
      test(
        'should return the same stream when openEventStream is called multiple times',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();

          // Act
          final stream1 = testMixin.openEventStream();
          final stream2 = testMixin.openEventStream();

          // Assert
          expect(stream1, same(stream2));
          expect(testMixin.isEventStreamOpen, true);

          // Clean up
          testMixin.closeEventStream();
        },
      );
      test(
        'should return a broadcast stream that allows multiple listeners',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          final stream = testMixin.openEventStream();

          // Act
          final subscription1 = stream.listen((_) {});
          final subscription2 = stream.listen((_) {});

          // Assert
          expect(stream.isBroadcast, true);
          expect(subscription1, isA<StreamSubscription<HakoEvent>>());
          expect(subscription2, isA<StreamSubscription<HakoEvent>>());

          // Clean up
          subscription1.cancel();
          subscription2.cancel();
          testMixin.closeEventStream();
        },
      );
      test(
        'should add events to the stream when onEvent is called with an open stream',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          final stream = testMixin.openEventStream();

          const testEvent1 = _TestHakoEvent('event1');
          const testEvent2 = _TestHakoEvent('event2');

          // Act
          testMixin.onEvent(testEvent1);
          testMixin.onEvent(testEvent2);

          // Assert
          expect(
            stream,
            emitsInOrder([
              testEvent1,
              testEvent2,
              emitsDone,
            ]),
          );

          // Clean up
          testMixin.closeEventStream();
        },
      );
      test(
        'should deliver events to multiple subscriptions on the same broadcast stream',
        () async {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          final stream = testMixin.openEventStream();

          const testEvent1 = _TestHakoEvent('event1');
          const testEvent2 = _TestHakoEvent('event2');

          final receivedEvents1 = <HakoEvent>[];
          final receivedEvents2 = <HakoEvent>[];

          // Act
          final subscription1 =
              stream.listen((event) => receivedEvents1.add(event));
          final subscription2 =
              stream.listen((event) => receivedEvents2.add(event));

          testMixin.onEvent(testEvent1);
          testMixin.onEvent(testEvent2);

          // Allow events to be processed
          await Future.delayed(Duration.zero);

          // Assert
          expect(receivedEvents1, equals([testEvent1, testEvent2]));
          expect(receivedEvents2, equals([testEvent1, testEvent2]));
          expect(receivedEvents1, equals(receivedEvents2));

          // Clean up
          subscription1.cancel();
          subscription2.cancel();
          testMixin.closeEventStream();
        },
      );
      test(
        'should ignore events when onEvent is called with no open stream',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          const testEvent = _TestHakoEvent('ignored event');

          // Act & Assert - should not throw any errors
          expect(() => testMixin.onEvent(testEvent), returnsNormally);
          expect(testMixin.isEventStreamOpen, false);
        },
      );
      test(
        'should close the sink and set isEventStreamOpen to false when closeEventStream is called',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          final stream = testMixin.openEventStream();

          // Verify initial state
          expect(testMixin.isEventStreamOpen, true);

          // Act
          testMixin.closeEventStream();

          // Assert
          expect(testMixin.isEventStreamOpen, false);
          expect(stream, emitsDone);
        },
      );
      test(
        'should allow reopening event stream after closing it',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();

          // Act - open stream for the first time
          final stream1 = testMixin.openEventStream();
          expect(testMixin.isEventStreamOpen, true);

          // Close the stream
          testMixin.closeEventStream();
          expect(testMixin.isEventStreamOpen, false);

          // Reopen the stream
          final stream2 = testMixin.openEventStream();

          // Assert
          expect(testMixin.isEventStreamOpen, true);
          expect(stream2, isA<Stream<HakoEvent>>());
          expect(stream2, isNot(same(stream1)));

          // Verify new stream works with events
          const testEvent = _TestHakoEvent('reopened stream event');
          testMixin.onEvent(testEvent);

          expect(stream2, emits(testEvent));

          // Clean up
          testMixin.closeEventStream();
        },
      );
      test(
        'should handle calling closeEventStream when no stream has been opened',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();

          // Act & Assert - should not throw any errors
          expect(() => testMixin.closeEventStream(), returnsNormally);
          expect(testMixin.isEventStreamOpen, false);
        },
      );
      test(
        'should handle calling closeEventStream multiple times consecutively',
        () {
          // Arrange
          final testMixin = _TestHakoEventStreamMixin();
          final stream = testMixin.openEventStream();

          // Verify initial state
          expect(testMixin.isEventStreamOpen, true);

          // Act - call closeEventStream multiple times
          testMixin.closeEventStream();
          testMixin.closeEventStream();
          testMixin.closeEventStream();

          // Assert
          expect(testMixin.isEventStreamOpen, false);
          expect(stream, emitsDone);
        },
      );
    },
  );
}

class _TestHakoEventStreamMixin with HakoEventStreamMixin {}

class _TestHakoEvent extends HakoEvent {
  const _TestHakoEvent(this.data);

  final String data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestHakoEvent &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}
