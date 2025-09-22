import 'package:flutter/foundation.dart';

/// Base class for all events that can occur within a Hako state container.
///
/// This abstract class serves as the foundation for all event types that
/// can be dispatched and handled by [HakoEventDelegate] implementations.
/// Events represent various occurrences within the Hako system.
///
/// All concrete event classes should extend this base class to ensure
/// they can be properly handled by the event system.
abstract class HakoEvent {
  /// Constructs a [HakoEvent].
  const HakoEvent();
}

/// An interface for classes that can receive and handle [HakoEvent]s.
///
/// This interface defines the contract for objects that need to be notified
/// about events occurring within a Hako instance.
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
