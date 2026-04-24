import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/bluetooth/bluetooth_permission_service.dart';

enum PermissionStep {
  checking,
  needLocation,
  needBluetooth,
  needPermissions,
  ready,
  error,
}

class VersusPermissionDialog extends StatefulWidget {
  final VoidCallback onReady;
  final VoidCallback onCancel;

  const VersusPermissionDialog({
    super.key,
    required this.onReady,
    required this.onCancel,
  });

  @override
  State<VersusPermissionDialog> createState() => _VersusPermissionDialogState();
}

class _VersusPermissionDialogState extends State<VersusPermissionDialog> {
  PermissionStep _step = PermissionStep.checking;
  String _message = 'Vérification des paramètres...';
  Timer? _checkTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startCheck();
  }

  Future<void> _startCheck() async {
    await _checkAll();

    _checkTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_isDisposed || !mounted) return;
      await _checkAll();
    });
  }

  Future<void> _checkAll() async {
    if (_isDisposed || !mounted) return;

    final locationEnabled = await BluetoothPermissionService.isLocationEnabled();
    if (!locationEnabled) {
      if (mounted) {
        setState(() {
          _step = PermissionStep.needLocation;
          _message = 'La localisation doit être activée\npour utiliser le Bluetooth';
        });
      }
      return;
    }

    final bluetoothEnabled = await BluetoothPermissionService.isBluetoothEnabled();
    if (!bluetoothEnabled) {
      if (mounted) {
        setState(() {
          _step = PermissionStep.needBluetooth;
          _message = 'Le Bluetooth doit être activé';
        });
      }
      return;
    }

    final permissionsGranted = await BluetoothPermissionService.areAllPermissionsGranted();
    if (!permissionsGranted) {
      if (mounted) {
        setState(() {
          _step = PermissionStep.needPermissions;
          _message = 'Les permissions Bluetooth et Localisation\nsont nécessaires';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _step = PermissionStep.ready;
        _message = 'Tout est prêt !';
      });
    }

    _checkTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isDisposed && mounted) {
        widget.onReady();
      }
    });
  }

  Future<void> _requestLocation() async {
    try {
      setState(() => _message = 'Activation de la localisation...');
      final result = await BluetoothPermissionService.requestLocationService();
      if (_isDisposed || !mounted) return;
      if (result) {
        await _checkAll();
      } else {
        setState(() => _message = 'Impossible d\'activer la localisation.\nVeuillez l\'activer manuellement.');
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _step = PermissionStep.error;
        _message = 'Erreur : $e';
      });
    }
  }

  Future<void> _openBluetoothSettings() async {
    try {
      await BluetoothPermissionService.openSystemSettings();
      if (_isDisposed || !mounted) return;
      setState(() => _message = 'Activez le Bluetooth dans les paramètres,\npuis revenez à l\'application');
    } catch (e) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _step = PermissionStep.error;
        _message = 'Erreur : $e';
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() => _message = 'Demande des permissions...');
      await BluetoothPermissionService.requestAllPermissions();
      if (_isDisposed || !mounted) return;
      await _checkAll();
    } catch (e) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _step = PermissionStep.error;
        _message = 'Erreur : $e';
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color royalGold = Color(0xFFD4AF37);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF001A33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: royalGold, width: 2),
          boxShadow: [BoxShadow(color: royalGold.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(royalGold),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildCompactProgress(royalGold),
            const SizedBox(height: 20),
            _buildActionButton(royalGold),
            if (_step != PermissionStep.ready) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _checkTimer?.cancel();
                  widget.onCancel();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: const Text(
                    'ANNULER',
                    style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color gold) {
    IconData icon;
    Color color;

    switch (_step) {
      case PermissionStep.checking:
        icon = Icons.sync_rounded;
        color = gold;
        break;
      case PermissionStep.needLocation:
        icon = Icons.location_off_rounded;
        color = Colors.orangeAccent;
        break;
      case PermissionStep.needBluetooth:
        icon = Icons.bluetooth_disabled_rounded;
        color = Colors.blueAccent;
        break;
      case PermissionStep.needPermissions:
        icon = Icons.security_rounded;
        color = Colors.yellowAccent;
        break;
      case PermissionStep.ready:
        icon = Icons.check_circle_rounded;
        color = Colors.greenAccent;
        break;
      case PermissionStep.error:
        icon = Icons.error_rounded;
        color = Colors.redAccent;
        break;
    }

    return Icon(icon, color: color, size: 64)
        .animate(
      onPlay: (controller) {
        if (_step == PermissionStep.checking) {
          controller.repeat();
        }
      },
    )
        .rotate(
      begin: 0,
      end: _step == PermissionStep.checking ? 6.28 : 0,
      duration: 2000.ms,
    );
  }

  // Version compacte de l'indicateur de progression (sans overflow)
  Widget _buildCompactProgress(Color gold) {
    final locDone = _step == PermissionStep.ready ||
        (_step != PermissionStep.needLocation && _step != PermissionStep.checking);
    final btDone = _step == PermissionStep.ready ||
        (_step != PermissionStep.needBluetooth && _step != PermissionStep.needLocation && _step != PermissionStep.checking);
    final permDone = _step == PermissionStep.ready;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(locDone, gold),
          const SizedBox(width: 6),
          Container(width: 20, height: 2, color: locDone ? gold : Colors.white.withOpacity(0.1)),
          const SizedBox(width: 6),
          _buildDot(btDone, gold),
          const SizedBox(width: 6),
          Container(width: 20, height: 2, color: btDone ? gold : Colors.white.withOpacity(0.1)),
          const SizedBox(width: 6),
          _buildDot(permDone, gold),
        ],
      ),
    );
  }

  Widget _buildDot(bool active, Color gold) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? gold : Colors.white.withOpacity(0.15),
            boxShadow: active ? [BoxShadow(color: gold.withOpacity(0.4), blurRadius: 6)] : [],
          ),
          child: active ? const Icon(Icons.check, color: Color(0xFF001A33), size: 9) : null,
        ),
        const SizedBox(height: 4),
        Text(
          active ? '✓' : '○',
          style: TextStyle(
            color: active ? gold : Colors.white.withOpacity(0.2),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Color gold) {
    switch (_step) {
      case PermissionStep.checking:
        return const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2.5),
        );

      case PermissionStep.needLocation:
        return _buildBtn('ACTIVER LA LOCALISATION', _requestLocation, gold);

      case PermissionStep.needBluetooth:
        return _buildBtn('OUVRIR LES PARAMÈTRES', _openBluetoothSettings, Colors.blueAccent);

      case PermissionStep.needPermissions:
        return _buildBtn('ACCORDER LES PERMISSIONS', _requestPermissions, Colors.yellowAccent);

      case PermissionStep.ready:
        return const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 44)
            .animate()
            .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );

      case PermissionStep.error:
        return _buildBtn('RÉESSAYER', _checkAll, Colors.redAccent);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBtn(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF001A33),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 8);
  }
}