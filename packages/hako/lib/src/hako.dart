import 'package:hako/src/base_hako.dart';

/// A container for multiple state objects.
///
/// [Hako] is the main class that users should extend to create their own state
/// containers. It provides methods to get and set state values in a type-safe
/// manner, while also tracking state changes for reactivity.
///
/// Example:
/// ```dart
/// class CounterHako extends Hako {
///   CounterHako() : super((register) {
///     register<int>(0); // Register initial state
///   });
///
///   void increment() => set<int>((current) => current + 1);
///
///   int get count => get<int>();
/// }
/// ```
///
/// {@macro base_hako}
abstract class Hako extends BaseHako {
  /// Creates a new [Hako] instance.
  ///
  /// The [registrar] parameter is a callback function where you must register
  /// all initial state values that your Hako instance will manage.
  Hako(super.registrar);
}
