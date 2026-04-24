import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/versus/versus_game_screen.dart';
import '../services/bluetooth/bluetooth_service.dart';
import '../services/bluetooth/bluetooth_game_handler.dart';
import '../services/versus/versus_game_manager.dart';
import '../services/settings_manager.dart';
import '../screens/versus/versus_setup_screen.dart';

class VersusStore extends GetxController {
  final BluetoothService bluetoothService = Get.put(BluetoothService());
  final Rx<VersusGameManager?> gameManager = Rx<VersusGameManager?>(null);

  final Rx<VersusGameConfig> selectedConfig = VersusGameConfig.bestOf3.obs;
  final Rx<bool> isSearching = false.obs;
  final Rx<bool> isConnected = false.obs;
  final Rx<String?> currentGame = Rx<String?>(null);

  final Rx<String?> statusMessage = Rx<String?>(null);

  // Callback pour afficher le défi
  void Function(String challengerName)? onChallengeReceived;

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
      _showMessage('Connecté ! En attente de la réponse...');

      // Envoyer le défi SANS les rounds (l'hôte choisira après acceptation)
      bluetoothService.sendMessage({
        'type': 'challenge',
        'data': {
          'fromName': settingsManager.playerName,
        },
      });
    } else {
      _showMessage('Échec de connexion');
    }
  }

  void acceptChallenge() {
    // L'invité accepte, on envoie la confirmation
    bluetoothService.sendMessage({
      'type': 'challengeAccepted',
      'data': {},
    });
    _showMessage('Défi accepté ! En attente de la configuration...');
  }

  void rejectChallenge() {
    bluetoothService.sendMessage({
      'type': 'challengeRejected',
      'data': {},
    });
    bluetoothService.disconnect();
    _showMessage('Défi refusé');
  }

  /// Appelé par l'hôte après avoir choisi le nombre de manches
  void hostConfirmSetup(VersusGameConfig config) {
    selectedConfig.value = config;

    // Envoyer la config à l'invité
    bluetoothService.sendMessage({
      'type': 'gameSetup',
      'data': {
        'rounds': config.totalRounds,
        'winsNeeded': config.winsNeeded,
      },
    });

    // Démarrer le jeu côté hôte
    _startGame(isHost: true);
  }

  void _startGame({bool isHost = true}) {
    gameManager.value = VersusGameManager(
      bluetoothService: bluetoothService,
      config: selectedConfig.value,
      isHost: isHost,
    );

    bluetoothService.sendMessage({
      'type': 'gameStart',
      'data': {
        'config': {
          'rounds': selectedConfig.value.totalRounds,
          'winsNeeded': selectedConfig.value.winsNeeded,
        },
      },
    });

    _showMessage('Début de la partie !');

    // Naviguer vers le jeu
    Get.off(() => const VersusGameScreen());
  }

  void _handleMessage(Map<String, dynamic> message) {
    debugPrint('📨 Message reçu: $message');

    final typeStr = message['type'] as String?;
    if (typeStr == null) return;

    switch (typeStr) {
      case 'challenge':
        debugPrint('🎯 DÉFI REÇU !');
        final fromName = message['data']?['fromName'] as String? ?? 'Joueur';

        // Afficher la popup de défi
        if (onChallengeReceived != null) {
          onChallengeReceived!(fromName);
        }
        break;

      case 'challengeAccepted':
        debugPrint('✅ Défi accepté par l\'invité !');
        _showMessage('Défi accepté ! Configurez la partie.');

        // L'hôte doit maintenant choisir la configuration
        // Afficher l'écran de configuration
        Get.to(() => VersusSetupScreen(isHost: true));
        break;

      case 'challengeRejected':
        _showMessage('Défi refusé par l\'adversaire');
        bluetoothService.disconnect();
        break;

      case 'gameSetup':
      // L'invité reçoit la configuration
        final rounds = message['data']?['rounds'] as int? ?? 3;
        selectedConfig.value = VersusGameConfig.fromRounds(rounds);
        _showMessage('Configuration reçue: BO$rounds');
        break;

      case 'gameStart':
        debugPrint('🎮 Début de partie !');
        if (gameManager.value == null) {
          gameManager.value = VersusGameManager(
            bluetoothService: bluetoothService,
            config: VersusGameConfig.fromRounds(
              message['data']?['config']?['rounds'] as int? ?? 3,
            ),
            isHost: false,
          );
        }
        _showMessage('La partie commence !');

        // Naviguer vers le jeu côté invité
        Get.off(() => const VersusGameScreen());
        break;

      case 'gameResult':
        debugPrint('📊 Résultat reçu: ${message['data']}');
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