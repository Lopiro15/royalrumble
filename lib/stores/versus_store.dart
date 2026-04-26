import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/bluetooth/bluetooth_service.dart';
import '../services/bluetooth/bluetooth_game_handler.dart';
import '../services/versus/versus_game_manager.dart';
import '../services/settings_manager.dart';
import '../screens/versus/versus_setup_screen.dart';
import '../screens/versus/versus_game_screen.dart';
import '../widgets/versus/versus_round_result.dart';

class VersusStore extends GetxController {
  final BluetoothService bluetoothService = Get.put(BluetoothService());
  final Rx<VersusGameManager?> gameManager = Rx<VersusGameManager?>(null);

  final Rx<VersusGameConfig> selectedConfig = VersusGameConfig.bestOf3.obs;
  final Rx<bool> isSearching = false.obs;
  final Rx<bool> isConnected = false.obs;
  final Rx<String?> statusMessage = Rx<String?>(null);

  void Function(String challengerName)? onChallengeReceived;

  // Résultats des manches pour affichage
  final RxList<Map<String, dynamic>> roundResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    bluetoothService.init();
    refreshMessageListener();
    ever(bluetoothService.status, (status) => isConnected.value = (status == ConnectionStatus.connected));
  }

  void refreshMessageListener() {
    bluetoothService.onMessageReceived = (message) {
      _handleMessage(message);
    };
  }

  void disconnectAndReset() {
    try { bluetoothService.sendMessage({'type': 'disconnect', 'data': {}}); } catch (_) {}
    bluetoothService.disconnect();
    gameManager.value = null;
    isConnected.value = false;
    isSearching.value = false;
    statusMessage.value = null;
    roundResults.clear();
    selectedConfig.value = VersusGameConfig.bestOf3;
  }

  void _showMessage(String msg) {
    statusMessage.value = msg;
  }

  void startSearching() {
    disconnectAndReset();
    refreshMessageListener();
    isSearching.value = true;
    bluetoothService.startDiscovery(playerName: settingsManager.playerName);
  }

  void startHosting() {
    disconnectAndReset();
    refreshMessageListener();
    isSearching.value = true;
    bluetoothService.startAdvertising(playerName: settingsManager.playerName);
  }

  Future<void> challengePlayer(BluetoothPlayer player) async {
    _showMessage('Connexion à ${player.name}...');
    final connected = await bluetoothService.connectToPlayer(player, playerName: settingsManager.playerName);
    if (connected) {
      _showMessage('Connecté ! Défi envoyé.');
      await Future.delayed(const Duration(milliseconds: 500));
      bluetoothService.sendMessage({'type': 'challenge', 'data': {'fromName': settingsManager.playerName}});
    } else {
      _showMessage('Échec de connexion');
    }
  }

  void acceptChallenge() {
    bluetoothService.sendMessage({'type': 'challengeAccepted', 'data': {}});
    _showMessage('Défi accepté !');
  }

  void rejectChallenge() {
    bluetoothService.sendMessage({'type': 'challengeRejected', 'data': {}});
    disconnectAndReset();
  }

  void hostConfirmSetup(VersusGameConfig config) {
    selectedConfig.value = config;
    gameManager.value = VersusGameManager(isHost: true, config: config);

    // Envoyer la séquence de jeux à l'invité
    bluetoothService.sendMessage({
      'type': 'gameSetup',
      'data': {
        'rounds': config.totalRounds,
        'winsNeeded': config.winsNeeded,
        'games': gameManager.value!.roundGames,
      },
    });

    // Démarrer la première manche
    _startCurrentRound();
  }

  void _startCurrentRound() {
    final gameName = gameManager.value?.currentGameName ?? 'AIR HOCKEY';
    _showMessage('Manche ${gameManager.value!.currentRound + 1}: $gameName');
    Get.off(() => VersusGameScreen(gameName: gameName));
  }

  /// Appelé par le VersusGameScreen quand une manche est terminée
  void onRoundFinished({required bool hostWon, required int hostScore, required int guestScore}) {
    final gm = gameManager.value;
    if (gm == null) return;

    gm.recordRoundWin(hostWon);
    roundResults.value = List.from(gm.roundResults);

    // Envoyer le résultat à l'adversaire
    bluetoothService.sendMessage({
      'type': 'roundResult',
      'data': {
        'hostWon': hostWon,
        'hostScore': hostScore,
        'guestScore': guestScore,
        'hostWins': gm.hostWins,
        'guestWins': gm.guestWins,
        'game': gm.currentGameName,
      },
    });

    // Afficher le résultat de la manche
    final myWins = gm.isHost ? gm.hostWins : gm.guestWins;
    final oppWins = gm.isHost ? gm.guestWins : gm.hostWins;
    final iWon = gm.isHost ? hostWon : !hostWon;

    if (gm.isMatchOver) {
      // Match terminé → recap final
      Get.off(() => VersusFinalRecapScreen(
        won: gm.amIWinner,
        myWins: myWins,
        opponentWins: oppWins,
        roundResults: List.from(gm.roundResults),
        isHost: gm.isHost,
      ));
    } else {
      // Manche suivante → recap partiel
      Get.off(() => VersusRoundResultScreen(
        won: iWon,
        myScore: gm.isHost ? hostScore : guestScore,
        opponentScore: gm.isHost ? guestScore : hostScore,
        myWins: myWins,
        opponentWins: oppWins,
        winsNeeded: gm.config.winsNeeded,
        gameName: gm.roundResults.last['game'] as String,
        onContinue: () {
          _startCurrentRound();
        },
      ));
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    final typeStr = message['type'] as String?;
    if (typeStr == null) return;

    switch (typeStr) {
      case 'challenge':
        final fromName = message['data']?['fromName'] as String? ?? 'Joueur';
        _showMessage('Défi de $fromName !');
        onChallengeReceived?.call(fromName);
        break;
      case 'challengeAccepted':
        _showMessage('Défi accepté ! Configurez.');
        Get.to(() => VersusSetupScreen(isHost: true));
        break;
      case 'challengeRejected':
        _showMessage('Défi refusé');
        disconnectAndReset();
        break;
      case 'gameSetup':
        final rounds = message['data']?['rounds'] as int? ?? 3;
        final games = message['data']?['games'] as List<dynamic>?;
        selectedConfig.value = VersusGameConfig.fromRounds(rounds);
        gameManager.value = VersusGameManager(isHost: false, config: selectedConfig.value);
        if (games != null) {
          gameManager.value!.roundGames.clear();
          gameManager.value!.roundGames.addAll(games.cast<String>());
        }
        _startCurrentRound();
        break;
      case 'roundResult':
        final data = message['data']!;
        final hostWon = data['hostWon'] as bool;
        gameManager.value?.recordRoundWin(hostWon);
        roundResults.value = List.from(gameManager.value!.roundResults);

        final gm = gameManager.value!;
        if (gm.isMatchOver) {
          Get.off(() => VersusFinalRecapScreen(
            won: gm.amIWinner,
            myWins: gm.myWins,
            opponentWins: gm.opponentWins,
            roundResults: List.from(gm.roundResults),
            isHost: gm.isHost,
          ));
        }
        break;
      case 'disconnect':
        _showMessage('Adversaire déconnecté');
        disconnectAndReset();
        Get.until((route) => route.isFirst);
        break;
    }
  }

  @override
  void onClose() {
    disconnectAndReset();
    super.onClose();
  }
}