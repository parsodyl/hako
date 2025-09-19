part of 'base_hako.dart';

/// A Provider widget that provides a specific Hako instance to its descendants
/// and rebuilds dependents whenever a 'set' operation is correctly performed.
///
/// [HakoProvider] exposes a Hako instance to the widget tree, enabling
/// descendants to access and react to state changes. It automatically
/// rebuilds listening widgets when state modifications occur through the
/// Hako's `set` method.
///
/// [HakoProvider] offers two constructors:
/// - The default constructor for creating new Hako instances
/// - The `.value` constructor for providing existing instances
///
/// When providing an existing instance using `.value`, the instance will not
/// be automatically disposed when the provider is removed from the widget tree.
///
/// Example:
/// ```dart
/// // Creating a new instance
/// HakoProvider<CounterHako>(
///   create: (context) => CounterHako(),
///   child: MyApp(),
/// )
///
/// // Providing an existing instance
/// HakoProvider<CounterHako>.value(
///   value: existingCounterHako,
///   child: MyApp(),
/// )
/// ```
class HakoProvider<H extends BaseHako>
    extends ChangeNotifierProvider<_HakoNotifier<H>> {
  /// Creates a new [HakoProvider] that creates and provides a Hako instance
  /// to its descendants.
  ///
  /// [create] A factory function that creates the Hako instance. The function
  /// receives a [BuildContext] and should return a new instance of type [H].
  /// The created instance will be automatically disposed when the provider is
  /// removed from the widget tree.
  ///
  /// [child] The widget below this provider in the tree that will have access
  /// to the Hako instance.
  ///
  /// [lazy] Whether to create the Hako instance lazily (only when first
  /// accessed) or immediately when the provider is created.
  HakoProvider({
    required Create<H> create,
    super.child,
    super.lazy,
    super.key,
  }) : super(
          create: (context) => _HakoNotifier<H>(
            create(context),
            false,
          ),
        );

  /// Creates a new [HakoProvider] that provides an existing Hako instance
  /// to its descendants.
  ///
  /// [value] An existing Hako instance of type [H] to provide to descendants.
  /// This instance will not be automatically disposed when the provider is
  /// removed from the widget tree, allowing for external lifecycle management.
  ///
  /// [child] The widget below this provider in the tree that will have access
  /// to the Hako instance.
  HakoProvider.value({
    required H value,
    super.child,
    super.key,
  }) : super(
          lazy: false,
          create: (context) => _HakoNotifier<H>(
            value,
            true,
          ),
        );
}

/// Extension methods on [BuildContext] for accessing and watching Hako state
/// containers.
///
/// This extension provides the methods to interact with Hako instances
/// provided through [HakoProvider] in the widget tree.
extension HakoBuildContextExtension on BuildContext {
  /// Retrieves a Hako instance of type [H] from the widget tree.
  ///
  /// This method provides direct access to a Hako instance without listening
  /// for changes. Use this when you need to call methods on the Hako instance
  /// or access public properties without triggering widget rebuilds.
  ///
  /// [H] The type of the Hako instance to retrieve. Must extend [BaseHako].
  ///
  /// Returns the Hako instance of type [H] that was provided by a
  /// [HakoProvider] higher up in the widget tree.
  ///
  /// Throws a [HakoProviderNotFoundException] if no [HakoProvider] of type [H]
  /// is found in the widget tree.
  H getHako<H extends BaseHako>() {
    try {
      return read<_HakoNotifier<H>>()._hako;
    } on ProviderNotFoundException catch (e) {
      if (e.valueType == _HakoNotifier<H>) {
        throw HakoProviderNotFoundException<H>(e.widgetType);
      }
      rethrow;
    }
  }

