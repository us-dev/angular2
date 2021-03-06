@TestOn('browser')

import 'package:angular2/angular2.dart';
import 'package:test/test.dart';

void main() {
  group('DatePipe', () {
    DateTime date;
    DatePipe pipe;
    setUp(() {
      date = new DateTime(2015, 6, 15, 21, 43, 11);
      pipe = new DatePipe();
    });
    group('supports', () {
      test('should support date', () {
        expect(pipe.supports(date), true);
      });
      test('should support int', () {
        expect(pipe.supports(123456789), true);
      });
      test('should not support other objects', () {
        expect(pipe.supports(new Object()), false);
        expect(pipe.supports(null), false);
      });
    });
    group('transform', () {
      test('should format each component correctly', () {
        expect(pipe.transform(date, 'y'), '2015');
        expect(pipe.transform(date, 'yy'), '15');
        expect(pipe.transform(date, 'M'), '6');
        expect(pipe.transform(date, 'MM'), '06');
        expect(pipe.transform(date, 'MMM'), 'Jun');
        expect(pipe.transform(date, 'MMMM'), 'June');
        expect(pipe.transform(date, 'd'), '15');
        expect(pipe.transform(date, 'E'), 'Mon');
        expect(pipe.transform(date, 'EEEE'), 'Monday');
        expect(pipe.transform(date, 'H'), '21');
        expect(pipe.transform(date, 'j'), '9 PM');
        expect(pipe.transform(date, 'm'), '43');
        expect(pipe.transform(date, 's'), '11');
      });
      test('should format common multi component patterns', () {
        expect(pipe.transform(date, 'yMEd'), 'Mon, 6/15/2015');
        expect(pipe.transform(date, 'MEd'), 'Mon, 6/15');
        expect(pipe.transform(date, 'MMMd'), 'Jun 15');
        expect(pipe.transform(date, 'yMMMMEEEEd'), 'Monday, June 15, 2015');
        expect(pipe.transform(date, 'jms'), '9:43:11 PM');
        expect(pipe.transform(date, 'ms'), '43:11');
      });
      test('should format with pattern aliases', () {
        expect(pipe.transform(date, 'medium'), 'Jun 15, 2015, 9:43:11 PM');
        expect(pipe.transform(date, 'short'), '6/15/2015, 9:43 PM');
        expect(pipe.transform(date, 'fullDate'), 'Monday, June 15, 2015');
        expect(pipe.transform(date, 'longDate'), 'June 15, 2015');
        expect(pipe.transform(date, 'mediumDate'), 'Jun 15, 2015');
        expect(pipe.transform(date, 'shortDate'), '6/15/2015');
        expect(pipe.transform(date, 'mediumTime'), '9:43:11 PM');
        expect(pipe.transform(date, 'shortTime'), '9:43 PM');
      });
    });
  });
}
