import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/hako_state_events.dart';

void main() {
  group(
    'HakoStateEvent',
    () {
      test(
        'should create a HakoStateEvent with a null state (dynamic type) value and no name',
        () {
          // Arrange & Act
          const state = null;
          final event = _TestHakoStateEvent(state) as HakoStateEvent;

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
          final event = _TestHakoStateEvent<Set<String>?>(state)
              as HakoStateEvent<Set<String>?>;
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
          final event = _TestHakoStateEvent<Set<String>>(state)
              as HakoStateEvent<Set<String>>;

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
          final event = _TestHakoStateEvent<Set<String>>(state, name: name)
              as HakoStateEvent<Set<String>>;

          // Assert
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Set<String>, name)));
        },
      );
    },
  );
  group(
    'ValueGetEvent',
    () {
      test(
        'should be a HakoStateEvent',
        () {
          // Arrange & Act
          const state = {'test_value'};
          const name = 'test_name';
          final event = ValueGetEvent<Set<String>?>(state, name: name);

          // Assert
          expect(event, isA<HakoStateEvent<Set<String>?>>());
        },
      );
      test(
        'should create ValueGetEvent with complex object state and verify toString format',
        () {
          // Arrange
          final state = {'key1': 'value1', 'key2': 'value2'};
          const name = 'complex_state';

          // Act
          final event = ValueGetEvent<Map<String, String>>(state, name: name);

          // Assert
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Map<String, String>, name)));
          expect(
            event.toString(),
            equals(
              'ValueGetEvent{key: (Map<String, String>, complex_state), state: {key1: value1, key2: value2}}',
            ),
          );
        },
      );
      test(
        'should verify two ValueGetEvent instances with same state and key are equal',
        () {
          // Arrange
          const state = {'test_value'};
          const name = 'test_name';
          final event1 = ValueGetEvent<Set<String>>(state, name: name);
          final event2 = ValueGetEvent<Set<String>>(state, name: name);

          // Act & Assert
          expect(event1, equals(event2));
          expect(event1.hashCode, equals(event2.hashCode));
        },
      );
      test(
        'should verify two ValueGetEvent instances with different states are not equal',
        () {
          // Arrange
          const state1 = 'first_value';
          const state2 = 'second_value';
          const name = 'test_name';
          final event1 = ValueGetEvent<String>(state1, name: name);
          final event2 = ValueGetEvent<String>(state2, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two ValueGetEvent instances with same state, same name and different types are not equal',
        () {
          // Arrange
          const state = 0;
          const name = 'test_name';
          final event1 = ValueGetEvent<num>(state, name: name);
          final event2 = ValueGetEvent<int>(state, name: name);

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
      test(
        'should verify two ValueGetEvent instances with same state, same type and different names are not equal',
        () {
          // Arrange
          const state = 'test_value';
          final event1 = ValueGetEvent<String>(state, name: 'first');
          final event2 = ValueGetEvent<String>(state, name: 'second');

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
    },
  );
  group(
    'ValueSetEvent',
    () {
      test(
        'should be a HakoStateEvent',
        () {
          // Arrange & Act
          const previous = {'old_value'};
          const state = {'new_value'};
          const name = 'test_name';
          final event =
              ValueSetEvent<Set<String>?>(previous, state, name: name);

          // Assert
          expect(event, isA<HakoStateEvent<Set<String>?>>());
        },
      );
      test(
        'should create ValueSetEvent with complex object state and verify toString format',
        () {
          // Arrange
          final previous = {'key1': 'old_value1', 'key2': 'old_value2'};
          final state = {'key1': 'new_value1', 'key2': 'new_value2'};
          const name = 'complex_state';

          // Act
          final event =
              ValueSetEvent<Map<String, String>>(previous, state, name: name);

          // Assert
          expect(event.previous, equals(previous));
          expect(event.state, equals(state));
          expect(event.name, equals(name));
          expect(event.key, equals((Map<String, String>, name)));
          expect(
            event.toString(),
            equals(
              'ValueSetEvent{key: (Map<String, String>, complex_state), previous: {key1: old_value1, key2: old_value2}, state: {key1: new_value1, key2: new_value2}}',
            ),
          );
        },
      );
      test(
        'should verify two ValueSetEvent instances with same previous, state and key are equal',
        () {
          // Arrange
          const previous = {'old_value'};
          const state = {'new_value'};
          const name = 'test_name';
          final event1 =
              ValueSetEvent<Set<String>>(previous, state, name: name);
          final event2 =
              ValueSetEvent<Set<String>>(previous, state, name: name);

          // Act & Assert
          expect(event1, equals(event2));
          expect(event1.hashCode, equals(event2.hashCode));
        },
      );
      test(
        'should verify two ValueSetEvent instances with different previous values are not equal',
        () {
          // Arrange
          const previous1 = 'old_value1';
          const previous2 = 'old_value2';
          const state = 'new_value';
          const name = 'test_name';
          final event1 = ValueSetEvent<String>(previous1, state, name: name);
          final event2 = ValueSetEvent<String>(previous2, state, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two ValueSetEvent instances with different states are not equal',
        () {
          // Arrange
          const previous = 'old_value';
          const state1 = 'new_value1';
          const state2 = 'new_value2';
          const name = 'test_name';
          final event1 = ValueSetEvent<String>(previous, state1, name: name);
          final event2 = ValueSetEvent<String>(previous, state2, name: name);

          // Act & Assert
          expect(event1 == event2, isFalse);
          expect(event1.hashCode == event2.hashCode, isFalse);
        },
      );
      test(
        'should verify two ValueSetEvent instances with same previous, same state, same name and different types are not equal',
        () {
          // Arrange
          const previous = 0;
          const state = 1;
          const name = 'test_name';
          final event1 = ValueSetEvent<num>(previous, state, name: name);
          final event2 = ValueSetEvent<int>(previous, state, name: name);

          // Act & Assert
          expect(event1, isNot(equals(event2)));
          expect(event1.hashCode, isNot(equals(event2.hashCode)));
        },
      );
      test(
        'should verify two ValueSetEvent instances with same previous, same state, same type and different names are not equal',
        () {
          // Arrange
          const previous = 'old_value';
          const state = 'new_value';
          final event1 = ValueSetEvent<String>(previous, state, name: 'first');
          final event2 = ValueSetEvent<String>(previous, state, name: 'second');

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
