import 'dart:math';
import '../bluetooth/bluetooth_game_handler.dart';

class VersusGameManager {
  final bool isHost;
  final VersusGameConfig config;

  int hostWins = 0;
  int guestWins = 0;
  int currentRound = 0;
  bool isMatchOver = false;

  // Jeux pour chaque manche
  final List<String> roundGames = [];

  // Résultats de chaque manche
  final List<Map<String, dynamic>> roundResults = [];

  // Jeux disponibles (hors Labyrinth)
  static const List<String> availableGames = [
    'CAR ROYAL',
    'METEOR SHOWER',
    'PUZZLE ROYAL',
    'TOUR D\'HANOI',
    'SQUARE CONQUEST',
    'AIR HOCKEY',
    'QUIZ',
  ];

  // Jeux pour la manche décisive
  static const List<String> decisiveGames = [
    'SQUARE CONQUEST',
    'AIR HOCKEY',
  ];

  VersusGameManager({
    required this.isHost,
    required this.config,
  }) {
    _generateGameSequence();
  }

  void _generateGameSequence() {
    final random = Random();
    final List<String> games = List.from(availableGames);
    games.shuffle(random);

    // Réserver un jeu décisif
    final String decisiveGame = decisiveGames[random.nextInt(decisiveGames.length)];

    // Retirer le jeu décisif de la liste des jeux normaux
    games.remove(decisiveGame);

    roundGames.clear();
    int gameIndex = 0;

    for (int i = 0; i < config.totalRounds; i++) {
      if (i == config.totalRounds - 1) {
        // Dernière manche = manche décisive
        roundGames.add(decisiveGame);
      } else if (gameIndex < games.length) {
        roundGames.add(games[gameIndex]);
        gameIndex++;
      } else {
        // Fallback
        roundGames.add(games[0]);
        gameIndex = 0;
      }
    }

    debugPrint('🎮 Séquence de jeux: ${roundGames.join(" → ")}');
  }

  String get currentGameName =>
      currentRound < roundGames.length ? roundGames[currentRound] : 'AIR HOCKEY';

  bool get isDecisiveRound =>
      hostWins == config.winsNeeded - 1 && guestWins == config.winsNeeded - 1;

  int get myWins => isHost ? hostWins : guestWins;
  int get opponentWins => isHost ? guestWins : hostWins;
  bool get amIWinner => isHost ? hostWins >= config.winsNeeded : guestWins >= config.winsNeeded;
  bool get isMatchPoint => myWins == config.winsNeeded - 1 || opponentWins == config.winsNeeded - 1;

  void recordRoundWin(bool hostWon) {
    if (hostWon) {
      hostWins++;
    } else {
      guestWins++;
    }

    roundResults.add({
      'round': currentRound,
      'game': currentGameName,
      'hostWon': hostWon,
      'hostWins': hostWins,
      'guestWins': guestWins,
    });

    currentRound++;

    if (hostWins >= config.winsNeeded || guestWins >= config.winsNeeded) {
      isMatchOver = true;
    }

    debugPrint('📊 Manche $currentRound terminée - Hôte: $hostWins, Invité: $guestWins');
  }

  void debugPrint(String message) {
    print('[VersusManager] $message');
  }
}