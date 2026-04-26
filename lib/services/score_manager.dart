import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static final ScoreManager _instance = ScoreManager._internal();
  factory ScoreManager() => _instance;
  ScoreManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;
  static const int _maxEntries = 10;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  Future<List<ScoreEntry>> getScores(String gameMode) async {
    await _ensureInit();
    final String key  = _keyFor(gameMode);
    final String? raw = _prefs.getString(key);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  Future<int> getBestScore(String gameMode) async {
    final scores = await getScores(gameMode);
    return scores.isEmpty ? 0 : scores.first.score;
  }

  Future<void> saveScore({
    required int score,
    required int maxScore,
    required String gameMode,
    required String playerName,
    required String gameName,
    String? opponentName,
    bool? won,
    String? finalScore,
  }) async {
    await _ensureInit();

    final entry = ScoreEntry(
      score: score,
      maxScore: maxScore,
      gameMode: gameMode,
      playerName: playerName,
      gameName: gameName,
      date: DateTime.now(),
      opponentName: opponentName,
      won: won,
      finalScore: finalScore,
    );

    final scores = await getScores(gameMode);
    scores.add(entry);

    scores.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = scores.take(_maxEntries).toList();

    final String key     = _keyFor(gameMode);
    final String encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
  }

  Future<void> clearScores(String gameMode) async {
    await _ensureInit();
    await _prefs.remove(_keyFor(gameMode));
  }

  String _keyFor(String gameMode) => 'best_scores_$gameMode';
}

class ScoreEntry {
  final int score;
  final int maxScore;
  final String gameMode;
  final String gameName;
  final String playerName;
  final DateTime date;
  final String? opponentName; // Pour le mode Versus
  final bool? won;            // true = gagné, false = perdu
  final String? finalScore;   // "3-1", "2-3", etc.

  const ScoreEntry({
    required this.score,
    required this.maxScore,
    required this.gameMode,
    required this.gameName,
    required this.playerName,
    required this.date,
    this.opponentName,
    this.won,
    this.finalScore,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    score:        json['score']        as int,
    maxScore:     json['maxScore']     as int,
    gameMode:     json['gameMode']     as String,
    gameName:     (json['gameName']    as String?) ?? 'QUIZ',
    playerName:   json['playerName']   as String,
    date:         DateTime.parse(json['date'] as String),
    opponentName: json['opponentName'] as String?,
    won:          json['won']          as bool?,
    finalScore:   json['finalScore']   as String?,
  );

  Map<String, dynamic> toJson() => {
    'score':        score,
    'maxScore':     maxScore,
    'gameMode':     gameMode,
    'gameName':     gameName,
    'playerName':   playerName,
    'date':         date.toIso8601String(),
    'opponentName': opponentName,
    'won':          won,
    'finalScore':   finalScore,
  };

  double get ratio => maxScore > 0 ? score / maxScore : 0;
}

final scoreManager = ScoreManager();