import 'package:flutter_test/flutter_test.dart';
import 'package:form_apps/models/task_model.dart';

void main() {
  group('TaskModel', () {
    test('normalizes legacy group names from persisted tasks', () {
      final task = TaskModel.fromJson({
        'name': 'Review proposal',
        'description': '',
        'date': '01/01/2026 09:00',
        'isCompleted': false,
        'group': 'İş',
        'user': 'alex',
      });

      expect(task.group, 'Work');
      expect(task.owner, 'alex');
    });

    test('uses General for a task without a stored group', () {
      final task = TaskModel.fromJson({
        'name': 'Plan week',
        'description': '',
        'date': '01/01/2026 09:00',
        'user': 'alex',
      });

      expect(task.group, 'General');
      expect(task.isCompleted, isFalse);
    });
  });
}
