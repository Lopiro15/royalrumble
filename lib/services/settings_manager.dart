import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// SettingsManager — Singleton de gestion des préférences et sons
//
// Sons disponibles (assets/sounds/) :
//   btn-click.mp3   → clic bouton
//   game-sound.mp3  → musique menu (loop)
//   game-start.mp3  → jingle lancement (court)
//   victory.mp3     → victoire fin de partie
//   losing.mp3      → défaite fin de partie
//
// Sons à ajouter dans assets/sounds/ pour les nouvelles fonctions :
//   quiz-music.mp3  → musique de fond pendant les quiz (loop)
// ---------------------------------------------------------------------------
class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

  // Deux lecteurs séparés : musique (loop) et effets (one-shot)
  final AudioPlayer _musicPlayer  = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool   isMusicEnabled = true;
  bool   isSoundEnabled = true;
  String playerName     = 'Player';

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  /// Charge les préférences sauvegardées et configure la musique en loop.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isMusicEnabled = _prefs.getBool('music') ?? true;
    isSoundEnabled = _prefs.getBool('sound') ?? true;
    playerName     = _prefs.getString('playerName') ?? 'Player';
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // ---------------------------------------------------------------------------
  // Musique de fond
  // ---------------------------------------------------------------------------

  /// Démarre la musique du menu principal (loop).
  void startMusic() async {
    if (isMusicEnabled) {
      await _musicPlayer.play(AssetSource('sounds/game-sound.mp3'));
    }
  }

  /// Démarre la musique dédiée à la partie quiz (loop).
  /// Utilise quiz-music.mp3 si disponible, sinon game-sound.mp3.
  void startQuizMusic() async {
    if (!isMusicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('sounds/quiz-music.mp3'));
    } catch (_) {
      // Fallback si quiz-music.mp3 n'existe pas encore
      await _musicPlayer.play(AssetSource('sounds/game-sound.mp3'));
    }
  }

  /// Arrête toute musique de fond.
  void stopMusic() async {
    await _musicPlayer.stop();
  }

  // ---------------------------------------------------------------------------
  // Effets sonores
  // ---------------------------------------------------------------------------

  /// Son de clic sur un bouton.
  void playClick() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/btn-click.mp3'));
    }
  }

  /// Son joué au lancement d'une partie (jingle court).
  void playGameStart() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/game-start.mp3'));
    }
  }

  /// Son "GO !" joué quand le countdown atteint 0 avant le lancement.
  void playCountdownGo() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/game-start.mp3'));
    }
  }

  /// Son de victoire — coupe la musique de fond.
  void playVictory() async {
    stopMusic();
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/victory.mp3'));
    }
  }

  /// Son de défaite — coupe la musique de fond.
  void playDefeat() async {
    stopMusic();
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/losing.mp3'));
    }
  }

  // ---------------------------------------------------------------------------
  // Préférences
  // ---------------------------------------------------------------------------

  /// Active ou désactive la musique de fond.
  void toggleMusic(bool value) {
    isMusicEnabled = value;
    _prefs.setBool('music', value);
    if (isMusicEnabled) { startMusic(); } else { stopMusic(); }
  }

  /// Active ou désactive les effets sonores.
  void toggleSound(bool value) {
    isSoundEnabled = value;
    _prefs.setBool('sound', value);
  }

  /// Met à jour le pseudo du joueur.
  void updatePlayerName(String name) {
    playerName = name;
    _prefs.setString('playerName', name);
  }
}

final settingsManager = SettingsManager();