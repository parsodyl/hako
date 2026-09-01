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
