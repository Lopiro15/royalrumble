import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_manager.dart';
import '../services/score_manager.dart';
import '../widgets/menu_button.dart';

// ---------------------------------------------------------------------------
// ScoresScreen — Page des meilleurs scores
//
// Accessible depuis PlayMenuScreen via le bouton SCORES.
// 3 onglets : SOLO / DUO / ENTRAÎNEMENT
// Chaque onglet liste les 10 meilleures parties avec :
//   - rang (médaille pour le top 3)
//   - pseudo du joueur
//   - score et pourcentage
//   - date de la partie
// ---------------------------------------------------------------------------
class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen>
    with SingleTickerProviderStateMixin {

  // Onglets disponibles — correspondent aux modes de jeu
  static const List<Map<String, String>> _tabs = [
    {'label': 'SOLO',         'mode': 'solo'},
    {'label': 'DUO',          'mode': 'duo'},
    {'label': 'ENTRAÎNEMENT', 'mode': 'entrainement'},
  ];

  late final TabController _tabController;

  // Cache des scores par mode pour éviter de relire SharedPreferences
  // à chaque rebuild
  final Map<String, List<ScoreEntry>> _scoreCache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadAllScores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Logique
  // ---------------------------------------------------------------------------

  /// Charge les scores des 3 modes en parallèle puis reconstruit l'UI.
  Future<void> _loadAllScores() async {
    setState(() => _loading = true);

    for (final tab in _tabs) {
      final mode    = tab['mode']!;
      final entries = await scoreManager.getScores(mode);
      _scoreCache[mode] = entries;
    }

    if (mounted) setState(() => _loading = false);
  }

  /// Efface tous les scores du mode actif après confirmation.
  Future<void> _confirmClear(String mode) async {
    settingsManager.playClick();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF002147),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        title: const Text(
          'EFFACER ?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Text(
          'Tous les scores de ce mode seront supprimés.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EFFACER',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await scoreManager.clearScores(mode);
      await _loadAllScores(); // Recharge après suppression
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold   = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
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

              // Titre
              _buildHeader(royalGold),
              const SizedBox(height: 20),

              // Onglets SOLO / DUO / ENTRAÎNEMENT
              _buildTabBar(royalGold),
              const SizedBox(height: 4),

              // Contenu des onglets
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) {
                          return _buildScoreList(tab['mode']!, royalGold);
                        }).toList(),
                      ),
              ),

              // Bouton retour
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 16),
                child: MenuButton(
                  label: 'RETOUR',
                  icon: Icons.arrow_back_rounded,
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  fontSize: 20,
                  onTap: () {
                    settingsManager.playClick();
                    Navigator.pop(context);
                  },
                ).animate().fadeIn(delay: 400.ms),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tête : trophée + titre "MEILLEURS SCORES".
  Widget _buildHeader(Color gold) {
    return Column(
      children: [
        const Text('🏆', style: TextStyle(fontSize: 48))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.95, 0.95),
              end:   const Offset(1.05, 1.05),
              duration: 1500.ms,
            ),
        const SizedBox(height: 8),
        Text(
          'MEILLEURS SCORES',
          style: TextStyle(
            color: gold,
            fontSize: 26,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
      ],
    );
  }

  /// Barre d'onglets personnalisée avec style Royal Rumble.
  Widget _buildTabBar(Color gold) {
    return TabBar(
      controller: _tabController,
      indicatorColor: gold,
      indicatorWeight: 3,
      labelColor: gold,
      unselectedLabelColor: Colors.white38,
      labelStyle: const TextStyle(fontSize: 13, letterSpacing: 1.5),
      tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
    );
  }

  /// Liste des scores pour un mode donné.
  Widget _buildScoreList(String mode, Color gold) {
    final entries = _scoreCache[mode] ?? [];

    if (entries.isEmpty) {
      return _buildEmptyState(gold);
    }

    return Column(
      children: [
        // Bouton effacer en haut à droite
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: GestureDetector(
              onTap: () => _confirmClear(mode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 14),
                    SizedBox(width: 4),
                    Text('EFFACER',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Liste des entrées
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: entries.length,
            itemBuilder: (_, i) => _buildScoreEntry(entries[i], i, gold),
          ),
        ),
      ],
    );
  }

  /// État vide : aucun score enregistré pour ce mode.
  Widget _buildEmptyState(Color gold) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎮',
            style: TextStyle(
                fontSize: 52, color: Colors.white.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune partie jouée',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lance une partie pour voir ton score ici !',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 13,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  /// Carte d'une entrée de score avec rang, pseudo, score, date.
  Widget _buildScoreEntry(ScoreEntry entry, int index, Color gold) {
    // Médaille pour le top 3
    final String rankLabel = index == 0
        ? '🥇'
        : index == 1
            ? '🥈'
            : index == 2
                ? '🥉'
                : '${index + 1}';

    // Couleur de la carte selon le rang
    final Color cardBorder = index == 0
        ? gold
        : index == 1
            ? Colors.grey.shade400
            : index == 2
                ? const Color(0xFFCD7F32) // bronze
                : Colors.white24;

    // Couleur du pourcentage selon la performance
    final Color perfColor = entry.ratio >= 0.8
        ? Colors.greenAccent
        : entry.ratio >= 0.5
            ? gold
            : Colors.orange;

    // Date formatée lisiblement
    final String dateStr = _formatDate(entry.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF002147),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: index < 3 ? 1.5 : 1),
          boxShadow: index == 0
              ? [BoxShadow(color: gold.withValues(alpha: 0.15), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            // Rang / médaille
            SizedBox(
              width: 36,
              child: Text(
                rankLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: index < 3 ? 22 : 16,
                  color: index < 3 ? null : Colors.white38,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Pseudo + badge jeu + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pseudo du joueur
                  Text(
                    entry.playerName.toUpperCase(),
                    style: TextStyle(
                      color: index == 0 ? gold : Colors.white,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Badge du nom du jeu — utile quand plusieurs jeux coexistent
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: gold.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Text(
                      entry.gameName.toUpperCase(),
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.8),
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Date de la partie
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Score + pourcentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.score} pts',
                  style: TextStyle(
                    color: perfColor,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${(entry.ratio * 100).round()}%',
                  style: TextStyle(
                    color: perfColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: -0.05),
    );
  }

  /// Formate une date en "12 jan. 2025 · 14h30".
  String _formatDate(DateTime dt) {
    const months = [
      'jan.','fév.','mar.','avr.','mai','jun.',
      'jul.','aoû.','sep.','oct.','nov.','déc.',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · ${h}h$m';
  }
}