  /// Watches a specific state value in a Hako container and rebuilds the widget
  /// when it changes.
  ///
  /// This method creates a reactive subscription to a state value of type [T]
  /// within a Hako instance of type [H]. The widget will automatically rebuild
  /// whenever the watched state value is modified.
  ///
  /// [H] The type of the Hako instance containing the state. Must extend
  /// [BaseHako].
  ///
  /// [T] The type of the state value to watch.
  ///
  /// [name] An optional identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  /// Defaults to `null`.
  ///
  /// Returns the current value of the state of type [T] with the specified
  /// [name].
  ///
  /// Throws a [HakoProviderNotFoundException] if no [HakoProvider] of type [H]
  /// is found in the widget tree.
  ///
  /// Throws an [ArgumentError] if the state of type [T] with the given [name]
  /// has not been registered in the Hako instance.
  T watchHakoState<H extends BaseHako, T>({String? name}) {
    try {
      final cache = select<_HakoNotifier<H>, (int, T)>((n) {
        final updatedState =
            n._hako.get<T>(name: name, addToEventStream: false);
        return (updatedState.hashCode, updatedState);
      });
      return cache.$2;
    } on ProviderNotFoundException catch (e) {
      if (e.valueType == _HakoNotifier<H>) {
        throw HakoProviderNotFoundException<H>(e.widgetType);
      }
      rethrow;
    }
  }

  /// Watches a state value in a Hako container and applies a filter function,
  /// rebuilding only when the filtered result changes.
  ///
  /// This method creates a reactive subscription to a state value of type [T]
  /// within a Hako instance of type [H], but applies a transformation function
  /// to derive a value of type [R]. The widget will only rebuild when the
  /// result of the filter function changes, providing more granular control
  /// over rebuild behavior.
  ///
  /// Note: The results of consecutive filter function calls are compared by
  /// their content rather than reference equality. This differs from
  /// [watchHakoState], which uses a hash-based comparison that may trigger
  /// rebuilds even when the content is identical but the reference changes.
  ///
  /// [H] The type of the Hako instance containing the state. Must extend
  /// [BaseHako].
  ///
  /// [T] The type of the source state value to watch.
  ///
  /// [R] The type of the filtered/transformed result.
  ///
  /// [filter] A function that transforms the state value of type [T] into a
  /// result of type [R]. This function is called whenever the source state
  /// changes, and the widget rebuilds only if the result differs from the
  /// previous result.
  ///
  /// [name] An optional identifier for the state value. Used when multiple
  /// state values of the same type need to be distinguished.
  /// Defaults to `null`.
  ///
  /// Returns the result of applying the [filter] function to the current
  /// state value of type [T].
  ///
  /// Throws a [HakoProviderNotFoundException] if no [HakoProvider] of type [H]
  /// is found in the widget tree.
  ///
  /// Throws an [ArgumentError] if the state of type [T] with the given [name]
  /// has not been registered in the Hako instance.
  R filterHakoState<H extends BaseHako, T, R>({
    required R Function(T state) filter,
    String? name,
  }) {
    try {
      return select<_HakoNotifier<H>, R>(
        (n) => filter(n._hako.get<T>(name: name, addToEventStream: false)),
      );
    } on ProviderNotFoundException catch (e) {
      if (e.valueType == _HakoNotifier<H>) {
        throw HakoProviderNotFoundException<H>(e.widgetType);
      }
      rethrow;
    }
  }
}

/// Exception thrown when a [HakoProvider] of a specific type is not found
/// in the widget tree.
///
/// This exception is thrown by methods that interact with Hako instances,
/// when they cannot locate a [HakoProvider] of the required type in the
/// widget tree above the current widget.
class HakoProviderNotFoundException<H extends BaseHako> implements Exception {
  /// The type of widget that attempted to access the Hako provider.
  final Type widgetType;

  /// Creates a new [HakoProviderNotFoundException].
  ///
  /// [widgetType] The type of widget that attempted to access the provider.
  const HakoProviderNotFoundException(this.widgetType);

  @override
  String toString() {
    return 'No HakoProvider<${H.toString()}> found in the widget tree above this $widgetType widget.';
  }
}
