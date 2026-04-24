import 'dart:math';
import 'package:get/get.dart';
import '../bluetooth/bluetooth_service.dart';
import '../bluetooth/bluetooth_game_handler.dart';

class VersusGameManager {
  final BluetoothService bluetoothService;
  final VersusGameConfig config;
  final bool isHost; // Le joueur qui a initié le défi

  // Scores
  final RxInt hostWins = 0.obs;
  final RxInt guestWins = 0.obs;
  final RxInt currentRound = 0.obs;
  final RxBool isMatchOver = false.obs;

  // Jeux pour chaque manche
  final List<String> roundGames = [];

  // Jeux disponibles (hors Labyrinth)
  static const List<String> availableGames = [
    'QUIZ',
    'CAR ROYAL',
    'METEOR SHOWER',
    'PUZZLE ROYAL',
    'TOUR D\'HANOI',
    'SQUARE CONQUEST',
    'AIR HOCKEY',
  ];

  // Jeux pour la manche décisive
  static const List<String> decisiveGames = [
    'SQUARE CONQUEST',
    'AIR HOCKEY',
  ];

  VersusGameManager({
    required this.bluetoothService,
    required this.config,
    required this.isHost,
  }) {
    _generateGameSequence();
  }

  void _generateGameSequence() {
    final random = Random();
    final List<String> normalGames = List.from(availableGames);
    normalGames.shuffle(random);

    // Réserver un jeu décisif (pas utilisé dans les manches normales)
    final String decisiveGame = decisiveGames[random.nextInt(decisiveGames.length)];

    // Calculer le nombre de manches non décisives
    final int normalRounds = config.totalRounds - 1; // -1 pour la manche décisive

    // Sélectionner les jeux sans doublon
    roundGames.clear();
    int gameIndex = 0;

    for (int i = 0; i < config.totalRounds; i++) {
      // La dernière manche est la décisive si nécessaire
      // (on vérifie si une manche décisive est possible)
      if (i == config.totalRounds - 1 && config.totalRounds > 1) {
        roundGames.add(decisiveGame);
      } else {
        if (gameIndex < normalGames.length && normalGames[gameIndex] != decisiveGame) {
          roundGames.add(normalGames[gameIndex]);
          gameIndex++;
        } else {
          // Fallback
          roundGames.add(normalGames[gameIndex + 1 < normalGames.length ? gameIndex + 1 : 0]);
        }
      }
    }
  }

  String get currentGameName =>
      currentRound.value < roundGames.length ? roundGames[currentRound.value] : 'AIR HOCKEY';

  bool get isDecisiveRound =>
      hostWins.value == config.winsNeeded - 1 && guestWins.value == config.winsNeeded - 1;

  void recordRoundWin(bool hostWon) {
    if (hostWon) {
      hostWins.value++;
    } else {
      guestWins.value++;
    }

    if (hostWins.value >= config.winsNeeded || guestWins.value >= config.winsNeeded) {
      isMatchOver.value = true;
    }
  }

  int get myWins => isHost ? hostWins.value : guestWins.value;
  int get opponentWins => isHost ? guestWins.value : hostWins.value;
  bool get amIWinner => isHost ? hostWins.value >= config.winsNeeded : guestWins.value >= config.winsNeeded;

  Map<String, dynamic> createMessage(VersusMessageType type, {Map<String, dynamic>? data}) {
    return {
      'type': type.name,
      'data': data ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}