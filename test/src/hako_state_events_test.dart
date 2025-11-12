import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/event_stream/hako_state_events.dart';

void main() {
  group(
    'HakoStateEvent',
    () {
      test(
        'should create a HakoStateEvent with a null state (dynamic type) value and no name',
        () {
          // Arrange & Act
          const state = null;
          const event = _TestHakoStateEvent(state);

          // Assert
          expect(event.state, isNull);
          expect(event.name, isNull);
          expect(event.key, equals((dynamic, null)));
        },
      );
      test(
        'should create a HakoStateEvent with a null state (nullable type) value and no name',
        () {
          // Arrange & Act
          const state = null;
          const event = _TestHakoStateEvent<Set<String>?>(state);
          Type type<T>() => T; // this is needed to get the nullable type

          // Assert
          expect(event.state, isNull);
          expect(event.name, isNull);
          expect(event.key, equals((type<Set<String>?>(), null)));
        },
      );
      test(
        'should create a HakoStateEvent with a non-null state value and no name',
        () {
          // Arrange & Act
          const state = {'test_value'};
          const event = _TestHakoStateEvent<Set<String>>(state);

          // Assert
          expect(event.state, equals(state));
          expect(event.name, isNull);
          expect(event.key, equals((Set<String>, null)));
        },
      );
      test(
        'should create a HakoStateEvent with a non-null state value and a non-null name',
        () {
          // Arrange & Act
          const state = {'test_value'};
          const name = 'test_name';
          const event = _TestHakoStateEvent<Set<String>>(state, name: name);

          // Assert
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Set<String>, name)));
        },
      );
    },
  );
  group(
    'GetEvent',
    () {
      test(
        'should be a HakoStateEvent',
        () {
          // Arrange & Act
          const state = {'test_value'};
          const name = 'test_name';
          const event = GetEvent<Set<String>?>(state, name: name);

          // Assert
          expect(event, isA<HakoStateEvent<Set<String>?>>());
        },
      );
      test(
        'should create GetEvent with complex object state and verify toString format',
        () {
          // Arrange
          final state = {'key1': 'value1', 'key2': 'value2'};
          const name = 'complex_state';

          // Act
          final event = GetEvent<Map<String, String>>(state, name: name);

          // Assert
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Map<String, String>, name)));
          expect(
            event.toString(),
            equals(
              'GetEvent{key: (Map<String, String>, complex_state), state: {key1: value1, key2: value2}}',
            ),
          );
        },
      );
      test(
        'should verify two GetEvent instances with same state and key are equal',
        () {
          // Arrange
          const state = {'test_value'};
          const name = 'test_name';
          const event1 = GetEvent<Set<String>>(state, name: name);
          const event2 = GetEvent<Set<String>>(state, name: name);

          // Act & Assert
          expect(event1, equals(event2));
          expect(event1.hashCode, equals(event2.hashCode));
        },
      );
      test(
        'should verify two GetEvent instances with different states are not equal',
        () {
          // Arrange
          const state1 = 'first_value';
          const state2 = 'second_value';
          const name = 'test_name';
          const event1 = GetEvent<String>(state1, name: name);
          const event2 = GetEvent<String>(state2, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two GetEvent instances with same state, same name and different types are not equal',
        () {
          // Arrange
          const state = 0;
          const name = 'test_name';
          const event1 = GetEvent<num>(state, name: name);
          const event2 = GetEvent<int>(state, name: name);

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
      test(
        'should verify two GetEvent instances with same state, same type and different names are not equal',
        () {
          // Arrange
          const state = 'test_value';
          const event1 = GetEvent<String>(state, name: 'first');
          const event2 = GetEvent<String>(state, name: 'second');

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
    },
  );
  group(
    'SetEvent',
    () {
      test(
        'should be a HakoStateEvent',
        () {
          // Arrange & Act
          const previous = {'old_value'};
          const state = {'new_value'};
          const name = 'test_name';
          const event = SetEvent<Set<String>?>(previous, state, name: name);

          // Assert
          expect(event, isA<HakoStateEvent<Set<String>?>>());
        },
      );
      test(
        'should create SetEvent with complex object state and verify toString format',
        () {
          // Arrange
          final previous = {'key1': 'old_value1', 'key2': 'old_value2'};
          final state = {'key1': 'new_value1', 'key2': 'new_value2'};
          const name = 'complex_state';

          // Act
          final event =
              SetEvent<Map<String, String>>(previous, state, name: name);

          // Assert
          expect(event.previous, equals(previous));
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Map<String, String>, name)));
          expect(
            event.toString(),
            equals(
              'SetEvent{key: (Map<String, String>, complex_state), previous: {key1: old_value1, key2: old_value2}, state: {key1: new_value1, key2: new_value2}}',
            ),
          );
        },
      );
      test(
        'should verify two SetEvent instances with same previous, state and key are equal',
        () {
          // Arrange
          const previous = {'old_value'};
          const state = {'new_value'};
          const name = 'test_name';
          const event1 = SetEvent<Set<String>>(previous, state, name: name);
          const event2 = SetEvent<Set<String>>(previous, state, name: name);

          // Act & Assert
          expect(event1, equals(event2));
          expect(event1.hashCode, equals(event2.hashCode));
        },
      );
      test(
        'should verify two SetEvent instances with different previous values are not equal',
        () {
          // Arrange
          const previous1 = 'old_value1';
          const previous2 = 'old_value2';
          const state = 'new_value';
          const name = 'test_name';
          const event1 = SetEvent<String>(previous1, state, name: name);
          const event2 = SetEvent<String>(previous2, state, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two SetEvent instances with different states are not equal',
        () {
          // Arrange
          const previous = 'old_value';
          const state1 = 'new_value1';
          const state2 = 'new_value2';
          const name = 'test_name';
          const event1 = SetEvent<String>(previous, state1, name: name);
          const event2 = SetEvent<String>(previous, state2, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two SetEvent instances with same previous, same state, same name and different types are not equal',
        () {
          // Arrange
          const previous = 0;
          const state = 1;
          const name = 'test_name';
          const event1 = SetEvent<num>(previous, state, name: name);
          const event2 = SetEvent<int>(previous, state, name: name);

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
      test(
        'should verify two SetEvent instances with same previous, same state, same type and different names are not equal',
        () {
          // Arrange
          const previous = 'old_value';
          const state = 'new_value';
          const event1 = SetEvent<String>(previous, state, name: 'first');
          const event2 = SetEvent<String>(previous, state, name: 'second');

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
    },
  );
}

class _TestHakoStateEvent<T> extends HakoStateEvent<T> {
  const _TestHakoStateEvent(super.state, {super.name});
}
