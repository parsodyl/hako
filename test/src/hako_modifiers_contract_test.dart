import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/hako_modifiers_contract.dart';

void main() {
  group(
    'HakoStateGetter',
    () {
      test(
        'should be extendable by other classes implementing the interface',
        () {
          // Arrange & Act
          final implementation = _TestHakoStateGetter();

          // Assert
          expect(implementation, isA<HakoStateGetter>());
          expect(
            implementation.get<String>(),
            equals(_TestHakoStateGetter.testStringValue),
          );
          expect(
            implementation.get<int>(name: _TestHakoStateGetter.counterName),
            equals(_TestHakoStateGetter.testIntValue),
          );
          expect(
            () => implementation.get<double>(),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    },
  );

  group(
    'HakoStateSetter',
    () {
      test(
        'should be extendable by other classes implementing the interface',
        () {
          // Arrange & Act
          final implementation = _TestHakoStateSetter();

          // Assert
          expect(implementation, isA<HakoStateSetter>());

          // Test and assert setting a string value
          implementation.set<String>((current) => 'new value');
          expect(implementation.stringValue, equals('new value'));

          // Test and assert setting an int value with name
          implementation.set<int>((current) => current + 10,
              name: _TestHakoStateSetter.counterName);
          expect(
            implementation.intValue,
            equals(52),
          );

          // Test and assert ArgumentError case
          expect(
            () => implementation.set<double>((current) => 1.0),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    },
  );
}

class _TestHakoStateGetter implements HakoStateGetter {
  static const String testStringValue = 'test value';
  static const String counterName = 'counter';
  static const int testIntValue = 42;

  @override
  T get<T>({String? name}) {
    if (T == String && name == null) {
      return testStringValue as T;
    }
    if (T == int && name == counterName) {
      return testIntValue as T;
    }
    throw ArgumentError('State not found');
  }
}

class _TestHakoStateSetter implements HakoStateSetter {
  static const String counterName = 'counter';

  String stringValue = 'initial value';
  int intValue = 42;

  @override
  void set<T>(T Function(T current) updater, {String? name}) {
    if (T == String && name == null) {
      stringValue = updater(stringValue as T) as String;
      return;
    }
    if (T == int && name == counterName) {
      intValue = updater(intValue as T) as int;
      return;
    }
    throw ArgumentError('State not found');
  }
}
