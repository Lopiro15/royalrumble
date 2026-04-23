import 'dart:math';
import 'package:get/get.dart';

enum SoloGamePhase { playing, betweenGames, finished }

class SoloGameResult {
  final String gameName;
  final int score;
  final int maxScore;
  final bool isVictory; // score >= 50% du max

  SoloGameResult({
    required this.gameName,
    required this.score,
    required this.maxScore,
    required this.isVictory,
  });

  double get ratio => maxScore > 0 ? score / maxScore : 0;
  String get percentage => '${(ratio * 100).round()}%';
}

class SoloGameStore extends GetxController {
  // Configuration
  static const int totalGamesInSession = 3;
  static const List<String> availableGames = [
    'QUIZ',
    'CAR ROYAL',
    'METEOR SHOWER',
    'PUZZLE ROYAL',
    'TOUR D\'HANOI',
    'LABYRINTH ROYAL',
    'SQUARE CONQUEST',
    'AIR HOCKEY',
  ];

  // État
  final Rx<SoloGamePhase> phase = SoloGamePhase.playing.obs;
  final RxInt currentGameIndex = 0.obs;
  final RxList<String> selectedGames = <String>[].obs;
  final RxList<SoloGameResult> results = <SoloGameResult>[].obs;

  // Score cumulé
  final RxInt totalScore = 0.obs;
  final RxInt totalMaxScore = 0.obs;

  // État du jeu en cours
  final RxBool isGameFinished = false.obs;
  final RxInt currentGameScore = 0.obs;
  final RxInt currentGameMaxScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _selectRandomGames();
  }

  void _selectRandomGames() {
    final random = Random();
    final List<String> shuffled = List.from(availableGames)..shuffle(random);
    selectedGames.value = shuffled.take(totalGamesInSession).toList();
  }

  String get currentGame => selectedGames[currentGameIndex.value];

  int get gamesRemaining => totalGamesInSession - currentGameIndex.value - 1;

  double get overallRatio => totalMaxScore.value > 0
      ? totalScore.value / totalMaxScore.value
      : 0;

  bool get isOverallVictory => overallRatio >= 0.5;

  void recordGameResult({
    required int score,
    required int maxScore,
  }) {
    final bool isVictory = maxScore > 0 && score >= maxScore * 0.5;

    final result = SoloGameResult(
      gameName: currentGame,
      score: score,
      maxScore: maxScore,
      isVictory: isVictory,
    );

    results.add(result);
    totalScore.value += score;
    totalMaxScore.value += maxScore;

    currentGameScore.value = score;
    currentGameMaxScore.value = maxScore;
    isGameFinished.value = true;
  }

  void nextGame() {
    if (currentGameIndex.value < totalGamesInSession - 1) {
      currentGameIndex.value++;
      isGameFinished.value = false;
      currentGameScore.value = 0;
      currentGameMaxScore.value = 0;
      phase.value = SoloGamePhase.playing;
    } else {
      phase.value = SoloGamePhase.finished;
    }
  }

  void reset() {
    phase.value = SoloGamePhase.playing;
    currentGameIndex.value = 0;
    results.clear();
    totalScore.value = 0;
    totalMaxScore.value = 0;
    isGameFinished.value = false;
    currentGameScore.value = 0;
    currentGameMaxScore.value = 0;
    _selectRandomGames();
  }

  void quitSoloMode() {
    reset();
    Get.until((route) => route.isFirst);
  }
}