import 'package:flutter/widgets.dart';
import 'package:hako/src/event_stream/hako_event_stream_mixin.dart';
import 'package:hako/src/contracts/hako_modifiers_contract.dart';
import 'package:hako/src/event_stream/hako_state_events.dart';
import 'package:hako/src/foundation/hako_state_key.dart';
import 'package:hako/src/hako.dart';
import 'package:provider/provider.dart';

part 'hako_provider.dart';

/// A callback function for registering initial state values in a Hako
/// state container.
typedef RegisterCallback = void Function<T>(T value, {String? name});

/// Base abstract class for Hako state containers.
///
/// {@template base_hako}
/// Hako classes provide the foundation for creating state containers
/// with automatic change tracking and event emission capabilities.
///
/// All state values must be registered during construction and can then be
/// safely accessed and modified throughout the container's lifecycle.
///
/// ## Lifecycle
///
/// 1. **Registration**: All state values must be declared upfront in the
///    constructor using the provided registrar callback
/// 2. **Usage**: Access state with `get<T>()` and update with `set<T>()`
/// 3. **Disposal**: Call `dispose()` to clean up resources when no longer
/// needed
///
/// ## Event stream
///
/// Hako classes include an integrated event system that emits events for state
/// operations when the event stream is open. This enables testing, monitoring,
/// debugging, and any other possible reactive behaviors:
///
/// - **[ValueGetEvent]**: Emitted when state is accessed via `get<T>()`
/// - **[ValueSetEvent]**: Emitted when state is modified via `set<T>()`
///
/// Events are only emitted when `isEventStreamOpen` returns `true`. The event
/// stream can be controlled through the [HakoEventStreamMixin] methods and is
/// automatically closed when `dispose()` is called.
///
/// Example usage for testing or debugging:
/// ```dart
/// final hako = MyHako();
/// final stream = hako.openEventStream();
/// stream.listen((event) {
///   if (event is ValueSetEvent<int>) {
///     print('Counter changed from ${event.previous} to ${event.state}');
///   }
/// });
/// ```
///
/// ## Type safety
///
/// All state operations are type-safe and require explicit type parameters.
/// State values should be registered with their exact types during
/// construction, and subsequent access must use the same types.
/// Nullable types must be explicitly declared (e.g., `register<String?>(null)`
/// instead of `register(null)`).
///
/// ## Optional names
///
/// State values can be registered with optional string names to allow
/// multiple instances of the same type within a single Hako container.
/// This is useful when you need to store several values of the same type
/// that serve different purposes.
///
/// The combination of type and name creates a unique key that identifies
/// each piece of state within the container. This key is used consistently
/// across all operations - you must use the same type and name combination
/// when registering, accessing, and modifying a specific state value.
///
/// Unnamed state (where name is `null`) and named state of the same type
/// are treated as completely separate and independent state values.
///
/// ## Error handling
///
/// - Attempting to register the same state type and name combination twice
///   throws a [StateError]
/// - Accessing or modifying unregistered state throws an [ArgumentError]
/// - Registering null values with generic types (Null or dynamic) throws
///   an [AssertionError]
///   {@endtemplate}
///
/// This abstract class should not be extended directly for final usage.
/// Instead, extend [Hako] or create more specific base classes that extend
/// this class.
abstract class BaseHako
    with HakoEventStreamMixin
    implements HakoStateGetter, HakoStateSetter {
  /// Creates a new instance and registers initial state values.
  ///
  /// This constructor takes a registrar function that is immediately called
  /// with a [RegisterCallback] to allow subclasses to declare and initialize
  /// all their state values upfront. The registrar pattern ensures that all
  /// state is defined during construction, enabling type-safe access
  /// throughout the container's lifecycle.
  ///
  /// The provided [registrar] function should call the register callback
  /// for each state value that needs to be managed by this Hako instance.
  /// Each state value must be registered with its exact type and an optional
  /// name for disambiguation when multiple values of the same type are needed.
  ///
  /// Example usage in a subclass:
  /// ```dart
  /// class CounterHako extends BaseHako {
  ///   CounterHako() : super((register) {
  ///     register<int>(0);
  ///     register<String>('idle');
  ///     register<bool>(false);
  ///     register<String>('primary', name: 'theme');
  ///   });
  /// }
  /// ```
  ///
  /// [registrar] A function that receives a [RegisterCallback] and should
  /// use it to register all initial state values for this Hako instance.
  /// The function is called immediately during construction to populate
  /// the internal state map.
  BaseHako(void Function(RegisterCallback register) registrar) {
    registrar(_registerInitialState);
  }

  final _stateMap = <HakoStateKey, Object?>{};

  VoidCallback? _onSetCalled;

  bool _hasKey<T>([String? name]) => _stateMap.containsKey((T, name));

  void _registerInitialState<T>(T value, {String? name}) {
    assert(
      value != null || (value == null && T != Null && T != dynamic),
      "Cannot register null values with generic types (Null or dynamic). "
      "When registering nullable state, specify the exact type: "
      "register<String?>(null) instead of register(null)",
    );
    final alreadyExists = _stateMap.containsKey((T, name));
    if (alreadyExists) {
      throw StateError(
        'Piece of state of type "$T"  ${name != null ? 'and name "$name" ' : '(no name) '}already registered.',
      );
    }
    _stateMap[(T, name)] = value;
  }

  /// {@macro hako_state_get}
  ///
  /// [addToEventStream] Whether to emit a [ValueGetEvent] to the event stream
  /// when the stream is open. Defaults to `true`. Set to `false` to access
  /// state silently without notifying event stream listeners.
  ///
  /// Returns the current value of the requested state of type [T].
  ///
  /// Throws an [ArgumentError] if the state of type [T] with the given [name]
  /// has not been registered.
  @override
  @visibleForTesting
  @protected
  T get<T>({String? name, bool addToEventStream = true}) {
    if (!_hasKey<T>(name)) {
      throw ArgumentError(
        'Piece of state of type "$T" ${name != null ? 'and name "$name" ' : '(no name) '}not found. You must register it in the constructor of your Hako class before trying to get it.',
      );
    }
    final state = _stateMap[(T, name)] as T;
    if (addToEventStream) {
      onEvent(ValueGetEvent<T>(name: name, state));
    }
    return state;
  }

  /// {@macro hako_state_set}
  ///
  /// [addToEventStream] Whether to emit a [ValueSetEvent] to the event stream
  /// when the stream is open. Defaults to `true`. Set to `false` to update
  /// state silently without notifying event stream listeners.
  ///
  /// The state is only updated if the new value is not identical to the current
  /// value (using [identical] comparison). If an update occurs, widgets that
  /// watch this state will be automatically rebuilt.
  ///
  /// Throws an [ArgumentError] if the state of type [T] with the given [name]
  /// has not been registered.
  @override
  @visibleForTesting
  @protected
  void set<T>(T Function(T current) updater,
      {String? name, bool addToEventStream = true}) {
    if (!_hasKey<T>(name)) {
      throw ArgumentError(
        'Piece of state of type "$T" ${name != null ? 'and name "$name" ' : '(no name) '}not found. You must register it in the constructor of your Hako class before setting it to a new value.',
      );
    }
    final previous = _stateMap[(T, name)] as T;
    final state = updater(previous);
    if (!identical(previous, state)) {
      _stateMap[(T, name)] = state;
      if (addToEventStream) {
        onEvent(ValueSetEvent<T>(name: name, previous, state));
      }
      _onSetCalled?.call();
    }
  }

  /// Disposes of resources associated with this Hako instance.
  ///
  /// This method provides a hook for subclasses to override and perform
  /// cleanup operations when the Hako instance is being disposed. The default
  /// implementation just closes the event stream when open to stop emitting
  /// events.
  ///
  /// Subclasses should call `super.dispose()` when overriding this method
  /// to ensure proper cleanup of base resources. The actual lifecycle
  /// management and when this method is called depends on the concrete
  /// implementation.
  @mustCallSuper
  void dispose() {
    closeEventStream();
  }
}

class _HakoNotifier<H extends BaseHako> extends ChangeNotifier {
  final H _hako;
  final bool doNotDispose;

  _HakoNotifier(H hako, this.doNotDispose) : _hako = hako {
    _hako._onSetCalled = notifyListeners;
  }

  @override
  void dispose() {
    if (!doNotDispose) {
      _hako.dispose();
    }
    _hako._onSetCalled = null;
    super.dispose();
  }
}
