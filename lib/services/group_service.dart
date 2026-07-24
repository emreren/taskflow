import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  static Map<String, int> customGroupIcons = {};
  static String? _username;

  static String _storageKeyFor(String username) =>
      'custom_group_icons_$username';

  /// Loads the custom groups belonging to [username], replacing whatever
  /// groups were previously loaded for another user. Must be called whenever
  /// the active account changes (e.g. right after login).
  static Future<void> loadForUser(String username) async {
    _username = username;
    customGroupIcons = {};

    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_storageKeyFor(username));
    if (dataString != null) {
      final Map<String, dynamic> decoded = jsonDecode(dataString);
      customGroupIcons = decoded.map(
        (key, value) => MapEntry(key, value as int),
      );
    }
  }

  /// Permanently removes the stored custom groups for [username]. Should be
  /// called when an account is deleted.
  static Future<void> deleteUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKeyFor(username));
    if (_username == username) {
      customGroupIcons = {};
    }
  }

  static Future<void> saveCustomGroup(
    String groupName,
    int iconCodePoint,
  ) async {
    customGroupIcons[groupName] = iconCodePoint;
    await _persist();
  }

  static Future<void> deleteCustomGroup(String groupName) async {
    customGroupIcons.remove(groupName);
    await _persist();
  }

  static Future<void> reorderGroup(int oldIndex, int newIndex) async {
    final keys = customGroupIcons.keys.toList();
    if (oldIndex < 0 ||
        oldIndex >= keys.length ||
        newIndex < 0 ||
        newIndex >= keys.length) {
      return;
    }

    final key = keys.removeAt(oldIndex);
    keys.insert(newIndex, key);
    customGroupIcons = {for (final k in keys) k: customGroupIcons[k]!};
    await _persist();
  }

  static Future<void> _persist() async {
    if (_username == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKeyFor(_username!),
      jsonEncode(customGroupIcons),
    );
  }

  static const List<IconData> selectableIcons = [
    Icons.fitness_center_rounded,
    Icons.directions_run_rounded,
    Icons.shopping_cart_rounded,
    Icons.local_grocery_store_rounded,
    Icons.flight_takeoff_rounded,
    Icons.directions_car_rounded,
    Icons.music_note_rounded,
    Icons.book_rounded,
    Icons.movie_creation_rounded,
    Icons.videogame_asset_rounded, // Oyun
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.pets_rounded,
    Icons.favorite_rounded,
    Icons.monetization_on_rounded, // Finans/Para
    Icons.computer_rounded,
    Icons.brush_rounded,
    Icons.build_rounded,
    Icons.event_rounded,
    Icons.label_important_rounded, // Varsayılan Özel
  ];

  static Color getColorForGroup(String group) {
    final colors = [
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.deepOrange,
      Colors.green,
      Colors.redAccent,
    ];

    int hash = 0;
    for (int i = 0; i < group.length; i++) {
      hash = hash + group.codeUnitAt(i);
    }
    return colors[hash % colors.length];
  }
}
