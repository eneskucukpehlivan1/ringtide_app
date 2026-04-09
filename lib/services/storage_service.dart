import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _bestScoreKey = 'best_score';

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, score);
  }
}
