## 0.0.2

* **SDK Compatibility**: Restored minimum Dart SDK constraint to `>=3.1.0` (Flutter `>=3.13.0`).
* Updated `hako` dependency constraint to `^0.1.1`.

## 0.0.1

* Initial release of `hako_test`.
* Added `expectHakoEmits` for testing reactive event stream emissions on `BaseHako` containers.
* Added `hakoTest` declarative test runner with support for `setUp`, `act`, `expect`, `verify`, and `tearDown`.
* Added custom matchers `isGetEvent` and `isSetEvent`.
