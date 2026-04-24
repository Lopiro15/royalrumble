// Types de messages échangés entre les joueurs
enum VersusMessageType {
  challenge,        // Défi envoyé
  challengeAccepted, // Défi accepté
  challengeRejected, // Défi refusé
  gameStart,        // Début de partie
  gameResult,       // Résultat d'un jeu
  roundResult,      // Résultat d'une manche
  waiting,          // En attente de l'autre joueur
  matchEnd,         // Fin du match
  ping,             // Ping pour vérifier la connexion
}

class VersusGameConfig {
  final int totalRounds; // 3, 5 ou 7
  final int winsNeeded;  // 2, 3 ou 4

  const VersusGameConfig(this.totalRounds, this.winsNeeded);

  static const VersusGameConfig bestOf3 = VersusGameConfig(3, 2);
  static const VersusGameConfig bestOf5 = VersusGameConfig(5, 3);
  static const VersusGameConfig bestOf7 = VersusGameConfig(7, 4);

  static VersusGameConfig fromRounds(int rounds) {
    switch (rounds) {
      case 3: return bestOf3;
      case 5: return bestOf5;
      case 7: return bestOf7;
      default: return bestOf3;
    }
  }
}