import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hako/src/contracts/hako_events_contract.dart';

/// A mixin that provides event streaming capabilities for Hako events.
///
/// This mixin implements the [HakoEventDelegate] interface and provides
/// functionality to stream [HakoEvent]s through an internal sink. It allows
/// components to open an event stream, receive events through the [onEvent]
/// method, and close the stream when it's no longer needed.
mixin HakoEventStreamMixin implements HakoEventDelegate {
  /// The current event stream and its associated sink.
  ///
  /// This tuple contains both the sink that receives [HakoEvent]s and the
  /// corresponding stream. Both are set when [openEventStream] is called
  /// and cleared when [closeEventStream] is called to ensure they're
  /// always coupled together.
  ({Sink<HakoEvent> sink, Stream<HakoEvent> stream})? _eventStreamPair;

  /// Handles a [HakoEvent] by adding it to the event sink if one is available.
  ///
  /// Events are forwarded to the current event sink, allowing subscribers
  /// to receive notifications about Hako events.
  /// If no sink is available (e.g., if [openEventStream] hasn't been called
  /// or [closeEventStream] has been called), the event is silently ignored
  /// and no error is thrown.
  ///
  /// [event] The event to be processed and forwarded to subscribers.
  @override
  @visibleForTesting
  @protected
  void onEvent(HakoEvent event) => _eventStreamPair?.sink.add(event);

  /// Closes the current event stream and cleans up resources.
  ///
  /// This method should be called when the event stream is no longer needed
  /// to prevent memory leaks. After calling this method, events passed to
  /// [onEvent] will be ignored until [openEventStream] is called again.
  void closeEventStream() {
    _eventStreamPair?.sink.close();
    _eventStreamPair = null;
  }

  /// Creates and returns a stream of Hako events.
  ///
  /// This stream allows you to monitor all events that occur within this Hako
  /// container. Multiple listeners can subscribe to the same stream to receive
  /// notifications.
  ///
  /// If called multiple times while the stream is open, this method will
  /// return the same stream instance. A new stream instance is only created
  /// when the previous stream has been closed via [closeEventStream].
  ///
  /// Returns a broadcast stream that will emit events until [closeEventStream]
  /// is called.
  Stream<HakoEvent> openEventStream() {
    if (_eventStreamPair == null) {
      final controller = StreamController<HakoEvent>();
      final stream = controller.stream.asBroadcastStream();
      _eventStreamPair = (sink: controller, stream: stream);
    }
    return _eventStreamPair!.stream;
  }

  /// Returns whether the event stream is currently open.
  ///
  /// This getter returns `true` if [openEventStream] has been called and
  /// [closeEventStream] has not been called yet, `false` otherwise.
  bool get isEventStreamOpen => _eventStreamPair != null;
}
