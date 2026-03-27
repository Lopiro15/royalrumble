import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool isMusicEnabled = true;
  bool isSoundEnabled = true;
  String playerName = "Player";

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isMusicEnabled = _prefs.getBool('music') ?? true;
    isSoundEnabled = _prefs.getBool('sound') ?? true;
    playerName = _prefs.getString('playerName') ?? "Player";
    
    _musicPlayer.setReleaseMode(ReleaseMode.loop);

    // Écouteur pour reprendre la musique après le son de victoire
    _effectPlayer.onPlayerComplete.listen((event) {
      if (isMusicEnabled) {
        _musicPlayer.resume();
      }
    });
  }

  void startMusic() async {
    if (isMusicEnabled) {
      if (_musicPlayer.state == PlayerState.paused) {
        await _musicPlayer.resume();
      } else {
        await _musicPlayer.play(AssetSource('sounds/game-sound.mp3'));
      }
    }
  }

  void stopMusic() async {
    await _musicPlayer.stop();
  }

  void playClick() async {
    if (isSoundEnabled) {
      await _effectPlayer.play(AssetSource('sounds/btn-click.mp3'));
    }
  }

  void playWin() async {
    if (isSoundEnabled) {
      // On met la musique en pause
      await _musicPlayer.pause();
      // On joue le son de victoire
      await _effectPlayer.play(AssetSource('sounds/victory.mp3'));
    }
  }

  void toggleMusic(bool value) {
    isMusicEnabled = value;
    _prefs.setBool('music', value);
    if (isMusicEnabled) {
      startMusic();
    } else {
      _musicPlayer.pause();
    }
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
