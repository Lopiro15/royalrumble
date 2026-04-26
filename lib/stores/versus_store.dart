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

  @override
  void onInit() { super.onInit(); bluetoothService.init(); refreshMessageListener(); ever(bluetoothService.status, (s) => isConnected.value = (s == ConnectionStatus.connected)); }

  void refreshMessageListener() { bluetoothService.onMessageReceived = (m) => _handleMessage(m); }
  void disconnectAndReset() { try { bluetoothService.sendMessage({'type': 'disconnect', 'data': {}}); } catch (_) {} bluetoothService.disconnect(); gameManager.value = null; isConnected.value = false; isSearching.value = false; statusMessage.value = null; selectedConfig.value = VersusGameConfig.bestOf3; }
  void _showMessage(String m) => statusMessage.value = m;

  void startSearching() { disconnectAndReset(); refreshMessageListener(); isSearching.value = true; bluetoothService.startDiscovery(playerName: settingsManager.playerName); }
  void startHosting() { disconnectAndReset(); refreshMessageListener(); isSearching.value = true; bluetoothService.startAdvertising(playerName: settingsManager.playerName); }

  Future<void> challengePlayer(BluetoothPlayer p) async { _showMessage('Connexion...'); final ok = await bluetoothService.connectToPlayer(p, playerName: settingsManager.playerName); if (ok) { await Future.delayed(const Duration(milliseconds: 500)); bluetoothService.sendMessage({'type': 'challenge', 'data': {'fromName': settingsManager.playerName}}); } else _showMessage('Échec'); }
  void acceptChallenge() { bluetoothService.sendMessage({'type': 'challengeAccepted', 'data': {}}); _showMessage('Défi accepté !'); }
  void rejectChallenge() { bluetoothService.sendMessage({'type': 'challengeRejected', 'data': {}}); disconnectAndReset(); }

  void hostConfirmSetup(VersusGameConfig config) {
    selectedConfig.value = config; gameManager.value = VersusGameManager(isHost: true, config: config);
    bluetoothService.sendMessage({'type': 'gameSetup', 'data': {'rounds': config.totalRounds, 'winsNeeded': config.winsNeeded, 'games': gameManager.value!.roundGames}});
    _startCurrentRound();
  }

  void _startCurrentRound() { final gm = gameManager.value; if (gm == null) return; Get.off(() => VersusGameScreen(gameName: gm.currentGameName)); }

  /// Appelé par chaque VersusGameScreen quand une manche est terminée
  /// iWon: true si j'ai gagné cette manche
  void onRoundFinished({required bool iWon, required int myScore, required int opponentScore}) {
    final gm = gameManager.value; if (gm == null) return;

    // Déterminer si l'hôte a gagné (pour la synchro entre les deux appareils)
    final hostWon = gm.isHost ? iWon : !iWon;
    gm.recordRoundWin(hostWon);

    final myWins = gm.myWins;
    final oppWins = gm.opponentWins;

    debugPrint('📊 Fin de manche - Mes victoires: $myWins, Adversaire: $oppWins, Match terminé: ${gm.isMatchOver}');

    if (gm.isMatchOver) {
      Get.off(() => VersusFinalRecapScreen(
        won: gm.amIWinner,
        myWins: myWins,
        opponentWins: oppWins,
        roundResults: List.from(gm.roundResults),
        isHost: gm.isHost,
      ));
    } else {
      Get.off(() => VersusRoundResultScreen(
        won: iWon,
        myScore: myScore,
        opponentScore: opponentScore,
        myWins: myWins,
        opponentWins: oppWins,
        winsNeeded: gm.config.winsNeeded,
        gameName: gm.roundResults.last['game'] as String,
        onContinue: () => _startCurrentRound(),
      ));
    }
  }

  void _handleMessage(Map<String, dynamic> m) {
    final t = m['type'] as String?; if (t == null) return;
    switch (t) {
      case 'challenge': onChallengeReceived?.call(m['data']?['fromName'] as String? ?? 'Joueur'); break;
      case 'challengeAccepted': Get.to(() => VersusSetupScreen(isHost: true)); break;
      case 'challengeRejected': disconnectAndReset(); break;
      case 'gameSetup': final r = m['data']?['rounds'] as int? ?? 3; final games = m['data']?['games'] as List<dynamic>?; selectedConfig.value = VersusGameConfig.fromRounds(r); gameManager.value = VersusGameManager(isHost: false, config: selectedConfig.value); if (games != null) { gameManager.value!.roundGames.clear(); gameManager.value!.roundGames.addAll(games.cast<String>()); } _startCurrentRound(); break;
      case 'disconnect': disconnectAndReset(); Get.until((route) => route.isFirst); break;
    }
  }

  @override
  void onClose() { disconnectAndReset(); super.onClose(); }
}