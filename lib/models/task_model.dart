class TaskModel {
  TaskModel({
    required this.name,
    required this.description,
    required this.createdAt,
    required this.owner,
    this.completedAt,
    this.isCompleted = false,
    this.group = 'General',
  });

  String name;
  String description;
  String createdAt;
  String? completedAt;
  bool isCompleted;
  String group;
  String owner;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'date': createdAt,
    'completedDate': completedAt,
    'isCompleted': isCompleted,
    'group': group,
    'user': owner,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    name: json['name'] as String,
    description: json['description'] as String,
    createdAt: json['date'] as String,
    completedAt: json['completedDate'] as String?,
    isCompleted: json['isCompleted'] as bool? ?? false,
    group: _normalizedGroup(json['group'] as String?),
    owner: json['user'] as String,
  );

  static String _normalizedGroup(String? group) {
    const legacyGroups = {
      'Genel': 'General',
      'Ev': 'Home',
      'İş': 'Work',
      'Okul': 'School',
    };
    return legacyGroups[group] ?? group ?? 'General';
  }
}
