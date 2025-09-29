<h1 align="center">Hako 📦</h1>

<p align="center">
  A state management library for Flutter designed for simplicity, performance, and testability.
  <br /><br />
  <a href="https://pub.dev/packages/hako"><img src="https://img.shields.io/pub/v/hako?style=for-the-badge" /></a>
  <a href="#"><img src="https://img.shields.io/github/workflow/status/parsodyl/hako/main?style=for-the-badge" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/github/license/parsodyl/hako?style=for-the-badge" /></a>
</p>

---

Hako (箱), the Japanese word for *box*, is a state management library built on top of `provider`. It serves as a natural progression for developers who use `provider` directly for state management and need granular state rebuilding and a more structured approach to state organization through an explicit and minimal API.

## Core Features

* **Granular Rebuilding**: Hako selects state values internally. This ensures that widgets listening to a `Hako` container will only rebuild when the specific state values they depend on have changed.
* **Minimal & Explicit API**: The public API is focused on three core operations: registering state in the constructor, reading state with `get()`, and updating state with `set()`.
* **No Code Generation**: The library is built with handwritten Dart and requires no build runners or generated files, keeping the development workflow simple.
* **Testable by Design**: The core logic (`Hako` containers) is decoupled from the Flutter widget tree, allowing for better separation of concerns and straightforward unit testing.
* **State Change Observability**: An optional event stream can be opened to monitor all state access (`ValueGetEvent`) and mutation (`ValueSetEvent`) operations for testing, debugging or logging purposes.

---

## Getting Started

### 1. Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  hako: ^[LATEST_VERSION]
```

Then, run `flutter pub get`.

### 2. Define a Hako Container

Create a class that extends Hako and register your initial state values in the constructor.

```dart
import 'package:hako/hako.dart';

class CounterHako extends Hako {
  // register all initial state values in the constructor.
  CounterHako() : super((register) {
    register<int>(0);
  });

  // (optional) expose state with getters for convenient access.
  int get count => get<int>();

  // expose methods to modify the state.
  void increment() => set<int>((current) => current + 1);
}
```

### 3. Provide the Container

Use `HakoProvider` to make the `CounterHako` instance available to the widget tree.

```dart
import 'package:flutter/material.dart';
import 'package.hako/hako.dart';

void main() {
  runApp(
    HakoProvider(
      create: (_) => CounterHako(),
      child: const MyApp(),
    ),
  );
}
```

### 4. Use it in your Widgets

Use the `BuildContext` extensions to access and listen to your state.

- `context.watchHakoState<H,T>()`: Listens to a specific piece of state and rebuilds the widget when it changes.

- `context.getHako<H>()`: Gets the `Hako` container instance without listening to state changes, perfect for calling methods.

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // use watchHakoState to subscribe to the counter int state.
    final count = context.watchHakoState<CounterHako, int>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hako Example')),
      body: Center(
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // use getHako to access the container for method calls.
        onPressed: () => context.getHako<CounterHako>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Advanced Usage: Event Stream

For debugging or logging, you can open a stream to observe all events within a Hako instance.

```dart
final myHako = CounterHako();

// (a) open the event stream.
final stream = myHako.openEventStream();

// (b) listen to the stream of events.
stream.listen((event) {
  if (event is ValueSetEvent) {
    print('State changed: key=${event.key}, previous=${event.previous}, new=${event.state}');
  }
});

myHako.increment(); // This will trigger the listener and print the state change.

// (c) close the event stream (and prevent possible memory leaks).
myHako.closeEventStream();
```

## Documentation

For detailed API documentation and examples, visit:

- [Hako Class](https://pub.dev/documentation/hako/latest/hako/Hako-class.html) - Core container class for state management
- [HakoProvider Class](https://pub.dev/documentation/hako/latest/hako/HakoProvider-class.html) - Widget for providing Hako instances to the widget tree
- [HakoBuildContextExtension](https://pub.dev/documentation/hako/latest/hako/HakoBuildContextExtension.html) - Extension methods for accessing Hako state in widgets

# Contribute
If you find a bug, or you would like to see a new feature, please create an issue.
