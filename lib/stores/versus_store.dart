import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/bluetooth/bluetooth_service.dart';
import '../services/bluetooth/bluetooth_game_handler.dart';
import '../services/versus/versus_game_manager.dart';
import '../services/settings_manager.dart';
import '../screens/versus/versus_setup_screen.dart';
import '../screens/versus/versus_game_screen.dart';

class VersusStore extends GetxController {
  final BluetoothService bluetoothService = Get.put(BluetoothService());
  final Rx<VersusGameManager?> gameManager = Rx<VersusGameManager?>(null);

  final Rx<VersusGameConfig> selectedConfig = VersusGameConfig.bestOf3.obs;
  final Rx<bool> isSearching = false.obs;
  final Rx<bool> isConnected = false.obs;
  final Rx<String?> statusMessage = Rx<String?>(null);

  void Function(String challengerName)? onChallengeReceived;

  @override
  void onInit() {
    super.onInit();
    bluetoothService.init();
    refreshMessageListener();

    ever(bluetoothService.status, (status) {
      isConnected.value = (status == ConnectionStatus.connected);
    });
  }

  /// À appeler après chaque navigation pour restaurer le listener du Store
  void refreshMessageListener() {
    debugPrint('🔄 Store reprend le contrôle des messages');
    bluetoothService.onMessageReceived = (message) {
      debugPrint('📨 Store reçoit: ${message['type']}');
      _handleMessage(message);
    };
  }

  void disconnectAndReset() {
    debugPrint('🔌 Reset...');
    try { bluetoothService.sendMessage({'type': 'disconnect', 'data': {}}); } catch (_) {}
    bluetoothService.disconnect();
    gameManager.value = null;
    isConnected.value = false;
    isSearching.value = false;
    statusMessage.value = null;
    selectedConfig.value = VersusGameConfig.bestOf3;
  }

  void _showMessage(String msg) {
    statusMessage.value = msg;
    debugPrint('💬 $msg');
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
      bluetoothService.sendMessage({
        'type': 'challenge',
        'data': {'fromName': settingsManager.playerName},
      });
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
    bluetoothService.sendMessage({
      'type': 'gameSetup',
      'data': {'rounds': config.totalRounds},
    });
    Get.off(() => const VersusGameScreen());
  }

  void _handleMessage(Map<String, dynamic> message) {
    final typeStr = message['type'] as String?;
    if (typeStr == null) return;

    debugPrint('📨 Traitement Store: $typeStr');

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
        selectedConfig.value = VersusGameConfig.fromRounds(rounds);
        Get.off(() => const VersusGameScreen());
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