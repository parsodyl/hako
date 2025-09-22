import 'package:flutter/foundation.dart';

/// An interface for accessing state values from a Hako state container.
///
/// This interface defines the contract for retrieving typed state values from
/// a Hako state container. It provides type-safe access to registered state
/// values through the [get] method.
abstract interface class HakoStateGetter {

  /// {@template hako_state_get}
  /// Retrieves a state value of type [T] from the container.
  ///
  /// This method provides type-safe access to a previously registered state
  /// value.
  ///
  /// [T] The type of the state value to retrieve.
  ///
  /// [name] An optional name identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  /// {@endtemplate}
  @visibleForTesting
  @protected
  T get<T>({String? name});
}

/// An interface for modifying state values in a Hako state container.
///
/// This interface defines the contract for updating typed state values in
/// a Hako state container. It provides type-safe modification of registered
/// state values through the [set] method.
abstract interface class HakoStateSetter {
  /// {@template hako_state_set}
  /// Updates a state value of type [T] in the container.
  ///
  /// This method provides a type-safe way to modify a previously registered
  /// state value. The update is performed using a functional approach where the
  /// current state is passed to the [updater] function, which returns the new
  /// state value.
  ///
  /// [T] The type of the state value to update.
  ///
  /// [updater] A function that receives the current state value and returns
  /// a new state value. This function should be pure and not cause side
  /// effects.
  ///
  /// [name] An optional name identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  /// {@endtemplate}
  @visibleForTesting
  @protected
  void set<T>(T Function(T current) updater, {String? name});
}
