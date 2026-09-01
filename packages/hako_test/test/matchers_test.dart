import 'package:flutter_test/flutter_test.dart';
import 'package:hako/hako.dart';
import 'package:hako_test/hako_test.dart';

void main() {
  group('isGetEvent', () {
    test('matches GetEvent with matching state', () {
      const event = GetEvent<int>(42);

      expect(event, isGetEvent<int>());
      expect(event, isGetEvent<int>(state: 42));
      expect(event, isNot(isGetEvent<int>(state: 99)));
      expect(event, isNot(isGetEvent<String>()));
    });

    test('matches GetEvent with matching name', () {
      const event = GetEvent<String>('dark', name: 'theme');

      expect(event, isGetEvent<String>(name: 'theme'));
      expect(event, isGetEvent<String>(name: 'theme', state: 'dark'));
      expect(event, isNot(isGetEvent<String>(name: 'other')));
      expect(event, isNot(isGetEvent<String>(name: 'theme', state: 'light')));
    });
  });

  group('isSetEvent', () {
    test('matches SetEvent with matching previous and current', () {
      const event = SetEvent<int>(0, 1);

      expect(event, isSetEvent<int>());
      expect(event, isSetEvent<int>(previous: 0));
      expect(event, isSetEvent<int>(current: 1));
      expect(event, isSetEvent<int>(previous: 0, current: 1));
      expect(event, isNot(isSetEvent<int>(previous: 1, current: 2)));
      expect(event, isNot(isSetEvent<String>()));
    });

    test('matches SetEvent with matching name', () {
      const event = SetEvent<String>('initial', 'updated', name: 'status');

      expect(event, isSetEvent<String>(name: 'status'));
      expect(
        event,
        isSetEvent<String>(
          name: 'status',
          previous: 'initial',
          current: 'updated',
        ),
      );
      expect(event, isNot(isSetEvent<String>(name: 'wrong')));
      expect(
        event,
        isNot(isSetEvent<String>(name: 'status', current: 'other')),
      );
    });
  });
}
