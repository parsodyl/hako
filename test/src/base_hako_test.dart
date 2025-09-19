import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/base_hako.dart';
import 'package:hako/src/hako_modifiers_contract.dart';
import 'package:hako/src/hako_state_events.dart';

void main() {
  group(
    'BaseHako constructor',
    () {
      test(
        'should call registrar function immediately during construction',
        () {
          // Arrange
          bool registrarCalled = false;

          // Act
          _TestBaseHako((register) {
            registrarCalled = true;
          });

          // Assert
          expect(registrarCalled, isTrue);
        },
      );
      test(
        'should allow registering state values of different types',
        () {
          // Arrange & Act
          final hako = _TestBaseHako(
            (register) {
              register<int>(42);
              register<String>('hello');
              register<bool>(true);
              register<List<String>>(['a', 'b']);
            },
          );

          // Assert
          expect(hako.get<int>(), equals(42));
          expect(hako.get<String>(), equals('hello'));
          expect(hako.get<bool>(), isTrue);
          expect(hako.get<List<String>>(), equals(['a', 'b']));
        },
      );
      test(
        'should allow registering multiple values of same type with different names',
        () {
          // Arrange & Act
          final hako = _TestBaseHako((register) {
            register<String>('primary', name: 'theme');
            register<String>('large', name: 'size');
            register<String>('default'); // no name
          });

          // Assert
          expect(hako.get<String>(name: 'theme'), equals('primary'));
          expect(hako.get<String>(name: 'size'), equals('large'));
          expect(hako.get<String>(), equals('default'));
        },
      );
      test(
        'should allow registering nullable types with explicit type declaration',
        () {
          // Arrange & Act
          final hako = _TestBaseHako((register) {
            register<String?>(null);
            register<int?>(null, name: 'optional');
            register<List<String>?>(null);
          });

          // Assert
          expect(hako.get<String?>(), isNull);
          expect(hako.get<int?>(name: 'optional'), isNull);
          expect(hako.get<List<String>?>(), isNull);
        },
      );
      test(
        'should throw StateError when registering duplicate type and name combination',
        () {
          // Arrange & Act & Assert
          expect(
            () => _TestBaseHako((register) {
              register<int>(1);
              register<int>(2); // Same type, same name (null)
            }),
            throwsA(isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Piece of state of type "int"'),
            )),
          );
        },
      );
      test(
        'should throw StateError when registering duplicate named state',
        () {
          // Arrange & Act & Assert
          expect(
            () => _TestBaseHako((register) {
              register<String>('first', name: 'test');
              register<String>('second', name: 'test'); // Same type and name
            }),
            throwsA(isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('and name "test"'),
            )),
          );
        },
      );
      test(
        'should throw AssertionError when registering null with generic Null type',
        () {
          // Arrange & Act & Assert
          expect(
            () => _TestBaseHako((register) {
              register<Null>(null);
            }),
            throwsA(isA<AssertionError>().having(
              (e) => e.message,
              'message',
              contains('Cannot register null values with generic types'),
            )),
          );
        },
      );
      test(
        'should throw AssertionError when registering null with dynamic type',
        () {
          // Arrange & Act & Assert
          expect(
            () => _TestBaseHako((register) {
              register<dynamic>(null);
            }),
            throwsA(isA<AssertionError>().having(
              (e) => e.message,
              'message',
              contains('Cannot register null values with generic types'),
            )),
          );
        },
      );
      test(
        'should allow registering the same type with and without names',
        () {
          // Arrange & Act
          final hako = _TestBaseHako((register) {
            register<int>(1); // no name
            register<int>(2, name: 'counter');
            register<int>(3, name: 'other');
          });

          // Assert
          expect(hako.get<int>(), equals(1));
          expect(hako.get<int>(name: 'counter'), equals(2));
          expect(hako.get<int>(name: 'other'), equals(3));
        },
      );
      test(
        'should preserve exact registered values without modification',
        () {
          // Arrange
          final complexObject = {
            'key': [1, 2, 3]
          };

          // Act
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(complexObject);
          });

          // Assert
          expect(hako.get<Map<String, List<int>>>(), same(complexObject));
        },
      );
      test(
        'should initialize with event stream closed by default',
        () {
          // Arrange & Act
          final hako = _TestBaseHako((register) {
            register<int>(0);
          });

          // Assert
          expect(hako.isEventStreamOpen, isFalse);
        },
      );
      test(
        'should implement HakoStateGetter and HakoStateSetter interfaces',
        () {
          // Arrange & Act
          final hako = _TestBaseHako((register) {
            register<int>(0);
          });

          // Assert
          expect(hako, isA<HakoStateGetter>());
          expect(hako, isA<HakoStateSetter>());
        },
      );
    },
  );
  group(
    'BaseHako get method',
    () {
      test(
        'should return the correct value for registered state without name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
            register<String>('hello world');
            register<bool>(true);
          });

          // Act & Assert
          expect(hako.get<int>(), equals(42));
          expect(hako.get<String>(), equals('hello world'));
          expect(hako.get<bool>(), isTrue);
        },
      );
      test(
        'should return the correct value for registered state with name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('primary', name: 'theme');
            register<int>(100, name: 'maxCount');
            register<bool>(false, name: 'isEnabled');
          });

          // Act & Assert
          expect(hako.get<String>(name: 'theme'), equals('primary'));
          expect(hako.get<int>(name: 'maxCount'), equals(100));
          expect(hako.get<bool>(name: 'isEnabled'), isFalse);
        },
      );
      test(
        'should distinguish between same type with and without names',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('default');
            register<String>('named', name: 'special');
          });

          // Act & Assert
          expect(hako.get<String>(), equals('default'));
          expect(hako.get<String>(name: 'special'), equals('named'));
        },
      );
      test(
        'should distinguish between same type with different names',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(1, name: 'first');
            register<int>(2, name: 'second');
            register<int>(3, name: 'third');
          });

          // Act & Assert
          expect(hako.get<int>(name: 'first'), equals(1));
          expect(hako.get<int>(name: 'second'), equals(2));
          expect(hako.get<int>(name: 'third'), equals(3));
        },
      );
      test(
        'should return null values for nullable types',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String?>(null);
            register<int?>(null, name: 'optional');
            register<List<String>?>(null, name: 'items');
          });

          // Act & Assert
          expect(hako.get<String?>(), isNull);
          expect(hako.get<int?>(name: 'optional'), isNull);
          expect(hako.get<List<String>?>(name: 'items'), isNull);
        },
      );
      test(
        'should return the exact same object reference that was registered',
        () {
          // Arrange
          final complexObject = {
            'key': [1, 2, 3]
          };
          final listObject = ['a', 'b', 'c'];
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(complexObject);
            register<List<String>>(listObject, name: 'items');
          });

          // Act & Assert
          expect(hako.get<Map<String, List<int>>>(), same(complexObject));
          expect(hako.get<List<String>>(name: 'items'), same(listObject));
        },
      );
      test(
        'should throw ArgumentError when accessing unregistered state without name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });

          // Act & Assert
          expect(
            () => hako.get<String>(),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('(no name)'),
                contains('not found'),
                contains('You must register it in the constructor'),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when accessing unregistered state with name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });

          // Act & Assert
          expect(
            () => hako.get<String>(name: 'theme'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('and name "theme"'),
                contains('not found'),
                contains('You must register it in the constructor'),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when accessing registered type with wrong name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('value', name: 'correct');
          });

          // Act & Assert
          expect(
            () => hako.get<String>(name: 'wrong'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('and name "wrong"'),
                contains('not found'),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when accessing named state without providing name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('value', name: 'named');
          });

          // Act & Assert
          expect(
            () => hako.get<String>(),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('(no name)'),
                contains('not found'),
              ]),
            )),
          );
        },
      );
      test(
        'should work with complex generic types',
        () {
          // Arrange
          final mapValue = <String, List<int>>{
            'numbers': [1, 2, 3]
          };
          final futureValue = Future.value(42);
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(mapValue);
            register<Future<int>>(futureValue, name: 'async');
          });

          // Act & Assert
          expect(hako.get<Map<String, List<int>>>(), equals(mapValue));
          expect(hako.get<Future<int>>(name: 'async'), same(futureValue));
        },
      );
      test(
        'should handle multiple calls to get same state consistently',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('consistent');
          });

          // Act
          final first = hako.get<String>();
          final second = hako.get<String>();
          final third = hako.get<String>();

          // Assert
          expect(first, equals('consistent'));
          expect(second, equals('consistent'));
          expect(third, equals('consistent'));
          expect(first, same(second));
          expect(second, same(third));
        },
      );
    },
  );
  group(
    'BaseHako set method',
    () {
      test(
        'should update state value when new value is different',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(10);
            register<String>('initial');
            register<bool>(false);
          });

          // Act
          hako.set<int>((current) => current + 5);
          hako.set<String>((current) => '$current updated');
          hako.set<bool>((current) => !current);

          // Assert
          expect(hako.get<int>(), equals(15));
          expect(hako.get<String>(), equals('initial updated'));
          expect(hako.get<bool>(), isTrue);
        },
      );
      test(
        'should update named state values correctly',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('light', name: 'theme');
            register<int>(50, name: 'volume');
            register<bool>(true, name: 'enabled');
          });

          // Act
          hako.set<String>((current) => 'dark', name: 'theme');
          hako.set<int>((current) => current * 2, name: 'volume');
          hako.set<bool>((current) => false, name: 'enabled');

          // Assert
          expect(hako.get<String>(name: 'theme'), equals('dark'));
          expect(hako.get<int>(name: 'volume'), equals(100));
          expect(hako.get<bool>(name: 'enabled'), isFalse);
        },
      );
      test(
        'should distinguish between same type with and without names when setting',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('default');
            register<String>('named', name: 'special');
          });

          // Act
          hako.set<String>((current) => 'updated default');
          hako.set<String>((current) => 'updated named', name: 'special');

          // Assert
          expect(hako.get<String>(), equals('updated default'));
          expect(hako.get<String>(name: 'special'), equals('updated named'));
        },
      );
      test(
        'should distinguish between same type with different names when setting',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(1, name: 'first');
            register<int>(2, name: 'second');
            register<int>(3, name: 'third');
          });

          // Act
          hako.set<int>((current) => current * 10, name: 'first');
          hako.set<int>((current) => current * 20, name: 'second');
          hako.set<int>((current) => current * 30, name: 'third');

          // Assert
          expect(hako.get<int>(name: 'first'), equals(10));
          expect(hako.get<int>(name: 'second'), equals(40));
          expect(hako.get<int>(name: 'third'), equals(90));
        },
      );
      test(
        'should handle nullable types correctly',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String?>(null);
            register<int?>(null, name: 'optional');
            register<List<String>?>(null, name: 'items');
          });

          // Act
          hako.set<String?>((current) => 'not null anymore');
          hako.set<int?>((current) => 42, name: 'optional');
          hako.set<List<String>?>((current) => ['a', 'b'], name: 'items');

          // Assert
          expect(hako.get<String?>(), equals('not null anymore'));
          expect(hako.get<int?>(name: 'optional'), equals(42));
          expect(hako.get<List<String>?>(name: 'items'), equals(['a', 'b']));
        },
      );
      test(
        'should handle setting nullable types back to null',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String?>('initial');
            register<int?>(100, name: 'count');
          });

          // Act
          hako.set<String?>((current) => null);
          hako.set<int?>((current) => null, name: 'count');

          // Assert
          expect(hako.get<String?>(), isNull);
          expect(hako.get<int?>(name: 'count'), isNull);
        },
      );
      test(
        'should not update state when new value is identical to current',
        () {
          // Arrange
          final originalObject = ['a', 'b', 'c'];
          final hako = _TestBaseHako((register) {
            register<List<String>>(originalObject);
            register<int>(42);
          });

          // Act
          hako.set<List<String>>((current) => current); // Same reference
          hako.set<int>((current) => 42); // Same value but different reference

          // Assert
          expect(hako.get<List<String>>(), same(originalObject));
          expect(hako.get<int>(), equals(42));
        },
      );
      test(
        'should update state when new value has same content but different reference',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<List<String>>(['a', 'b']);
            register<Map<String, int>>({'key': 1});
          });

          // Act
          hako.set<List<String>>(
              (current) => ['a', 'b']); // Same content, different reference
          hako.set<Map<String, int>>(
              (current) => {'key': 1}); // Same content, different reference

          // Assert
          expect(hako.get<List<String>>(), equals(['a', 'b']));
          expect(hako.get<Map<String, int>>(), equals({'key': 1}));
        },
      );
      test(
        'should provide current value to updater function',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(5);
            register<String>('hello', name: 'greeting');
          });

          // Act & Assert
          hako.set<int>((current) {
            expect(current, equals(5));
            return current * 2;
          });

          hako.set<String>((current) {
            expect(current, equals('hello'));
            return '$current world';
          }, name: 'greeting');

          expect(hako.get<int>(), equals(10));
          expect(hako.get<String>(name: 'greeting'), equals('hello world'));
        },
      );
      test(
        'should handle complex generic types',
        () {
          // Arrange
          final initialMap = <String, List<int>>{
            'numbers': [1, 2]
          };
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(initialMap);
          });

          // Act
          hako.set<Map<String, List<int>>>((current) {
            final newMap = Map<String, List<int>>.from(current);
            newMap['numbers'] = [...current['numbers']!, 3];
            return newMap;
          });

          // Assert
          expect(
              hako.get<Map<String, List<int>>>()['numbers'], equals([1, 2, 3]));
        },
      );
      test(
        'should throw ArgumentError when setting unregistered state without name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });

          // Act & Assert
          expect(
            () => hako.set<String>((current) => 'new value'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('(no name)'),
                contains('not found'),
                contains(
                  'You must register it in the constructor of your Hako class before setting it to a new value',
                ),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when setting unregistered state with name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });

          // Act & Assert
          expect(
            () => hako.set<String>((current) => 'new value', name: 'theme'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('and name "theme"'),
                contains('not found'),
                contains('before setting it to a new value'),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when setting registered type with wrong name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('value', name: 'correct');
          });

          // Act & Assert
          expect(
            () => hako.set<String>((current) => 'new value', name: 'wrong'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('and name "wrong"'),
                contains('not found'),
              ]),
            )),
          );
        },
      );
      test(
        'should throw ArgumentError when setting named state without providing name',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('value', name: 'named');
          });

          // Act & Assert
          expect(
            () => hako.set<String>((current) => 'new value'),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('Piece of state of type "String"'),
                contains('(no name)'),
                contains('not found'),
              ]),
            )),
          );
        },
      );
      test(
        'should allow multiple consecutive updates',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(0);
          });

          // Act
          hako.set<int>((current) => current + 1);
          hako.set<int>((current) => current + 2);
          hako.set<int>((current) => current * 3);

          // Assert
          expect(hako.get<int>(), equals(9)); // (0 + 1 + 2) * 3
        },
      );
      test(
        'should handle updater function that throws exception',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });

          // Act & Assert
          expect(
            () => hako.set<int>((current) => throw Exception('Update failed')),
            throwsA(isA<Exception>()),
          );

          // State should remain unchanged
          expect(hako.get<int>(), equals(42));
        },
      );
      test(
        'should preserve state when updater returns identical value',
        () {
          // Arrange
          final originalList = [1, 2, 3];
          final hako = _TestBaseHako((register) {
            register<List<int>>(originalList);
            register<String>('same');
          });

          // Act
          hako.set<List<int>>((current) => current); // Return same reference
          hako.set<String>((current) => current); // Return same reference

          // Assert
          expect(hako.get<List<int>>(), same(originalList));
          expect(hako.get<String>(), equals('same'));
        },
      );
    },
  );
  group(
    'BaseHako get method event stream behavior',
    () {
      test(
        'should emit ValueGetEvent when getting state with event stream open',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('test value');
            register<int>(42, name: 'counter');
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<String>();
          hako.get<int>(name: 'counter');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<String>('test value'),
              ValueGetEvent<int>(42, name: 'counter'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should not emit events when getting state with event stream closed',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('test value');
          });

          // Act
          final result = hako.get<String>();

          // Assert
          expect(result, equals('test value'));
          expect(hako.isEventStreamOpen, isFalse);
        },
      );
      test(
        'should emit correct ValueGetEvent with nullable types',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String?>(null);
            register<int?>(100, name: 'optional');
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<String?>();
          hako.get<int?>(name: 'optional');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<String?>(null),
              ValueGetEvent<int?>(100, name: 'optional'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events for complex generic types',
        () {
          // Arrange
          final mapValue = <String, List<int>>{
            'numbers': [1, 2, 3]
          };
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(mapValue);
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<Map<String, List<int>>>();
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<Map<String, List<int>>>(mapValue),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit multiple events for consecutive gets of same state',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('repeated');
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<String>();
          hako.get<String>();
          hako.get<String>();
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<String>('repeated'),
              ValueGetEvent<String>('repeated'),
              ValueGetEvent<String>('repeated'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events for different states accessed in sequence',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(1);
            register<String>('hello');
            register<bool>(true, name: 'flag');
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<int>();
          hako.get<String>();
          hako.get<bool>(name: 'flag');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<int>(1),
              ValueGetEvent<String>('hello'),
              ValueGetEvent<bool>(true, name: 'flag'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should not emit event when addToEventStream is false',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('silent');
            register<int>(42, name: 'counter');
          });
          final stream = hako.openEventStream();

          // Act
          final result1 = hako.get<String>(addToEventStream: false);
          final result2 =
              hako.get<int>(name: 'counter', addToEventStream: false);
          hako.closeEventStream();

          // Assert
          expect(result1, equals('silent'));
          expect(result2, equals(42));
          expect(stream, emitsDone);
        },
      );
      test(
        'should emit events only for gets with addToEventStream true',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('visible');
            register<int>(42);
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<String>(addToEventStream: true);
          hako.get<int>(addToEventStream: false);
          hako.get<String>(addToEventStream: true);
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<String>('visible'),
              ValueGetEvent<String>('visible'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events with correct state key information',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('unnamed');
            register<String>('named', name: 'special');
          });
          final stream = hako.openEventStream();

          // Act
          hako.get<String>();
          hako.get<String>(name: 'special');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              predicate<ValueGetEvent<String>>((event) =>
                  event.key == (String, null) && event.state == 'unnamed'),
              predicate<ValueGetEvent<String>>((event) =>
                  event.key == (String, 'special') && event.state == 'named'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should maintain event emission behavior when get throws ArgumentError',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });
          final stream = hako.openEventStream();

          // Act & Assert
          hako.get<int>(); // This should emit an event
          expect(
            () => hako.get<String>(),
            throwsA(isA<ArgumentError>()),
          ); // This should not emit any events
          hako.closeEventStream();

          expect(
            stream,
            emitsInOrder([
              ValueGetEvent<int>(42),
              emitsDone,
            ]),
          );
        },
      );
    },
  );
  group(
    'BaseHako set method event stream behavior',
    () {
      test(
        'should emit ValueSetEvent when setting state with event stream open',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('initial');
            register<int>(10, name: 'counter');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<String>((current) => 'updated');
          hako.set<int>((current) => current + 5, name: 'counter');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<String>('initial', 'updated'),
              ValueSetEvent<int>(10, 15, name: 'counter'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should not emit events when setting state with event stream closed',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('initial');
          });

          // Act
          hako.set<String>((current) => 'updated');

          // Assert
          expect(hako.get<String>(), equals('updated'));
          expect(hako.isEventStreamOpen, isFalse);
        },
      );
      test(
        'should emit correct ValueSetEvent with nullable types',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String?>(null);
            register<int?>(100, name: 'optional');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<String?>((current) => 'not null');
          hako.set<int?>((current) => null, name: 'optional');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<String?>(null, 'not null'),
              ValueSetEvent<int?>(100, null, name: 'optional'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events for complex generic types',
        () {
          // Arrange
          final initialMap = <String, List<int>>{
            'numbers': [1, 2]
          };
          final updatedMap = <String, List<int>>{
            'numbers': [1, 2, 3]
          };
          final hako = _TestBaseHako((register) {
            register<Map<String, List<int>>>(initialMap);
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<Map<String, List<int>>>((current) => updatedMap);
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<Map<String, List<int>>>(initialMap, updatedMap),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit multiple events for consecutive sets of same state',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(0);
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<int>((current) => current + 1);
          hako.set<int>((current) => current + 1);
          hako.set<int>((current) => current + 1);
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<int>(0, 1),
              ValueSetEvent<int>(1, 2),
              ValueSetEvent<int>(2, 3),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events for different states updated in sequence',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(1);
            register<String>('hello');
            register<bool>(false, name: 'flag');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<int>((current) => current * 2);
          hako.set<String>((current) => '$current world');
          hako.set<bool>((current) => !current, name: 'flag');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<int>(1, 2),
              ValueSetEvent<String>('hello', 'hello world'),
              ValueSetEvent<bool>(false, true, name: 'flag'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should not emit event when addToEventStream is false',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('silent');
            register<int>(42, name: 'counter');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<String>((current) => 'updated silently',
              addToEventStream: false);
          hako.set<int>((current) => current + 10,
              name: 'counter', addToEventStream: false);
          hako.closeEventStream();

          // Assert
          expect(hako.get<String>(), equals('updated silently'));
          expect(hako.get<int>(name: 'counter'), equals(52));
          expect(stream, emitsDone);
        },
      );
      test(
        'should emit events only for sets with addToEventStream true',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('visible');
            register<int>(42);
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<String>((current) => 'updated1', addToEventStream: true);
          hako.set<int>((current) => current + 1, addToEventStream: false);
          hako.set<String>((current) => 'updated2', addToEventStream: true);
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<String>('visible', 'updated1'),
              ValueSetEvent<String>('updated1', 'updated2'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should not emit event when new value is identical to current value',
        () {
          // Arrange
          final originalList = [1, 2, 3];
          final hako = _TestBaseHako((register) {
            register<List<int>>(originalList);
            register<String>('same');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<List<int>>((current) => current); // Same reference
          hako.set<String>((current) => current); // Same reference
          hako.closeEventStream();

          // Assert
          expect(stream, emitsDone);
        },
      );
      test(
        'should emit event when new value has same content but different reference',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<List<String>>(['a', 'b']);
            register<Map<String, int>>({'key': 1});
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<List<String>>(
              (current) => ['a', 'b']); // Same content, different reference
          hako.set<Map<String, int>>(
              (current) => {'key': 1}); // Same content, different reference
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              predicate<ValueSetEvent<List<String>>>((event) =>
                  listEquals<String>(event.previous, ['a', 'b']) &&
                  listEquals<String>(event.state, ['a', 'b']) &&
                  !identical(event.previous, event.state)),
              predicate<ValueSetEvent<Map<String, int>>>((event) =>
                  mapEquals<String, int>(event.previous, {'key': 1}) &&
                  mapEquals<String, int>(event.state, {'key': 1}) &&
                  !identical(event.previous, event.state)),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should emit events with correct state key information',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('unnamed');
            register<String>('named', name: 'special');
          });
          final stream = hako.openEventStream();

          // Act
          hako.set<String>((current) => 'updated unnamed');
          hako.set<String>((current) => 'updated named', name: 'special');
          hako.closeEventStream();

          // Assert
          expect(
            stream,
            emitsInOrder([
              predicate<ValueSetEvent<String>>((event) =>
                  event.key == (String, null) &&
                  event.previous == 'unnamed' &&
                  event.state == 'updated unnamed'),
              predicate<ValueSetEvent<String>>((event) =>
                  event.key == (String, 'special') &&
                  event.previous == 'named' &&
                  event.state == 'updated named'),
              emitsDone,
            ]),
          );
        },
      );
      test(
        'should maintain event emission behavior when set throws ArgumentError',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<int>(42);
          });
          final stream = hako.openEventStream();

          // Act & Assert
          hako.set<int>((current) => current + 1); // This should emit an event
          expect(
            () => hako.set<String>((current) => 'new'),
            throwsA(isA<ArgumentError>()),
          ); // This should not emit any events
          hako.closeEventStream();

          expect(
            stream,
            emitsInOrder([
              ValueSetEvent<int>(42, 43),
              emitsDone,
            ]),
          );
        },
      );
    },
  );

  group(
    'BaseHako dispose method',
    () {
      test(
        'should close event stream when dispose is called',
        () {
          // Arrange
          final hako = _TestBaseHako((register) {
            register<String>('test');
          });
          final stream = hako.openEventStream();
          expect(hako.isEventStreamOpen, isTrue);

          // Act
          hako.dispose();

          // Assert
          expect(hako.isEventStreamOpen, isFalse);
          expect(stream, emitsDone);
        },
      );
    },
  );
}

class _TestBaseHako extends BaseHako {
  _TestBaseHako(super.registrar);
}
