import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// ScoreManager — Singleton de gestion des meilleurs scores
//
// Stocke jusqu'à 10 entrées par mode de jeu dans SharedPreferences (JSON).
// Chaque entrée contient : score, playerName, date, gameMode.
//
// Clés SharedPreferences utilisées :
//   'best_scores_solo'         → liste JSON des scores en mode solo
//   'best_scores_duo'          → liste JSON des scores en mode duo
//   'best_scores_entrainement' → liste JSON des scores en mode entraînement
// ---------------------------------------------------------------------------
class ScoreManager {
  // Singleton
  static final ScoreManager _instance = ScoreManager._internal();
  factory ScoreManager() => _instance;
  ScoreManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Nombre maximum d'entrées conservées par mode
  static const int _maxEntries = 10;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Doit être appelé une fois au démarrage (dans main() ou au premier accès).
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// S'assure que le manager est initialisé avant tout accès.
  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  /// Retourne la liste des meilleurs scores pour un mode donné,
  /// triée du meilleur au moins bon.
  Future<List<ScoreEntry>> getScores(String gameMode) async {
    await _ensureInit();
    final String key  = _keyFor(gameMode);
    final String? raw = _prefs.getString(key);
    if (raw == null) return [];

    // Décode le JSON et construit les objets ScoreEntry
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    // Trie du meilleur au moins bon
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  /// Retourne le meilleur score (int) pour un mode, ou 0 si aucun.
  Future<int> getBestScore(String gameMode) async {
    final scores = await getScores(gameMode);
    return scores.isEmpty ? 0 : scores.first.score;
  }

  // ---------------------------------------------------------------------------
  // Écriture
  // ---------------------------------------------------------------------------

  /// Sauvegarde un nouveau score pour le mode donné.
  /// Garde uniquement les [_maxEntries] meilleures entrées.
  Future<void> saveScore({
    required int    score,
    required int    maxScore,
    required String gameMode,
    required String playerName,
    required String gameName,   // Nom du jeu (ex: "QUIZ", "MEMORY"...)
  }) async {
    await _ensureInit();

    // Crée la nouvelle entrée
    final entry = ScoreEntry(
      score:      score,
      maxScore:   maxScore,
      gameMode:   gameMode,
      playerName: playerName,
      gameName:   gameName,
      date:       DateTime.now(),
    );

    // Récupère les scores existants
    final scores = await getScores(gameMode);
    scores.add(entry);

    // Trie et garde uniquement les meilleurs
    scores.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = scores.take(_maxEntries).toList();

    // Sérialise en JSON et sauvegarde
    final String key     = _keyFor(gameMode);
    final String encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
  }

  /// Efface tous les scores d'un mode donné.
  Future<void> clearScores(String gameMode) async {
    await _ensureInit();
    await _prefs.remove(_keyFor(gameMode));
  }

  // ---------------------------------------------------------------------------
  // Utilitaires
  // ---------------------------------------------------------------------------

  /// Retourne la clé SharedPreferences pour un mode de jeu.
  String _keyFor(String gameMode) => 'best_scores_$gameMode';
}

// ---------------------------------------------------------------------------
// ScoreEntry — Modèle d'une entrée de score
// ---------------------------------------------------------------------------
class ScoreEntry {
  final int    score;       // Score obtenu
  final int    maxScore;    // Score maximum possible
  final String gameMode;    // Mode de jeu (solo, duo, entrainement)
  final String gameName;    // Nom du jeu (QUIZ, MEMORY...) — affiché dans le classement
  final String playerName;  // Pseudo du joueur
  final DateTime date;      // Date et heure de la partie

  const ScoreEntry({
    required this.score,
    required this.maxScore,
    required this.gameMode,
    required this.gameName,
    required this.playerName,
    required this.date,
  });

  /// Construit depuis un Map JSON (lecture SharedPreferences).
  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        score:      json['score']      as int,
        maxScore:   json['maxScore']   as int,
        gameMode:   json['gameMode']   as String,
        // Compatibilité ascendante : anciens scores sans gameName → "QUIZ"
        gameName:   (json['gameName']  as String?) ?? 'QUIZ',
        playerName: json['playerName'] as String,
        date:       DateTime.parse(json['date'] as String),
      );

  /// Convertit en Map JSON (écriture SharedPreferences).
  Map<String, dynamic> toJson() => {
        'score':      score,
        'maxScore':   maxScore,
        'gameMode':   gameMode,
        'gameName':   gameName,
        'playerName': playerName,
        'date':       date.toIso8601String(),
      };

  /// Pourcentage de réussite (0.0 → 1.0).
  double get ratio => maxScore > 0 ? score / maxScore : 0;
}

// Instance globale accessible depuis toute l'app
final scoreManager = ScoreManager();