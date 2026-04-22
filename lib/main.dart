import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/settings_manager.dart';
import 'screens/play_menu_screen.dart';
import 'widgets/menu_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Activer le mode plein écran immersif (cache barres système et navigation)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await settingsManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Rumble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF001A33),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.luckiestGuyTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingsManager.startMusic();
    _nameController.text = settingsManager.playerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showSettings() {
    settingsManager.playClick();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF002147),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD4AF37), width: 1)),
          title: const Text('PARAMETRES', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('NOM DU JOUEUR', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    hintText: 'Ton pseudo...',
                    hintStyle: const TextStyle(color: Colors.white24),
                  ),
                  onChanged: (val) => settingsManager.updatePlayerName(val),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('MUSIQUE', style: TextStyle(color: Colors.white)),
                  value: settingsManager.isMusicEnabled,
                  activeColor: const Color(0xFFD4AF37),
                  onChanged: (val) {
                    setState(() => settingsManager.toggleMusic(val));
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('SONS', style: TextStyle(color: Colors.white)),
                  value: settingsManager.isSoundEnabled,
                  activeColor: const Color(0xFFD4AF37),
                  onChanged: (val) {
                    setState(() => settingsManager.toggleSound(val));
                    setDialogState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                settingsManager.playClick();
                Navigator.pop(context);
                setState(() {}); // Pour mettre à jour l'affichage si le nom a changé
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
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
                        // Affichage du nom du joueur
                        Text(
                          "BIENVENUE, ${settingsManager.playerName.toUpperCase()}",
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/logo.png',
                            height: 250,
                          )
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .moveY(begin: -10, end: 10, duration: 2000.ms, curve: Curves.easeInOut)
                              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: MenuButton(
                            label: 'JOUER',
                            icon: Icons.play_arrow_rounded,
                            color: royalGold,
                            onTap: () {
                              settingsManager.playClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PlayMenuScreen()),
                              );
                            },
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: MenuButton(
                            label: 'PARAMETRES',
                            icon: Icons.settings_rounded,
                            color: Colors.white.withOpacity(0.9),
                            textColor: primaryBlue,
                            onTap: _showSettings,
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
