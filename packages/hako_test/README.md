# hako_test

Official testing utilities for [Hako](https://pub.dev/packages/hako) state management.

`hako_test` makes testing Hako state containers intuitive, fast, and robust by providing declarative test runners, event stream assertion utilities, and type-safe matchers.

---

## Installation

Add `hako_test` to your `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  hako_test: ^[LATEST_VERSION]
```

---

## Features

- **`hakoTest`**: A declarative test runner that automates setup, action execution, event assertion, state verification, and resource disposal.
- **`expectHakoEmits`**: Stream assertion utility to assert event sequences in order with guaranteed cleanup.
- **Match helper functions**: Type-safe matchers including `isGetEvent<T>()` and `isSetEvent<T>()`.

---

## Usage

### 1. Declarative testing with `hakoTest`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hako_test/hako_test.dart';
import 'package:my_app/counter_hako.dart';

void main() {
  group('CounterHako', () {
    hakoTest<CounterHako>(
      'emits [SetEvent(0, 1)] when increment() is called',
      build: () => CounterHako(),
      act: (hako) => hako.increment(),
      expect: () => [
        const SetEvent<int>(0, 1),
      ],
      verify: (hako) {
        expect(hako.count, equals(1));
      },
    );

    hakoTest<CounterHako>(
      'supports setUp and multiple operations',
      build: () => CounterHako(),
      setUp: (hako) => hako.increment(), // Initial state prepared before assertion
      act: (hako) => hako.increment(),
      expect: () => [
        const SetEvent<int>(1, 2),
      ],
      verify: (hako) {
        expect(hako.count, equals(2));
      },
    );
  });
}
```

---

### 2. Stream assertions with `expectHakoEmits`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hako_test/hako_test.dart';

void main() {
  test('increments counter and emits events', () async {
    final counter = CounterHako();

    await expectHakoEmits<CounterHako>(
      counter,
      (hako) => hako.increment(),
      [
        const SetEvent<int>(0, 1),
      ],
    );
  });
}
```

---

### 3. Custom Event Matchers

```dart
hakoTest<CounterHako>(
  'matches events using isSetEvent and isGetEvent matchers',
  build: () => CounterHako(),
  act: (hako) {
    hako.count;
    hako.increment();
  },
  expect: () => [
    isGetEvent<int>(state: 0),
    isSetEvent<int>(previous: 0, current: 1),
  ],
);
```

---

## License

MIT
