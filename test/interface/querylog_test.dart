import 'package:adguard_home_client/interface/querylog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'query log parsing preserves unknown reasons and tolerates mixed values',
    () {
      final entry = QueryLogEntry.fromJson({
        'time': '2026-07-10T10:30:00Z',
        'client': '192.0.2.1',
        'question': {'name': 'example.test', 'type': 'AAAA'},
        'answer': [
          {'value': '2001:db8::1'},
        ],
        'reason': 'FilteredFutureReason',
        'elapsedMs': 1.6,
      });

      expect(entry.question, 'example.test');
      expect(entry.questionType, 'AAAA');
      expect(entry.reason, 'FilteredFutureReason');
      expect(entry.blocked, isTrue);
      expect(entry.elapsedMs, 2);
      expect(entry.answers, ['2001:db8::1']);
    },
  );
}
