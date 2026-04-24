import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/bluetooth/bluetooth_service.dart';
import '../services/bluetooth/bluetooth_game_handler.dart';
import '../services/versus/versus_game_manager.dart';
import '../services/settings_manager.dart';

class VersusStore extends GetxController {
  final BluetoothService bluetoothService = Get.put(BluetoothService());
  final Rx<VersusGameManager?> gameManager = Rx<VersusGameManager?>(null);

  final Rx<VersusGameConfig> selectedConfig = VersusGameConfig.bestOf3.obs;
  final Rx<bool> isSearching = false.obs;
  final Rx<bool> isConnected = false.obs;
  final Rx<String?> currentGame = Rx<String?>(null);

  // Messages pour l'UI
  final Rx<String?> statusMessage = Rx<String?>(null);

  // Callback pour afficher le défi (sera défini par le LobbyScreen)
  void Function(String challengerName, int rounds)? onChallengeReceived;

  @override
  void onInit() {
    super.onInit();
    bluetoothService.init();
    bluetoothService.onMessageReceived = _handleMessage;

    ever(bluetoothService.status, (status) {
      isConnected.value = (status == ConnectionStatus.connected);
    });
  }

  void _showMessage(String msg) {
    statusMessage.value = msg;
    debugPrint('💬 $msg');
    Future.delayed(const Duration(seconds: 4), () {
      if (statusMessage.value == msg) {
        statusMessage.value = null;
      }
    });
  }

  void startSearching() {
    isSearching.value = true;
    bluetoothService.startDiscovery(playerName: settingsManager.playerName);
  }

  void startHosting() {
    isSearching.value = true;
    bluetoothService.startAdvertising(playerName: settingsManager.playerName);
  }

  void stopSearching() {
    isSearching.value = false;
    bluetoothService.stopAdvertising();
    bluetoothService.stopDiscovery();
  }

  Future<void> challengePlayer(BluetoothPlayer player) async {
    _showMessage('Connexion à ${player.name}...');

    final connected = await bluetoothService.connectToPlayer(
      player,
      playerName: settingsManager.playerName,
    );

    if (connected) {
      _showMessage('Connecté ! Défi envoyé.');
      await Future.delayed(const Duration(milliseconds: 500));

      bluetoothService.sendMessage({
        'type': 'challenge',
        'data': {
          'fromName': settingsManager.playerName,
          'rounds': selectedConfig.value.totalRounds,
        },
      });
    } else {
      _showMessage('Échec de connexion');
    }
  }

  void acceptChallenge() {
    bluetoothService.sendMessage({
      'type': 'challengeAccepted',
      'data': {},
    });
    _startGame(isHost: false);
  }

  void rejectChallenge() {
    bluetoothService.sendMessage({
      'type': 'challengeRejected',
      'data': {},
    });
    bluetoothService.disconnect();
    _showMessage('Défi refusé');
  }

  void _startGame({bool isHost = true}) {
    bluetoothService.sendMessage({
      'type': 'gameStart',
      'data': {
        'config': {'rounds': selectedConfig.value.totalRounds},
      },
    });
    _showMessage('Début de la partie !');
    // Navigation vers le jeu (à implémenter)
  }

  void _handleMessage(Map<String, dynamic> message) {
    debugPrint('📨 Message reçu: $message');

    final typeStr = message['type'] as String?;
    if (typeStr == null) return;

    switch (typeStr) {
      case 'challenge':
        debugPrint('🎯 DÉFI REÇU ! Appel du callback...');
        final rounds = message['data']?['rounds'] as int? ?? 3;
        final fromName = message['data']?['fromName'] as String? ?? 'Joueur';
        selectedConfig.value = VersusGameConfig.fromRounds(rounds);

        // Utiliser le callback au lieu de Get.dialog
        if (onChallengeReceived != null) {
          onChallengeReceived!(fromName, rounds);
        } else {
          debugPrint('❌ onChallengeReceived est null !');
        }
        break;

      case 'challengeAccepted':
        _showMessage('Défi accepté !');
        _startGame(isHost: true);
        break;

      case 'challengeRejected':
        _showMessage('Défi refusé par l\'adversaire');
        bluetoothService.disconnect();
        break;

      case 'gameStart':
        if (gameManager.value == null) {
          gameManager.value = VersusGameManager(
            bluetoothService: bluetoothService,
            config: VersusGameConfig.fromRounds(
              message['data']?['config']?['rounds'] as int? ?? 3,
            ),
            isHost: false,
          );
        }
        _startGame(isHost: false);
        break;
    }
  }

  void sendGameResult({required bool hostWon, required int hostScore, required int guestScore}) {
    bluetoothService.sendMessage({
      'type': 'gameResult',
      'data': {
        'hostWon': hostWon,
        'hostScore': hostScore,
        'guestScore': guestScore,
      },
    });
  }

  @override
  void onClose() {
    bluetoothService.disconnect();
    super.onClose();
  }
}