import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isMusicEnabled = _prefs.getBool('music') ?? true;
    isSoundEnabled = _prefs.getBool('sound') ?? true;
    playerName     = _prefs.getString('playerName') ?? 'Player';
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void startMusic() async {
    if (!isMusicEnabled) return;
    if (_musicPlayer.state == PlayerState.playing) return;
    
    if (_musicPlayer.state == PlayerState.paused) {
      await _musicPlayer.resume();
    } else {
      await _musicPlayer.play(AssetSource('sounds/game-sound.mp3'));
    }
  }

  /// Démarre la musique dédiée au quiz.
  void startQuizMusic() async {
    if (!isMusicEnabled) return;
    await _musicPlayer.play(AssetSource('sounds/quiz-music.mp3'));
  }

  void pauseMusic() async {
    await _musicPlayer.pause();
  }

  void stopMusic() async {
    await _musicPlayer.stop();
  }

  void playClick() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/btn-click.mp3'), mode: PlayerMode.lowLatency);
    }
  }

  void playWin() async {
    if (isSoundEnabled) {
      await _musicPlayer.pause();
      await _effectPlayer.play(AssetSource('sounds/victory.mp3'));
      _effectPlayer.onPlayerComplete.first.then((_) {
        if (isMusicEnabled) _musicPlayer.resume();
      });
    }
  }

  void playGameStart() async {
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

  void playCountdownGo() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/game-start.mp3'));
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

  void toggleMusic(bool value) {
    isMusicEnabled = value;
    _prefs.setBool('music', value);
    if (isMusicEnabled) { startMusic(); } else { stopMusic(); }
  }

  void toggleSound(bool value) {
    isSoundEnabled = value;
    _prefs.setBool('sound', value);
  }

  void updatePlayerName(String name) {
    playerName = name;
    _prefs.setString('playerName', name);
  }
}

final settingsManager = SettingsManager();
