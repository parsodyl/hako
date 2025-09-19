/// A key for uniquely identifying state values in a Hako state container.
typedef HakoStateKey = (Type, String?);

/// Extension on [HakoStateKey] that provides convenient access to key
/// properties.
extension HakoStateKeyExtension on HakoStateKey {
  /// Gets the optional name component of this state key.
  ///
  /// Returns the second element of the tuple, which represents an optional
  /// string identifier that can be used to distinguish between multiple
  /// state instances of the same type.
  ///
  /// Returns `null` if no name was provided when the key was created.
  String? get name => $2;
}
