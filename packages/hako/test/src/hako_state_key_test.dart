import 'package:flutter_test/flutter_test.dart';
import 'package:hako/src/foundation/hako_state_key.dart';

void main() {
  group(
    'HakoStateKey',
    () {
      test('should create an instance with a Type and null name', () {
        // Arrange & Act
        const type = Map<String, List<double>>;
        const String? name = null;
        const key = (type, name);

        // Assert
        expect(key, isA<HakoStateKey>());
        expect(key.$1, equals(type));
        expect(key.$2, isNull);
        expect(key.name, isNull);
      });
      test('should create an instance with a Type and a non-null name', () {
        // Arrange & Act
        const type = Map<String, List<double>>;
        const name = 'test';
        const key = (type, name);

        // Assert
        expect(key, isA<HakoStateKey>());
        expect(key.$1, equals(type));
        expect(key.$2, equals(name));
        expect(key.name, equals(name));
      });
    },
  );
}
