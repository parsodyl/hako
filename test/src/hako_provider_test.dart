import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/base_hako.dart';
import 'package:provider/provider.dart';

void main() {
  group(
    'HakoProvider - create constructor',
    () {
      // Arrange
      final testChild = Container(key: const Key('test-child'));

      testWidgets(
        'should insert a ChangeNotifierProvider in the widget tree and pass the '
        'same child to super constructor',
        (tester) async {
          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                create: (context) => _TestCounterHako(),
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byType(HakoProvider<_TestCounterHako>),
          );
          expect(hakoProvider, isA<ChangeNotifierProvider>());
          expect(find.byKey(const Key('test-child')), findsOneWidget);
        },
      );
      testWidgets(
        'should pass the key parameter correctly to the super constructor '
        'when provided',
        (tester) async {
          // Arrange
          const testKey = Key('test-hako-provider');

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                key: testKey,
                create: (context) => _TestCounterHako(),
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byKey(testKey),
          );
          expect(hakoProvider.key, equals(testKey));
        },
      );
      testWidgets(
        'should handle null key parameter passed to super constructor',
        (tester) async {
          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                key: null,
                create: (context) => _TestCounterHako(),
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byType(HakoProvider<_TestCounterHako>),
          );
          expect(hakoProvider.key, isNull);
        },
      );
      testWidgets(
        'should not create the Hako instance when "lazy" is true (default)',
        (tester) async {
          // Arrange
          _TestCounterHako? createdInstance;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                create: (context) {
                  createdInstance = _TestCounterHako();
                  return createdInstance!;
                },
                child: testChild,
              ),
            ),
          );

          // Assert
          expect(createdInstance, isNull);
        },
      );
      testWidgets(
        'should create the Hako instance when "lazy" is false',
        (tester) async {
          // Arrange
          _TestCounterHako? createdInstance;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                lazy: false,
                create: (context) {
                  createdInstance = _TestCounterHako();
                  return createdInstance!;
                },
                child: testChild,
              ),
            ),
          );

          // Assert
          expect(createdInstance, isNotNull);
          expect(createdInstance?.count, equals(0));
        },
      );
      testWidgets(
        'should lazily create the Hako instance when getHako() is called',
        (tester) async {
          // Arrange
          _TestCounterHako? createdInstance;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                create: (context) {
                  createdInstance = _TestCounterHako();
                  return createdInstance!;
                },
                child: Builder(
                  builder: (context) {
                    final hako = context.readHako<_TestCounterHako>();
                    return Text('${hako.hashCode}');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(createdInstance, isNotNull);
          expect(createdInstance!.count, equals(0));
        },
      );
      testWidgets(
        'should be disposed when the widget tree is torn down',
        (tester) async {
          // Arrange
          _TestCounterHako? createdInstance;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>(
                lazy: false,
                create: (context) {
                  createdInstance = _TestCounterHako();
                  return createdInstance!;
                },
                child: testChild,
              ),
            ),
          );

          // Assert
          expect(createdInstance?.isDisposed, isFalse);

          // Act
          await tester.pumpWidget(const Placeholder());

          // Assert
          expect(createdInstance?.isDisposed, isTrue);
        },
      );
    },
  );
  group(
    'HakoProvider - value constructor',
    () {
      // Arrange
      final testChild = Container(key: const Key('test-child'));

      testWidgets(
        'should insert a ChangeNotifierProvider in the widget tree and pass the '
        'same child to super constructor',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byType(HakoProvider<_TestCounterHako>),
          );
          expect(hakoProvider, isA<ChangeNotifierProvider>());
          expect(find.byKey(const Key('test-child')), findsOneWidget);
        },
      );

      testWidgets(
        'should pass the key parameter correctly to the super constructor '
        'when provided',
        (tester) async {
          // Arrange
          const testKey = Key('test-hako-provider-value');
          final testHako = _TestCounterHako();

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                key: testKey,
                value: testHako,
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byKey(testKey),
          );
          expect(hakoProvider.key, equals(testKey));
        },
      );

      testWidgets(
        'should handle null key parameter passed to super constructor',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                key: null,
                value: testHako,
                child: testChild,
              ),
            ),
          );

          // Assert
          final hakoProvider = tester.widget<HakoProvider<_TestCounterHako>>(
            find.byType(HakoProvider<_TestCounterHako>),
          );
          expect(hakoProvider.key, isNull);
        },
      );

      testWidgets(
        'should provide the exact Hako instance passed as value',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();
          testHako.increment(); // Set initial state to 1
          _TestCounterHako? retrievedHako;

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: Builder(
                  builder: (context) {
                    retrievedHako = context.readHako<_TestCounterHako>();
                    return Text('${retrievedHako.hashCode}');
                  },
                ),
              ),
            ),
          );

          // Assert
          expect(retrievedHako, isNotNull);
          expect(retrievedHako, same(testHako));
          expect(retrievedHako!.count, equals(1));
        },
      );

      testWidgets(
        'should NOT dispose the Hako instance when the widget tree is torn down',
        (tester) async {
          // Arrange
          final testHako = _TestCounterHako();

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: HakoProvider<_TestCounterHako>.value(
                value: testHako,
                child: testChild,
              ),
            ),
          );

          // Assert
          expect(testHako.isDisposed, isFalse);

          // Act - tear down the widget tree
          await tester.pumpWidget(const Placeholder());

          // Assert - the Hako instance should NOT be disposed
          expect(testHako.isDisposed, isFalse);
        },
      );
    },
  );
}

class _TestCounterHako extends BaseHako {
  _TestCounterHako()
      : super((register) {
          register<int>(0);
        });

  bool _disposed = false;

  bool get isDisposed => _disposed;

  int get count => get<int>();

  void increment() => set<int>((current) => current + 1);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
