import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';

class _TestCounterHako extends Hako {
  _TestCounterHako()
      : super((register) {
          register<int>(0);
          register<List<int>>([1, 2]);
        });

  void increment() => set<int>((current) => current + 1);

  void setIdentical() => set<List<int>>((current) => current);

  void setSameContent() => set<List<int>>((current) => [1, 2]);
}

Widget _buildTestApp({
  required Function(BuildContext context) onFABPressed,
  required Widget Function(BuildContext context) bodyBuilder,
}) {
  return MaterialApp(
    home: HakoProvider(
      create: (_) => _TestCounterHako(),
      child: Scaffold(
        body: Builder(builder: bodyBuilder),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => onFABPressed(context),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group(
    'HakoProvider watching state',
    () {
      testWidgets(
        'should rebuild widget when watched state changes',
        (WidgetTester tester) async {
          // Arrange: Build the UI with HakoProvider and a test widget.
          await tester.pumpWidget(
            _buildTestApp(
              onFABPressed: (context) =>
                  context.getHako<_TestCounterHako>().increment(),
              bodyBuilder: (context) {
                // Watch the state. This widget will rebuild on changes.
                final count = context.watchHakoState<_TestCounterHako, int>();
                return Text('Count: $count');
              },
            ),
          );

          // Assert: Verify the initial state is correct.
          expect(find.text('Count: 0'), findsOneWidget);
          expect(find.text('Count: 1'), findsNothing);

          // Act: Tap the button to trigger the state change.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: Verify the widget has rebuilt with the new state.
          expect(find.text('Count: 0'), findsNothing);
          expect(find.text('Count: 1'), findsOneWidget);

          // Act: Change the state again.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: Verify the widget has rebuilt with the new state.
          expect(find.text('Count: 1'), findsNothing);
          expect(find.text('Count: 2'), findsOneWidget);
        },
      );

      testWidgets(
        'should NOT rebuild widget when state is set to an identical value',
        (WidgetTester tester) async {
          // Arrange
          List<int>? capturedList;

          await tester.pumpWidget(
            _buildTestApp(
              onFABPressed: (context) =>
                  context.getHako<_TestCounterHako>().setIdentical(),
              bodyBuilder: (context) {
                // Watch the list state.
                final list =
                    context.watchHakoState<_TestCounterHako, List<int>>();
                capturedList = list;
                return Text('List: ${list.join(', ')}');
              },
            ),
          );

          // Assert: The widget built once initially.
          expect(find.text('List: 1, 2'), findsOneWidget);
          final initialList = capturedList;

          // Act: Tap the button to set the identical state.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: The widget did NOT rebuild.
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(capturedList, same(initialList));
        },
      );

      testWidgets(
        'SHOULD rebuild widget when state has same content but different reference',
        (WidgetTester tester) async {
          // Arrange
          List<int>? capturedList;

          await tester.pumpWidget(
            _buildTestApp(
              onFABPressed: (context) =>
                  context.getHako<_TestCounterHako>().setSameContent(),
              bodyBuilder: (context) {
                final list =
                    context.watchHakoState<_TestCounterHako, List<int>>();
                capturedList = list;
                return Text('List: ${list.join(', ')}');
              },
            ),
          );

          // Assert: Initial build and capture the initial list reference.
          expect(find.text('List: 1, 2'), findsOneWidget);
          final initialList = capturedList;

          // Act
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // Assert: The widget rebuilt with the new state.
          expect(find.text('List: 1, 2'), findsOneWidget);
          expect(capturedList, isNot(same(initialList))); // Different reference
          expect(capturedList, equals([1, 2])); // Same content
        },
      );
    },
  );
}
