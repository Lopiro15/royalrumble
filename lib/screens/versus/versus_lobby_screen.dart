import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:royalrumble/screens/versus/versus_setup_screen.dart';
import '../../services/bluetooth/bluetooth_service.dart';
import '../../services/bluetooth/bluetooth_permission_service.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../../widgets/menu_button.dart';
import '../../widgets/versus/versus_permission_dialog.dart';
import '../../widgets/versus/versus_challenge_dialog.dart';
import '../../services/bluetooth/bluetooth_game_handler.dart';

class VersusLobbyScreen extends StatefulWidget {
  const VersusLobbyScreen({super.key});

  @override
  State<VersusLobbyScreen> createState() => _VersusLobbyScreenState();
}

class _VersusLobbyScreenState extends State<VersusLobbyScreen> {
  @override
  void initState() {
    super.initState();

    // Réinitialiser complètement le store quand on arrive sur cet écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Get.find<VersusStore>();
      store.refreshMessageListener();

      store.onChallengeReceived = (challengerName) {
        debugPrint('🎯 Popup défi pour: $challengerName');
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => VersusChallengeDialog(
              challengerName: challengerName,
              onAccept: () {
                Navigator.pop(ctx);
                store.acceptChallenge();
                Get.to(() => VersusSetupScreen(isHost: false));
              },
              onReject: () {
                Navigator.pop(ctx);
                store.rejectChallenge();
              },
            ),
          );
        }
      };
    });
  }

  Future<bool> _checkPermissionsBeforeAction(BuildContext context) async {
    final allReady = await BluetoothPermissionService.areAllPermissionsGranted();
    final locationEnabled = await BluetoothPermissionService.isLocationEnabled();
    final bluetoothEnabled = await BluetoothPermissionService.isBluetoothEnabled();

    if (allReady && locationEnabled && bluetoothEnabled) return true;

    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => VersusPermissionDialog(
          onReady: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        ),
      );
      return result ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final VersusStore store = Get.find<VersusStore>();
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        store.disconnectAndReset();
      },
      child: Scaffold(
        backgroundColor: primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('MODE VERSUS', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              store.disconnectAndReset();
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF002147), primaryBlue],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          Expanded(
                            child: MenuButton(
                              label: 'RECHERCHER',
                              icon: Icons.search_rounded,
                              color: royalGold,
                              fontSize: 16,
                              onTap: () async {
                                settingsManager.playClick();
                                final ready = await _checkPermissionsBeforeAction(context);
                                if (ready) store.startSearching();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MenuButton(
                              label: 'HÉBERGER',
                              icon: Icons.wifi_rounded,
                              color: Colors.white.withOpacity(0.9),
                              textColor: primaryBlue,
                              fontSize: 16,
                              onTap: () async {
                                settingsManager.playClick();
                                final ready = await _checkPermissionsBeforeAction(context);
                                if (ready) store.startHosting();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Obx(() {
                        if (store.isSearching.value) {
                          return _buildPlayerList(store, royalGold);
                        } else {
                          return _buildEmptyState(royalGold);
                        }
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      child: MenuButton(
                        label: 'RETOUR',
                        icon: Icons.arrow_back_rounded,
                        color: Colors.redAccent.withOpacity(0.8),
                        fontSize: 18,
                        onTap: () {
                          store.disconnectAndReset();
                          Navigator.pop(context);
                        },
                      ).animate().fadeIn(delay: 500.ms),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (store.statusMessage.value != null) {
                return Positioned(
                  bottom: 100, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(store.statusMessage.value!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF001A33), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn().slideY(begin: 20);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(VersusStore store, Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Text(
              'CONFIGURATION DES MANCHES',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoundOption(store, VersusGameConfig.bestOf3, '3', '2 wins', gold),
                _buildRoundOption(store, VersusGameConfig.bestOf5, '5', '3 wins', gold),
                _buildRoundOption(store, VersusGameConfig.bestOf7, '7', '4 wins', gold),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundOption(VersusStore store, VersusGameConfig config, String rounds, String desc, Color gold) {
    final isSelected = store.selectedConfig.value.totalRounds == config.totalRounds;

    return GestureDetector(
      onTap: () {
        settingsManager.playClick();
        store.selectedConfig.value = config;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? gold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? gold : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'BO$rounds',
              style: TextStyle(
                color: isSelected ? gold : Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                color: isSelected ? gold.withOpacity(0.7) : Colors.white24,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList(VersusStore store, Color gold) {
    return Obx(() {
      if (store.bluetoothService.availablePlayers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recherche de joueurs...',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                store.bluetoothService.status.value == ConnectionStatus.advertising
                    ? 'En attente de connexion...'
                    : 'Scan en cours...',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
        ).animate().fadeIn();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        itemCount: store.bluetoothService.availablePlayers.length,
        itemBuilder: (context, index) {
          final player = store.bluetoothService.availablePlayers[index];
          return _buildPlayerCard(player, store, gold, index);
        },
      );
    });
  }

  Widget _buildPlayerCard(BluetoothPlayer player, VersusStore store, Color gold, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002147),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFFD4AF37), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                ),
                Text(
                  'Disponible',
                  style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              settingsManager.playClick();
              store.challengePlayer(player);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'DÉFIER',
                style: TextStyle(
                  color: Color(0xFF001A33),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: -0.2);
  }

  Widget _buildEmptyState(Color gold) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching_rounded, size: 80, color: gold.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Appuyez sur Rechercher pour trouver\nun adversaire à proximité',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}