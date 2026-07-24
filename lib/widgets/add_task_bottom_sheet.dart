import 'package:flutter/material.dart';
import '../localization.dart';
import '../main.dart';
import '../services/group_service.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String name, String description, String group) onTaskAdded;
  final List<String> availableGroups;

  const AddTaskDialog({
    super.key,
    required this.onTaskAdded,
    required this.availableGroups,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late List<String> _groups;
  String _selectedGroup = 'General';

  @override
  void initState() {
    super.initState();
    _groups = List.from(widget.availableGroups);
    if (!_groups.contains(_selectedGroup)) {
      _groups.add(_selectedGroup);
    }
  }

  void _submit() {
    if (_nameController.text.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onTaskAdded(
        _nameController.text,
        _descController.text,
        _selectedGroup,
      );
    }
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

  Future<String?> _showNewGroupDialog() {
    final TextEditingController groupController = TextEditingController();
    IconData selectedIcon = GroupService.selectableIcons.first;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                AppTranslations.getText(
                  languageNotifier.value,
                  'new_group_title',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: groupController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.getText(
                          languageNotifier.value,
                          'group_name',
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GroupService.selectableIcons.map((icon) {
                        final isSelected = selectedIcon == icon;
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = icon;
                              });
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white24
                                            : Colors.black12),
                                  width: isSelected ? 2 : 1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'cancel'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = groupController.text.trim();
                    if (newName.isNotEmpty) {
                      await GroupService.saveCustomGroup(
                        newName,
                        selectedIcon.codePoint,
                      );
                      if (context.mounted) Navigator.of(context).pop(newName);
                    }
                  },
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'add'),
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
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        AppTranslations.getText(languageNotifier.value, 'add_task_title'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
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
                  vertical: 14,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
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
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  AppTranslations.getText(languageNotifier.value, 'group'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._groups.map((String category) {
                  final isSelected = _selectedGroup == category;
                  final iconData = _getGroupIconData(category);
                  final color = _getGroupColor(category);

                  return Tooltip(
                    message: category,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGroup = category;
                        });
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                          size: 28,
                        ),
                      ),
                    ),
                  );
                }),

                Tooltip(
                  message: AppTranslations.getText(
                    languageNotifier.value,
                    'add_new_group',
                  ),
                  child: InkWell(
                    onTap: () async {
                      final newGroup = await _showNewGroupDialog();
                      if (newGroup != null && newGroup.isNotEmpty) {
                        setState(() {
                          if (!_groups.contains(newGroup)) {
                            _groups.add(newGroup);
                          }
                          _selectedGroup = newGroup;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.black12,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppTranslations.getText(languageNotifier.value, 'cancel'),
            style: const TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppTranslations.getText(languageNotifier.value, 'add')),
        ),
      ],
    );
  }
}
