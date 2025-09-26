import 'package:hako/src/foundation/foundation.dart';

/// Base class for events that involve state values in a Hako state container.
abstract class HakoStateEvent<T> extends HakoEvent {
  /// Creates a new [HakoStateEvent] with the specified state value and
  /// optional name.
  ///
  /// [T] The type of the state value.
  /// [state] The current state value involved in the event.
  /// [name] An optional identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  const HakoStateEvent(this.state, {String? name}) : key = (T, name);

  /// The unique identifier key for the state value involved in the event.
  ///
  /// This key is a tuple containing the type [T] and an optional name string,
  /// which together uniquely identify a specific state value within the Hako
  /// container. The key is automatically generated when the event is created.
  final HakoStateKey key;

  /// The current state value involved in the event.
  ///
  /// This contains the state value at the time the event was created.
  /// The type [T] corresponds to the registered type of the state value
  /// in the container.
  final T state;

  /// Returns the optional name identifier for the state value.
  ///
  /// This getter extracts the name component from the [key] tuple. Returns
  /// `null` if no name was specified when the state was registered, or the
  /// name string if one was provided to distinguish between multiple state
  /// values of the same type.
  String? get name => key.name;
}

/// An event that represents the retrieval of a state value from a Hako
/// container.
///
/// This event is emitted whenever a state value is accessed through the `get`
/// method of a Hako instance. It contains information about the retrieved
/// state value and its identifying key.
///
/// The event is useful for testing, debugging, logging, or implementing
/// reactive behaviors that need to track when specific state values are being
/// accessed.
class ValueGetEvent<T> extends HakoStateEvent<T> {
  /// Creates a new [ValueGetEvent] with the specified state value and optional
  /// name.
  ///
  /// [T] The type of the state value.
  /// [state] The state value that was retrieved from the Hako container.
  /// [name] An optional identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  const ValueGetEvent(super.state, {super.name});

  @override
  String toString() {
    return 'ValueGetEvent{key: $key, state: $state}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueGetEvent &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          state == other.state;

  @override
  int get hashCode => Object.hash(key, state);
}

/// An event that represents the modification of a state value in a Hako
/// container.
///
/// This event is emitted whenever a state value is updated through the `set`
/// method of a Hako instance. It contains information about both the previous
/// and new state values, along with their identifying key.
///
/// The event is useful for testing, debugging, logging, or implementing
/// reactive behaviors that need to track when specific state values are being
/// modified and what changes occurred.
class ValueSetEvent<T> extends HakoStateEvent<T> {
  /// Creates a new [ValueSetEvent] with the specified previous and new state
  /// values and optional name.
  ///
  /// [T] The type of the state value.
  /// [previous] The state value that existed before the update operation.
  /// [state] The new state value that was set in the Hako container.
  /// [name] An optional identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  const ValueSetEvent(this.previous, super.state, {super.name});

  /// The state value that existed before the update operation.
  ///
  /// This contains the previous value of the state before it was modified
  /// through the `set` method. The type [T] corresponds to the registered type
  /// of the state value in the container.
  final T previous;

  @override
  String toString() {
    return 'ValueSetEvent{key: $key, previous: $previous, state: $state}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueSetEvent &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          state == other.state &&
          previous == other.previous;

  @override
  int get hashCode => Object.hash(key, previous, state);
}
