import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:get/get.dart';

enum ConnectionStatus {
  idle,
  advertising,
  discovering,
  connected,
  disconnected,
}

class BluetoothPlayer {
  final String id;
  final String name;
  String? endpointId;

  BluetoothPlayer({
    required this.id,
    required this.name,
    this.endpointId,
  });
}

class BluetoothService extends GetxService {
  static const String serviceId = 'com.royalrumble.versus';
  final Strategy strategy = Strategy.P2P_STAR;

  final Rx<ConnectionStatus> status = ConnectionStatus.idle.obs;
  final RxList<BluetoothPlayer> availablePlayers = <BluetoothPlayer>[].obs;
  final Rx<BluetoothPlayer?> connectedPlayer = Rx<BluetoothPlayer?>(null);

  void Function(Map<String, dynamic>)? onMessageReceived;

  Completer<bool>? _connectionCompleter;

  Future<void> init() async {}

  // ---------------------------------------------------------------------------
  // CALLBACKS PAYLOAD
  // ---------------------------------------------------------------------------
  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      try {
        final messageStr = utf8.decode(payload.bytes!);
        debugPrint('📩 Reçu de $endpointId: $messageStr');
        final message = jsonDecode(messageStr) as Map<String, dynamic>;
        onMessageReceived?.call(message);
      } catch (e) {
        debugPrint('❌ Décodage: $e');
      }
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) {
    debugPrint('📊 Transfert $endpointId: ${update.status}');
  }

  // ---------------------------------------------------------------------------
  // HÉBERGER - Accepter dans onConnectionInitiated
  // ---------------------------------------------------------------------------
  Future<void> startAdvertising({required String playerName}) async {
    try {
      await Nearby().stopAllEndpoints();
      status.value = ConnectionStatus.advertising;
      availablePlayers.clear();

      debugPrint('📡 HÉBERGEMENT: $playerName');

      await Nearby().startAdvertising(
        playerName,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          debugPrint('📥 Demande de: $id (${info.endpointName})');

          // L'hôte DOIT accepter pour que la connexion aboutisse
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: _onPayloadReceived,
            onPayloadTransferUpdate: _onPayloadTransferUpdate,
          );

          final player = BluetoothPlayer(id: id, name: info.endpointName, endpointId: id);
          connectedPlayer.value = player;
          status.value = ConnectionStatus.connected;
          debugPrint('✅ Hôte connecté à: ${info.endpointName}');
        },
        onConnectionResult: (String id, Status connectionStatus) {
          debugPrint('🔗 Résultat hôte: $id -> $connectionStatus');
        },
        onDisconnected: (String id) {
          debugPrint('🔴 Hôte déconnecté: $id');
          status.value = ConnectionStatus.disconnected;
          connectedPlayer.value = null;
        },
        serviceId: BluetoothService.serviceId,
      );
      debugPrint('📡 HÉBERGEMENT actif');
    } catch (e) {
      debugPrint('❌ Erreur hébergement: $e');
      status.value = ConnectionStatus.idle;
    }
  }

  // ---------------------------------------------------------------------------
  // RECHERCHER
  // ---------------------------------------------------------------------------
  Future<void> startDiscovery({required String playerName}) async {
    try {
      await Nearby().stopAllEndpoints();
      status.value = ConnectionStatus.discovering;
      availablePlayers.clear();

      debugPrint('🔍 RECHERCHE: $playerName');

      await Nearby().startDiscovery(
        playerName,
        strategy,
        onEndpointFound: (String id, String userName, String serviceId) {
          if (serviceId == BluetoothService.serviceId) {
            final exists = availablePlayers.any((p) => p.id == id);
            if (!exists) {
              availablePlayers.add(BluetoothPlayer(id: id, name: userName));
              availablePlayers.refresh();
              debugPrint('➕ $userName');
            }
          }
        },
        onEndpointLost: (String? id) {
          availablePlayers.removeWhere((p) => p.id == id);
        },
        serviceId: BluetoothService.serviceId,
      );
      debugPrint('🔍 RECHERCHE active');
    } catch (e) {
      debugPrint('❌ Erreur recherche: $e');
      status.value = ConnectionStatus.idle;
    }
  }

  // ---------------------------------------------------------------------------
  // DÉFIER - Accepter dans onConnectionInitiated, envoyer défi dans onConnectionResult
  // ---------------------------------------------------------------------------
  Future<bool> connectToPlayer(BluetoothPlayer player, {required String playerName}) async {
    try {
      debugPrint('🔗 Connexion à: ${player.name} (id: ${player.id})');

      await Nearby().stopDiscovery();
      debugPrint('🛑 Découverte arrêtée');

      _connectionCompleter = Completer<bool>();

      await Nearby().requestConnection(
        playerName,
        player.id,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          debugPrint('📥 Initiée: $id (${info.endpointName})');

          // LE CLIENT DOIT AUSSI ACCEPTER ICI !
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: _onPayloadReceived,
            onPayloadTransferUpdate: _onPayloadTransferUpdate,
          );

          player.endpointId = id;
          connectedPlayer.value = player;
          status.value = ConnectionStatus.connected;

          debugPrint('✅ Client connecté à: ${info.endpointName}');
        },
        onConnectionResult: (String id, Status connectionStatus) {
          debugPrint('🔗 Résultat client: $id -> $connectionStatus');
          if (connectionStatus == Status.CONNECTED) {
            // Connexion confirmée, on peut compléter
            if (!(_connectionCompleter?.isCompleted ?? true)) {
              _connectionCompleter?.complete(true);
            }
          } else {
            if (!(_connectionCompleter?.isCompleted ?? true)) {
              _connectionCompleter?.complete(false);
            }
          }
        },
        onDisconnected: (String id) {
          debugPrint('🔴 Client déconnecté: $id');
          status.value = ConnectionStatus.disconnected;
          connectedPlayer.value = null;
          if (!(_connectionCompleter?.isCompleted ?? true)) {
            _connectionCompleter?.complete(false);
          }
        },
      );

      // Attendre un peu que la connexion se stabilise, puis considérer comme connecté
      // car onConnectionResult peut ne pas être appelé sur toutes les plateformes
      await Future.delayed(const Duration(seconds: 2));

      if (!(_connectionCompleter?.isCompleted ?? true)) {
        // Si onConnectionResult n'a pas été appelé, on considère que c'est bon
        // car onConnectionInitiated a déjà été appelé
        debugPrint('⏳ onConnectionResult non appelé, connexion considérée OK');
        _connectionCompleter?.complete(true);
      }

      final result = await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ Timeout final');
          return false;
        },
      );

      return result;
    } catch (e) {
      debugPrint('❌ Erreur connexion: $e');
      status.value = ConnectionStatus.idle;
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // ENVOYER
  // ---------------------------------------------------------------------------
  Future<void> sendMessage(Map<String, dynamic> message) async {
    final endpointId = connectedPlayer.value?.endpointId;
    if (endpointId == null) {
      debugPrint('❌ Pas d\'endpointId. Joueur: ${connectedPlayer.value?.name}');
      return;
    }

    try {
      final jsonStr = jsonEncode(message);
      final bytes = utf8.encode(jsonStr);
      debugPrint('📤 Envoi à $endpointId: $jsonStr');
      await Nearby().sendBytesPayload(endpointId, Uint8List.fromList(bytes));
      debugPrint('✅ Envoyé');
    } catch (e) {
      debugPrint('❌ Erreur envoi: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // STOP
  // ---------------------------------------------------------------------------
  Future<void> stopAdvertising() async {
    try { await Nearby().stopAdvertising(); } catch (_) {}
  }

  Future<void> stopDiscovery() async {
    try { await Nearby().stopDiscovery(); } catch (_) {}
  }

  Future<void> disconnect() async {
    try {
      await Nearby().stopAllEndpoints();
      connectedPlayer.value = null;
      availablePlayers.clear();
      status.value = ConnectionStatus.idle;
    } catch (_) {}
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}