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
  }

  void startMusic() async {
    if (isMusicEnabled) {
      await _musicPlayer.play(AssetSource('sounds/game-sound.mp3'));
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

  void toggleMusic(bool value) {
    isMusicEnabled = value;
    _prefs.setBool('music', value);
    if (isMusicEnabled) {
      startMusic();
    } else {
      stopMusic();
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
