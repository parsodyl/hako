import 'package:flutter/foundation.dart';
import 'package:hako/src/foundation/foundation.dart';

/// An interface for classes that can receive and handle [HakoEvent]s.
///
/// This interface defines the contract for objects that need to be notified
/// about events occurring within a Hako state container instance.
abstract interface class HakoEventDelegate {
  /// Handles a [HakoEvent] that has occurred within a Hako state container.
  ///
  /// This method is called whenever a relevant event occurs in the associated
  /// Hako state container.
  ///
  /// [event] The event object containing information about what occurred.
  @visibleForTesting
  @protected
  void onEvent(HakoEvent event);
}
