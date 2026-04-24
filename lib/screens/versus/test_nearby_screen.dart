
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class TestNearbyScreen extends StatefulWidget {
  const TestNearbyScreen({super.key});

  @override
  State<TestNearbyScreen> createState() => _TestNearbyScreenState();
}

class _TestNearbyScreenState extends State<TestNearbyScreen> {
  final List<String> _logs = [];
  final List<String> _devices = [];
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  void _addLog(String msg) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] $msg');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  Future<void> _startAdvertising() async {
    try {
      await Nearby().stopAllEndpoints();
      _addLog('🟢 Arrêt des connexions précédentes');

      await Nearby().startAdvertising(
        'TestPlayer',
        Strategy.P2P_STAR,
        onConnectionInitiated: (id, info) {
          _addLog('📥 Connexion initiée: $id');
          Nearby().acceptConnection(id, onPayloadTransferUpdate: (endpointId, update) {}, onPayLoadRecieved: (String endpointId, Payload payload) {
            _addLog('📦 Données reçues de: $endpointId');
          });
        },
        onConnectionResult: (id, status) {
          _addLog('🔗 Résultat connexion: $id -> $status');
        },
        onDisconnected: (id) {
          _addLog('🔴 Déconnecté: $id');
        },
        serviceId: 'com.royalrumble.versus',
      );

      setState(() => _isAdvertising = true);
      _addLog('📡 Publicité démarrée');
    } catch (e) {
      _addLog('❌ Erreur publicité: $e');
    }
  }

  Future<void> _startDiscovery() async {
    try {
      await Nearby().stopAllEndpoints();
      _addLog('🟢 Arrêt des connexions précédentes');

      await Nearby().startDiscovery(
        'TestPlayer2',
        Strategy.P2P_STAR,
        onEndpointFound: (id, name, serviceId) {
          _addLog('👀 Appareil trouvé: $name ($id) serviceId: $serviceId');
          if (serviceId == 'com.royalrumble.versus') {
            setState(() => _devices.add(name));
          }
        },
        onEndpointLost: (id) {
          _addLog('👋 Appareil perdu: $id');
        },
        serviceId: 'com.royalrumble.versus',
      );

      setState(() => _isDiscovering = true);
      _addLog('🔍 Découverte démarrée');
    } catch (e) {
      _addLog('❌ Erreur découverte: $e');
    }
  }

  Future<void> _stopAll() async {
    await Nearby().stopAllEndpoints();
    setState(() {
      _isAdvertising = false;
      _isDiscovering = false;
      _devices.clear();
    });
    _addLog('🛑 Tout arrêté');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A33),
      appBar: AppBar(
        title: const Text('TEST NEARBY'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isAdvertising ? null : _startAdvertising,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('PUBLIER'),
                ),
                ElevatedButton(
                  onPressed: _isDiscovering ? null : _startDiscovery,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('CHERCHER'),
                ),
                ElevatedButton(
                  onPressed: _stopAll,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('STOP'),
                ),
              ],
            ),

            // Appareils trouvés
            if (_devices.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('APPAREILS TROUVÉS:', style: TextStyle(color: Colors.greenAccent)),
                    ..._devices.map((d) => Text(d, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) => Text(
                    _logs[index],
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}