import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/base_hako.dart';

void main() {
  group(
    'HakoBuildContextExtension - readHako method',
    () {
      // Arrange
      final testChild = Container(key: const Key('test-child'));

      testWidgets(
        'should return the correct Hako instance when HakoProvider is present',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          _TestCounterHako? retrievedHako;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedHako = context.readHako<_TestCounterHako>();
                    return testChild;
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedHako, isNotNull);
          expect(retrievedHako, same(testHako));
        },
      );

      testWidgets(
        'should return the same instance on multiple calls',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          _TestCounterHako? firstCall;
          _TestCounterHako? secondCall;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    firstCall = context.readHako<_TestCounterHako>();
                    secondCall = context.readHako<_TestCounterHako>();
                    return testChild;
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(firstCall, isNotNull);
          expect(secondCall, isNotNull);
          expect(firstCall, same(secondCall));
          expect(firstCall, same(testHako));
        },
      );

      testWidgets(
        'should work with nested HakoProviders of different types',
        (tester) async {
          // Arrange
          final counterHako = _TestCounterHako();
          final stringHako = _TestStringHako();
          _TestCounterHako? retrievedCounterHako;
          _TestStringHako? retrievedStringHako;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: counterHako,
                child: HakoProvider<_TestStringHako>.value(
                  value: stringHako,
                  child: Builder(
                    builder: (context) {
                      retrievedCounterHako =
                          context.readHako<_TestCounterHako>();
                      retrievedStringHako = context.readHako<_TestStringHako>();
                      return testChild;
                    },
                  ),
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedCounterHako, same(counterHako));
          expect(retrievedStringHako, same(stringHako));
        },
      );

      testWidgets(
        'should throw HakoProviderNotFoundException when no HakoProvider is found',
        (tester) async {
          // Arrange
          Object? thrownException;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  try {
                    context.readHako<_TestCounterHako>();
                  } catch (e) {
                    thrownException = e;
                  }
                  return testChild;
                },
              ),
            ),
          );

          // Assert
          expect(thrownException,
              isA<HakoProviderNotFoundException<_TestCounterHako>>());
          expect(
            thrownException.toString(),
            contains(
              'No HakoProvider<_TestCounterHako> found in the widget tree',
            ),
          );
        },
      );

      testWidgets(
        'should throw HakoProviderNotFoundException when wrong type is requested',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          Object? thrownException;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    try {
                      context.readHako<_TestStringHako>();
                    } catch (e) {
                      thrownException = e;
                    }
                    return testChild;
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(thrownException,
              isA<HakoProviderNotFoundException<_TestStringHako>>());
          expect(
            thrownException.toString(),
            contains(
              'No HakoProvider<_TestStringHako> found in the widget tree',
            ),
          );
        },
      );

      testWidgets(
        'should not trigger widget rebuilds when called',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          int buildCount = 0;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    buildCount++;
                    final hako = context.readHako<_TestCounterHako>();
                    return Text('Count: ${hako.count}');
                  },
                ),
              ),
            ),
          );

          // Initial build
          expect(buildCount, equals(1));

          // Modify state
          testHako.increment();
          await tester.pump();

          // Should not rebuild because readHako doesn't listen to changes
          expect(buildCount, equals(1));
        },
      );
    },
  );
  group(
    'HakoBuildContextExtension - watchHakoState method',
    () {
      // Arrange
      final testChild = Container(key: const Key('test-child'));

      testWidgets(
        'should return the correct state value when HakoProvider is present',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          testHako.increment(); // Set count to 1
          int? retrievedCount;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedCount =
                        context.watchHakoState<_TestCounterHako, int>();
                    return Text('Count: $retrievedCount');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedCount, equals(1));
          expect(find.text('Count: 1'), findsOneWidget);
        },
      );

      testWidgets(
        'should return the correct named state value',
        (tester) async {
          // Arrange
          final testHako = _TestNamedStateHako();
          String? retrievedTheme;
          int? retrievedVolume;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestNamedStateHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedTheme =
                        context.watchHakoState<_TestNamedStateHako, String>(
                            name: 'theme');
                    retrievedVolume =
                        context.watchHakoState<_TestNamedStateHako, int>(
                            name: 'volume');
                    return Column(
                      children: [
                        Text('Theme: $retrievedTheme'),
                        Text('Volume: $retrievedVolume'),
                      ],
                    );
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedTheme, equals('light'));
          expect(retrievedVolume, equals(50));
          expect(find.text('Theme: light'), findsOneWidget);
          expect(find.text('Volume: 50'), findsOneWidget);
        },
      );

      testWidgets(
        'should rebuild widget when watched state changes',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      final count =
                          context.watchHakoState<_TestCounterHako, int>();
                      return Text('Count: $count');
                    },
                  ),
                  floatingActionButton: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () =>
                          context.readHako<_TestCounterHako>().increment(),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Assert: Verify the initial state is correct
          expect(find.text('Count: 0'), findsOneWidget);
          expect(find.text('Count: 1'), findsNothing);

          // Act: Tap the button to trigger the state change
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: Verify the widget has rebuilt with the new state
          expect(find.text('Count: 0'), findsNothing);
          expect(find.text('Count: 1'), findsOneWidget);

          // Act: Change the state again
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: Verify the widget has rebuilt with the new state
          expect(find.text('Count: 1'), findsNothing);
          expect(find.text('Count: 2'), findsOneWidget);
        },
      );

      testWidgets(
        'should NOT rebuild widget when state is set to an identical value',
        (tester) async {
          // Arrange
          final testHako = _TestListHako();
          List<int>? capturedList;
          int buildCount = 0;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestListHako>.value(
                value: testHako,
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      buildCount++;
                      final list =
                          context.watchHakoState<_TestListHako, List<int>>();
                      capturedList = list;
                      return Text('List: ${list.join(', ')}');
                    },
                  ),
                  floatingActionButton: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () =>
                          context.readHako<_TestListHako>().setIdentical(),
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Assert: The widget built once initially
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(buildCount, equals(1));
          final initialList = capturedList;

          // Act: Tap the button to set the identical state
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: The widget did NOT rebuild
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(buildCount, equals(1)); // No additional builds
          expect(capturedList, same(initialList));
        },
      );

      testWidgets(
        'should rebuild widget when state has same content but different reference',
        (tester) async {
          // Arrange
          final testHako = _TestListHako();
          List<int>? capturedList;
          int buildCount = 0;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestListHako>.value(
                value: testHako,
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      buildCount++;
                      final list =
                          context.watchHakoState<_TestListHako, List<int>>();
                      capturedList = list;
                      return Text('List: ${list.join(', ')}');
                    },
                  ),
                  floatingActionButton: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () =>
                          context.readHako<_TestListHako>().setSameContent(),
                      child: const Icon(Icons.copy),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Assert: Initial build and capture the initial list reference
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(buildCount, equals(1));
          final initialList = capturedList;

          // Act: Tap the button to set same content but different reference
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: The widget rebuilt with the new state
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(buildCount, equals(2)); // Widget rebuilt
          expect(capturedList, isNot(same(initialList))); // Different reference
          expect(capturedList, equals([1, 2])); // Same content
        },
      );

      testWidgets(
        'should handle multiple widgets watching the same state',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          int firstWidgetBuildCount = 0;
          int secondWidgetBuildCount = 0;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Scaffold(
                  body: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          firstWidgetBuildCount++;
                          final count =
                              context.watchHakoState<_TestCounterHako, int>();
                          return Text('First: $count');
                        },
                      ),
                      Builder(
                        builder: (context) {
                          secondWidgetBuildCount++;
                          final count =
                              context.watchHakoState<_TestCounterHako, int>();
                          return Text('Second: $count');
                        },
                      ),
                    ],
                  ),
                  floatingActionButton: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () =>
                          context.readHako<_TestCounterHako>().increment(),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Assert: Both widgets built initially
          expect(find.text('First: 0'), findsOneWidget);
          expect(find.text('Second: 0'), findsOneWidget);
          expect(firstWidgetBuildCount, equals(1));
          expect(secondWidgetBuildCount, equals(1));

          // Act: Change the state
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: Both widgets rebuilt
          expect(find.text('First: 1'), findsOneWidget);
          expect(find.text('Second: 1'), findsOneWidget);
          expect(firstWidgetBuildCount, equals(2));
          expect(secondWidgetBuildCount, equals(2));
        },
      );

      testWidgets(
        'should handle nullable state types',
        (tester) async {
          // Arrange
          final testHako = _TestNullableHako();
          String? retrievedValue;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestNullableHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedValue =
                        context.watchHakoState<_TestNullableHako, String?>();
                    return Text('Value: ${retrievedValue ?? 'null'}');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedValue, isNull);
          expect(find.text('Value: null'), findsOneWidget);
        },
      );
      testWidgets(
        'should throw HakoProviderNotFoundException when no HakoProvider is found',
        (tester) async {
          // Arrange
          Object? thrownException;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  try {
                    context.watchHakoState<_TestCounterHako, int>();
                  } catch (e) {
                    thrownException = e;
                  }
                  return testChild;
                },
              ),
            ),
          );

          // Assert
          expect(thrownException,
              isA<HakoProviderNotFoundException<_TestCounterHako>>());
          expect(
            thrownException.toString(),
            contains(
                'No HakoProvider<_TestCounterHako> found in the widget tree'),
          );
        },
      );

      testWidgets(
        'should throw HakoProviderNotFoundException when wrong type is requested',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          Object? thrownException;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    try {
                      context.watchHakoState<_TestStringHako, String>();
                    } catch (e) {
                      thrownException = e;
                    }
                    return testChild;
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(thrownException,
              isA<HakoProviderNotFoundException<_TestStringHako>>());
          expect(
            thrownException.toString(),
            contains(
                'No HakoProvider<_TestStringHako> found in the widget tree'),
          );
        },
      );

      testWidgets(
        'should throw ArgumentError when requesting unregistered state',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          Object? thrownException;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    try {
                      context.watchHakoState<_TestCounterHako, String>();
                    } catch (e) {
                      thrownException = e;
                    }
                    return testChild;
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(thrownException, isA<ArgumentError>());
          expect(
            thrownException.toString(),
            contains('Piece of state of type "String"'),
          );
        },
      );

      testWidgets(
        'should work with complex generic types',
        (tester) async {
          // Arrange
          final testHako = _TestComplexHako();
          Map<String, List<int>>? retrievedMap;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestComplexHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedMap = context.watchHakoState<_TestComplexHako,
                        Map<String, List<int>>>();
                    return Text('Map keys: ${retrievedMap!.keys.join(', ')}');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedMap, isNotNull);
          expect(retrievedMap!['numbers'], equals([1, 2, 3]));
          expect(find.text('Map keys: numbers'), findsOneWidget);
        },
      );

      testWidgets(
        'should not interfere with readHako calls in same widget',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          int? watchedCount;
          int? getCount;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    watchedCount =
                        context.watchHakoState<_TestCounterHako, int>();
                    getCount = context.readHako<_TestCounterHako>().count;
                    return Text('Watched: $watchedCount, Get: $getCount');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(watchedCount, equals(0));
          expect(getCount, equals(0));
          expect(find.text('Watched: 0, Get: 0'), findsOneWidget);
        },
      );
    },
  );

  group('HakoBuildContextExtension - filterHakoState method', () {
    // Arrange
    final testChild = Container(key: const Key('test-child'));

    testWidgets(
      'should return the correct filtered value when HakoProvider is present',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        testHako.increment(); // Set count to 1
        bool? isEven;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  isEven = context.filterHakoState<_TestCounterHako, int, bool>(
                    filter: (count) => count % 2 == 0,
                  );
                  return Text('Is Even: $isEven');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(isEven, equals(false));
        expect(find.text('Is Even: false'), findsOneWidget);
      },
    );

    testWidgets(
      'should return the correct filtered value for named state',
      (tester) async {
        // Arrange
        final testHako = _TestNamedStateHako();
        String? uppercaseTheme;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestNamedStateHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  uppercaseTheme = context
                      .filterHakoState<_TestNamedStateHako, String, String>(
                    filter: (theme) => theme.toUpperCase(),
                    name: 'theme',
                  );
                  return Text('Theme: $uppercaseTheme');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(uppercaseTheme, equals('LIGHT'));
        expect(find.text('Theme: LIGHT'), findsOneWidget);
      },
    );

    testWidgets(
      'should rebuild widget only when filtered result changes',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        int buildCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    buildCount++;
                    final isEven =
                        context.filterHakoState<_TestCounterHako, int, bool>(
                      filter: (count) => count % 2 == 0,
                    );
                    return Text('Is Even: $isEven');
                  },
                ),
                floatingActionButton: Builder(
                  builder: (context) => FloatingActionButton(
                    onPressed: () =>
                        context.readHako<_TestCounterHako>().increment(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert: Initial state (count=0, isEven=true)
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(buildCount, equals(1));

        // Act: Increment to 1 (isEven changes from true to false)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget rebuilt because filtered result changed
        expect(find.text('Is Even: false'), findsOneWidget);
        expect(buildCount, equals(2));

        // Act: Increment to 2 (isEven changes from false to true)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget rebuilt because filtered result changed
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(buildCount, equals(3));

        // Act: Increment to 3 (isEven stays false)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget rebuilt because filtered result changed
        expect(find.text('Is Even: false'), findsOneWidget);
        expect(buildCount, equals(4));
      },
    );

    testWidgets(
      'should NOT rebuild when filtered result remains the same',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        int buildCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    buildCount++;
                    // Filter that returns true for any positive number
                    final isPositive =
                        context.filterHakoState<_TestCounterHako, int, bool>(
                      filter: (count) => count > 0,
                    );
                    return Text('Is Positive: $isPositive');
                  },
                ),
                floatingActionButton: Builder(
                  builder: (context) => FloatingActionButton(
                    onPressed: () =>
                        context.readHako<_TestCounterHako>().increment(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert: Initial state (count=0, isPositive=false)
        expect(find.text('Is Positive: false'), findsOneWidget);
        expect(buildCount, equals(1));

        // Act: Increment to 1 (isPositive changes from false to true)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget rebuilt because filtered result changed
        expect(find.text('Is Positive: true'), findsOneWidget);
        expect(buildCount, equals(2));

        // Act: Increment to 2 (isPositive stays true)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget did NOT rebuild because filtered result stayed the same
        expect(find.text('Is Positive: true'), findsOneWidget);
        expect(buildCount, equals(2)); // No additional build
      },
    );

    testWidgets(
      'should handle complex filter transformations',
      (tester) async {
        // Arrange
        final testHako = _TestComplexHako();
        int? listLength;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestComplexHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  listLength = context.filterHakoState<_TestComplexHako,
                      Map<String, List<int>>, int>(
                    filter: (map) => map['numbers']?.length ?? 0,
                  );
                  return Text('List Length: $listLength');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(listLength, equals(3));
        expect(find.text('List Length: 3'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle nullable state types in filter',
      (tester) async {
        // Arrange
        final testHako = _TestNullableHako();
        int? stringLength;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestNullableHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  stringLength =
                      context.filterHakoState<_TestNullableHako, String?, int>(
                    filter: (value) => value?.length ?? 0,
                  );
                  return Text('String Length: $stringLength');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(stringLength, equals(0));
        expect(find.text('String Length: 0'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle multiple widgets with different filters on same state',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        int firstWidgetBuildCount = 0;
        int secondWidgetBuildCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Scaffold(
                body: Column(
                  children: [
                    Builder(
                      builder: (context) {
                        firstWidgetBuildCount++;
                        final isEven = context
                            .filterHakoState<_TestCounterHako, int, bool>(
                          filter: (count) => count % 2 == 0,
                        );
                        return Text('Is Even: $isEven');
                      },
                    ),
                    Builder(
                      builder: (context) {
                        secondWidgetBuildCount++;
                        final isGreaterThanTwo = context
                            .filterHakoState<_TestCounterHako, int, bool>(
                          filter: (count) => count > 2,
                        );
                        return Text('Greater Than 2: $isGreaterThanTwo');
                      },
                    ),
                  ],
                ),
                floatingActionButton: Builder(
                  builder: (context) => FloatingActionButton(
                    onPressed: () =>
                        context.readHako<_TestCounterHako>().increment(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert: Initial state (count=0)
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(find.text('Greater Than 2: false'), findsOneWidget);
        expect(firstWidgetBuildCount, equals(1));
        expect(secondWidgetBuildCount, equals(1));

        // Act: Increment to 1
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: First widget rebuilt (even changed), second didn't (still false)
        expect(find.text('Is Even: false'), findsOneWidget);
        expect(find.text('Greater Than 2: false'), findsOneWidget);
        expect(firstWidgetBuildCount, equals(2));
        expect(secondWidgetBuildCount, equals(1)); // No rebuild

        // Act: Increment to 2
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: First widget rebuilt (even changed), second didn't (still false)
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(find.text('Greater Than 2: false'), findsOneWidget);
        expect(firstWidgetBuildCount, equals(3));
        expect(secondWidgetBuildCount, equals(1)); // No rebuild

        // Act: Increment to 3
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Both widgets rebuilt (both filters changed)
        expect(find.text('Is Even: false'), findsOneWidget);
        expect(find.text('Greater Than 2: true'), findsOneWidget);
        expect(firstWidgetBuildCount, equals(4));
        expect(secondWidgetBuildCount, equals(2)); // Rebuilt
      },
    );

    testWidgets(
      'should throw HakoProviderNotFoundException when no HakoProvider is found',
      (tester) async {
        // Arrange
        Object? thrownException;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                try {
                  context.filterHakoState<_TestCounterHako, int, bool>(
                    filter: (count) => count > 0,
                  );
                } catch (e) {
                  thrownException = e;
                }
                return testChild;
              },
            ),
          ),
        );

        // Assert
        expect(thrownException,
            isA<HakoProviderNotFoundException<_TestCounterHako>>());
        expect(
          thrownException.toString(),
          contains(
              'No HakoProvider<_TestCounterHako> found in the widget tree'),
        );
      },
    );

    testWidgets(
      'should throw HakoProviderNotFoundException when wrong type is requested',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        Object? thrownException;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  try {
                    context.filterHakoState<_TestStringHako, String, int>(
                      filter: (value) => value.length,
                    );
                  } catch (e) {
                    thrownException = e;
                  }
                  return testChild;
                },
              ),
            ),
          ),
        );

        // Assert
        expect(thrownException,
            isA<HakoProviderNotFoundException<_TestStringHako>>());
        expect(
          thrownException.toString(),
          contains('No HakoProvider<_TestStringHako> found in the widget tree'),
        );
      },
    );

    testWidgets(
      'should throw ArgumentError when requesting unregistered state',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        Object? thrownException;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  try {
                    context.filterHakoState<_TestCounterHako, String, int>(
                      filter: (value) => value.length,
                    );
                  } catch (e) {
                    thrownException = e;
                  }
                  return testChild;
                },
              ),
            ),
          ),
        );

        // Assert
        expect(thrownException, isA<ArgumentError>());
        expect(
          thrownException.toString(),
          contains('Piece of state of type "String"'),
        );
      },
    );

    testWidgets(
      'should work with complex generic types and transformations',
      (tester) async {
        // Arrange
        final testHako = _TestComplexHako();
        List<String>? transformedKeys;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestComplexHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  transformedKeys = context.filterHakoState<_TestComplexHako,
                      Map<String, List<int>>, List<String>>(
                    filter: (map) => map.keys.toList()..sort(),
                  );
                  return Text('Keys: ${transformedKeys?.join(', ')}');
                },
              ),
            ),
          ),
        );

        // Assert
        expect(transformedKeys, isNotNull);
        expect(transformedKeys, contains('numbers'));
        expect(find.textContaining('Keys:'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle filter function that returns same content but different reference',
      (tester) async {
        // Arrange
        final testHako = _TestComplexHako();
        int buildCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestComplexHako>.value(
              value: testHako,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    buildCount++;
                    // Filter that always returns a new list with same content
                    final keys = context.filterHakoState<_TestComplexHako,
                        Map<String, List<int>>, List<String>>(
                      filter: (map) => List<String>.from(map.keys),
                    );
                    return Text('Keys Count: ${keys.length}');
                  },
                ),
                floatingActionButton: Builder(
                  builder: (context) => FloatingActionButton(
                    onPressed: () => context.readHako<_TestComplexHako>(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert: Initial state
        expect(find.text('Keys Count: 1'), findsOneWidget);
        expect(buildCount, equals(1));

        // Act: Add number (doesn't change keys, so filter result should be same)
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert: Widget should NOT rebuild because filter result content is same
        expect(find.text('Keys Count: 1'), findsOneWidget);
        expect(buildCount, equals(1)); // No additional build
      },
    );

    testWidgets(
      'should handle filter function exceptions gracefully',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        Object? thrownException;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: Builder(
                builder: (context) {
                  try {
                    context.filterHakoState<_TestCounterHako, int, String>(
                      filter: (count) => throw Exception('Filter error'),
                    );
                  } catch (e) {
                    thrownException = e;
                  }
                  return testChild;
                },
              ),
            ),
          ),
        );

        // Assert
        expect(thrownException, isA<Exception>());
        expect(thrownException.toString(), contains('Filter error'));
      },
    );

    testWidgets(
      'should work correctly with nested HakoProviders of different types',
      (tester) async {
        // Arrange
        final counterHako = _TestCounterHako();
        final stringHako = _TestStringHako();
        bool? counterIsEven;
        int? stringLength;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: counterHako,
              child: HakoProvider<_TestStringHako>.value(
                value: stringHako,
                child: Builder(
                  builder: (context) {
                    counterIsEven =
                        context.filterHakoState<_TestCounterHako, int, bool>(
                      filter: (count) => count % 2 == 0,
                    );
                    stringLength =
                        context.filterHakoState<_TestStringHako, String, int>(
                      filter: (value) => value.length,
                    );
                    return Column(
                      children: [
                        Text('Counter Is Even: $counterIsEven'),
                        Text('String Length: $stringLength'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(counterIsEven, equals(true)); // Initial count is 0
        expect(stringLength, equals(7)); // "initial".length
        expect(find.text('Counter Is Even: true'), findsOneWidget);
        expect(find.text('String Length: 7'), findsOneWidget);
      },
    );

    testWidgets(
      'should maintain filter state consistency across widget rebuilds',
      (tester) async {
        // Arrange
        final testHako = _TestCounterHako();
        final List<bool> filterResults = [];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: HakoProvider<_TestCounterHako>.value(
              value: testHako,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    body: Builder(
                      builder: (context) {
                        final isEven = context
                            .filterHakoState<_TestCounterHako, int, bool>(
                          filter: (count) => count % 2 == 0,
                        );
                        filterResults.add(isEven);
                        return Text('Is Even: $isEven');
                      },
                    ),
                    floatingActionButton: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: 'increment',
                          onPressed: () =>
                              context.readHako<_TestCounterHako>().increment(),
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'rebuild',
                          onPressed: () => setState(() {}),
                          child: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Assert: Initial state
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(filterResults, equals([true]));

        // Act: Force widget rebuild without state change
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        // Assert: Filter should return same result
        expect(find.text('Is Even: true'), findsOneWidget);
        expect(
            filterResults, equals([true, true])); // No new filter result added

        // Act: Increment counter
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert: Filter should return new result
        expect(find.text('Is Even: false'), findsOneWidget);
        expect(filterResults, equals([true, true, false]));
      },
    );
  });
}

class _TestNamedStateHako extends BaseHako {
  _TestNamedStateHako()
      : super((register) {
          register<String>('light', name: 'theme');
          register<int>(50, name: 'volume');
        });

  String get theme => get<String>(name: 'theme');

  int get volume => get<int>(name: 'volume');

  void setTheme(String newTheme) =>
      set<String>((current) => newTheme, name: 'theme');

  void setVolume(int newVolume) =>
      set<int>((current) => newVolume, name: 'volume');
}

class _TestNullableHako extends BaseHako {
  _TestNullableHako()
      : super((register) {
          register<String?>(null);
        });

  String? get value => get<String?>();

  void setValue(String? newValue) => set<String?>((current) => newValue);
}

class _TestListHako extends BaseHako {
  _TestListHako()
      : super((register) {
          register<List<int>>([1, 2]);
        });

  List<int> get list => get<List<int>>();

  void setIdentical() => set<List<int>>((current) => current);

  void setSameContent() => set<List<int>>((current) => [1, 2]);
}

class _TestComplexHako extends BaseHako {
  _TestComplexHako()
      : super((register) {
          register<Map<String, List<int>>>({
            'numbers': [1, 2, 3]
          });
        });

  Map<String, List<int>> get complexMap => get<Map<String, List<int>>>();

  void updateMap(Map<String, List<int>> newMap) =>
      set<Map<String, List<int>>>((current) => newMap);
}

class _TestCounterHako extends BaseHako {
  _TestCounterHako()
      : super((register) {
          register<int>(0);
        });

  int get count => get<int>();

  void increment() => set<int>((current) => current + 1);
}

class _TestStringHako extends BaseHako {
  _TestStringHako()
      : super((register) {
          register<String>('initial');
        });

  String get value => get<String>();

  void updateValue(String newValue) => set<String>((current) => newValue);
}
