/// History store backed by shared_preferences.
library;

import 'package:shared_preferences/shared_preferences.dart';

import 'saved_bill.dart';

class HistoryStore {
  static const _key = 'bill_history_v1';
  static const maxEntries = 100;

  static Future<List<SavedBill>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final items = <SavedBill>[];
    for (final s in raw) {
      try {
        items.add(SavedBill.fromJsonString(s));
      } catch (_) {
        // Skip corrupt entries.
      }
    }
    return items;
  }

  static Future<void> add(SavedBill bill) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await load();
    items.insert(0, bill);
    final trimmed = items.take(maxEntries).toList();
    await prefs.setStringList(
        _key, trimmed.map((b) => b.toJsonString()).toList());
  }

  static Future<void> removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await load();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await prefs.setStringList(
          _key, items.map((b) => b.toJsonString()).toList());
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
