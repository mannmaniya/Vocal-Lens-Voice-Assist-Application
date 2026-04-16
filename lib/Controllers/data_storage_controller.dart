import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class DataStorageController with ChangeNotifier {
  final GetStorage _storage = GetStorage();
  final List<String> _history = [];
  final List<String> _favoritesList = [];
  final List<String> _pinnedList = [];

  List<String> get history => _history;
  List<String> get favoritesList => _favoritesList;
  List<String> get pinnedList => _pinnedList;

  Future<void> loadPreferences() async {
    _history
        .addAll((_storage.read<List<dynamic>>('history') ?? []).cast<String>());
    _favoritesList.addAll(
        (_storage.read<List<dynamic>>('favorites') ?? []).cast<String>());
    _pinnedList
        .addAll((_storage.read<List<dynamic>>('pinned') ?? []).cast<String>());
    notifyListeners();
  }

  void addToFavorites(String response) {
    if (!_favoritesList.contains(response)) {
      _favoritesList.add(response);
      _saveFavorites();
      notifyListeners();
    }
  }

  void _saveFavorites() => _storage.write('favorites', _favoritesList);
  void _saveHistory() => _storage.write('history', _history);
  void _savePinned() => _storage.write('pinned', _pinnedList);
}
