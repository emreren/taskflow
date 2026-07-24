import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import '../main.dart';
import '../localization.dart';
import '../services/group_service.dart';

class TaskPage extends StatefulWidget {
  final String currentUser;

  const TaskPage({super.key, required this.currentUser});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    GroupService.loadForUser(widget.currentUser).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJsonString = prefs.getString('tasks_data');

    if (tasksJsonString != null) {
      final List<dynamic> decodedList = jsonDecode(tasksJsonString);
      setState(() {
        _tasks = decodedList.map((item) => TaskModel.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String tasksJsonString = jsonEncode(
      _tasks.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('tasks_data', tasksJsonString);
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _addTask(String name, String description, String group) {
    setState(() {
      final now = DateTime.now();

      final formattedDate = _formatDate(now);

      _tasks.add(
        TaskModel(
          name: name,
          description: description,
          createdAt: formattedDate,
          group: group,
          owner: widget.currentUser,
        ),
      );
      _saveTasks();
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      final task = _tasks[index];
      task.isCompleted = !task.isCompleted;

      if (task.isCompleted) {
        final now = DateTime.now();

        task.completedAt = _formatDate(now);
      } else {
        task.completedAt = null;
      }
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _updateTaskGroup(int index, String newGroup) {
    setState(() {
      _tasks[index].group = newGroup;
      _saveTasks();
    });
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

  List<String> get _availableGroups {
    final Set<String> groups = {'General', 'Home', 'Work', 'School'};
    for (var task in _tasks) {
      if (task.owner == widget.currentUser) {
        groups.add(task.group);
      }
    }
    groups.addAll(GroupService.customGroupIcons.keys);
    return groups.toList();
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

  Future<void> _confirmDeleteGroup(String group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppTranslations.getText(languageNotifier.value, 'delete_group_title'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          AppTranslations.getText(languageNotifier.value, 'delete_group_desc'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppTranslations.getText(languageNotifier.value, 'cancel'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppTranslations.getText(languageNotifier.value, 'yes')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await GroupService.deleteCustomGroup(group);
    setState(() {
      for (var task in _tasks) {
        if (task.group == group) {
          task.group = 'General';
        }
      }
      _saveTasks();
    });
  }

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.person_rounded, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.currentUser,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Manage sign-in and account data for this profile.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppTranslations.getText(languageNotifier.value, 'close'),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _confirmDeleteAccount();
            },
            child: Text(
              AppTranslations.getText(languageNotifier.value, 'delete_account'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppTranslations.getText(languageNotifier.value, 'delete_account'),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete "${widget.currentUser}" and all of its tasks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppTranslations.getText(languageNotifier.value, 'cancel'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppTranslations.getText(languageNotifier.value, 'yes')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.deleteUser(widget.currentUser);

    _tasks.removeWhere((task) => task.owner == widget.currentUser);
    await _saveTasks();

    await GroupService.deleteUserData(widget.currentUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isDarkMode_${widget.currentUser}');

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _showManageGroupsDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final customGroups = GroupService.customGroupIcons.keys.toList();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Manage groups',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (customGroups.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No custom groups yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(customGroups.length, (
                              index,
                            ) {
                              final group = customGroups[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(_getGroupIconData(group)),
                                title: Text(
                                  group,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Move up',
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                      ),
                                      onPressed: index == 0
                                          ? null
                                          : () async {
                                              await GroupService.reorderGroup(
                                                index,
                                                index - 1,
                                              );
                                              setDialogState(() {});
                                              setState(() {});
                                            },
                                    ),
                                    IconButton(
                                      tooltip: 'Move down',
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                      onPressed:
                                          index == customGroups.length - 1
                                          ? null
                                          : () async {
                                              await GroupService.reorderGroup(
                                                index,
                                                index + 1,
                                              );
                                              setDialogState(() {});
                                              setState(() {});
                                            },
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await _confirmDeleteGroup(group);
                                        setDialogState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final newGroup = await _showNewGroupDialog();
                        if (newGroup != null && newGroup.isNotEmpty) {
                          setDialogState(() {});
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        AppTranslations.getText(
                          languageNotifier.value,
                          'add_new_group',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppTranslations.getText(languageNotifier.value, 'close'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          onTaskAdded: (name, description, group) {
            _addTask(name, description, group);

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      AppTranslations.getText(
                        languageNotifier.value,
                        'success',
                      ),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                content: Text(
                  AppTranslations.getText(
                    languageNotifier.value,
                    'task_added_success',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      AppTranslations.getText(languageNotifier.value, 'ok'),
                    ),
                  ),
                ],
              ),
            );
          },
          availableGroups: _availableGroups,
        );
      },
    );
  }

  Widget _buildTaskList({required bool isCompleted, String? group}) {
    final filteredTasks = _tasks.where((task) {
      final isGroupMatch = group == null || task.group == group;
      return task.isCompleted == isCompleted &&
          task.owner == widget.currentUser &&
          isGroupMatch;
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          isCompleted
              ? AppTranslations.getText(
                  languageNotifier.value,
                  'no_completed_tasks',
                )
              : AppTranslations.getText(
                  languageNotifier.value,
                  'no_pending_tasks',
                ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];

        final originalIndex = _tasks.indexOf(task);

        return TaskTile(
          task: task,
          availableGroups: _availableGroups,
          onToggleCompletion: () => _toggleTaskCompletion(originalIndex),
          onDelete: () => _deleteTask(originalIndex),
          onGroupChanged: (newGroup) =>
              _updateTaskGroup(originalIndex, newGroup),
          onUpdate: () {
            setState(() {
              _saveTasks();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _availableGroups;

    return DefaultTabController(
      key: ValueKey(groups.join(',')),
      length: groups.length + 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                ),
                accountName: Text(
                  widget.currentUser,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentMode, child) {
                  final isDark = currentMode == ThemeMode.dark;
                  return SwitchListTile(
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDark ? Colors.yellow : Colors.blueGrey,
                    ),
                    title: Text(
                      AppTranslations.getText(
                        languageNotifier.value,
                        'dark_mode',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: isDark,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (bool value) async {
                      final newMode = value ? ThemeMode.dark : ThemeMode.light;
                      themeNotifier.value = newMode;

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                        'isDarkMode_${widget.currentUser}',
                        value,
                      );
                      await prefs.setBool('isDarkMode', value);
                    },
                  );
                },
              ),

              const Spacer(),
              const Divider(color: Colors.black12),

              ListTile(
                leading: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.orange,
                ),
                title: Text(
                  AppTranslations.getText(languageNotifier.value, 'logout'),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.manage_accounts_rounded,
                  color: Colors.blueGrey,
                ),
                title: const Text(
                  'Account',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: _showAccountDialog,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppTranslations.getText(languageNotifier.value, 'task_list_title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blueAccent,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: Tooltip(
                          message: AppTranslations.getText(
                            languageNotifier.value,
                            'all_tasks',
                          ),
                          child: const Icon(Icons.list_alt_rounded),
                        ),
                      ),
                      ...groups.map((g) {
                        return Tab(
                          icon: Tooltip(
                            message: g,
                            child: Icon(_getGroupIconData(g)),
                          ),
                        );
                      }),
                      Tab(
                        icon: Tooltip(
                          message: AppTranslations.getText(
                            languageNotifier.value,
                            'completed_tasks',
                          ),
                          child: const Icon(Icons.check_circle_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Manage groups',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _showManageGroupsDialog,
                ),
              ],
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _buildTaskList(isCompleted: false, group: null),
            ...groups.map((g) => _buildTaskList(isCompleted: false, group: g)),
            _buildTaskList(isCompleted: true, group: null),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddTaskDialog,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Text(
            AppTranslations.getText(languageNotifier.value, 'add_task'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add_task_rounded),
        ),
      ),
    );
  }
}
