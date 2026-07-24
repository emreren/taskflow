import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../localization.dart';
import '../main.dart';
import '../services/group_service.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  final Function(String) onGroupChanged;

  final VoidCallback onUpdate;

  final List<String> availableGroups;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onGroupChanged,
    required this.onUpdate,
    required this.availableGroups,
  });

  Icon _getGroupIcon(String group) {
    return Icon(_getGroupIconData(group), color: _getGroupColor(group));
  }

  IconData _getGroupIconData(String group) {
    if (GroupService.customGroupIcons.containsKey(group)) {
      return IconData(
        // ignore: non_const_argument_for_const_parameter
        GroupService.customGroupIcons[group]!,
        fontFamily: 'MaterialIcons',
      );
    }
    switch (group) {
      case 'School':
        return Icons.school;
      case 'Home':
        return Icons.home;
      case 'Work':
        return Icons.work;
      case 'General':
        return Icons.task;
      default:
        return Icons.label_important_rounded;
    }
  }

  Color _getGroupColor(String group) {
    if (GroupService.customGroupIcons.containsKey(group)) {
      return GroupService.getColorForGroup(group);
    }
    switch (group) {
      case 'School':
        return Colors.blue;
      case 'Home':
        return Colors.orange;
      case 'Work':
        return Colors.teal;
      case 'General':
        return Colors.blueGrey;
      default:
        return Colors.purple;
    }
  }

  void _showTaskDetailsDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: task.name,
    );
    final TextEditingController descController = TextEditingController(
      text: task.description,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.getText(
                        languageNotifier.value,
                        'task_name',
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.getText(
                        languageNotifier.value,
                        'task_desc',
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Text(
                      '${AppTranslations.getText(languageNotifier.value, 'group')}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableGroups.map((String category) {
                      final isSelected = task.group == category;
                      final iconData = _getGroupIconData(category);
                      final color = _getGroupColor(category);

                      return Tooltip(
                        message: category,
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              task.group = category;
                            });
                            onGroupChanged(category);
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white24
                                          : Colors.black12),
                                width: isSelected ? 2 : 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected ? color : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    '${AppTranslations.getText(languageNotifier.value, 'created_at')}: ${task.createdAt}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  if (task.isCompleted && task.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${AppTranslations.getText(languageNotifier.value, 'completed_at')}: ${task.completedAt}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    onDelete();
                  },
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'close'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    task.name = nameController.text.trim();
                    task.description = descController.text.trim();
                    if (task.name.isNotEmpty) {
                      onUpdate();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'update'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              onToggleCompletion();
            },
          ),

          title: Text(
            task.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: task.isCompleted
                  ? Colors.grey
                  : Theme.of(context).textTheme.bodyLarge?.color,

              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),

          subtitle: Text(
            task.description,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),

          trailing: _getGroupIcon(task.group),

          onTap: () {
            _showTaskDetailsDialog(context);
          },
        ),
      ),
    );
  }
}
