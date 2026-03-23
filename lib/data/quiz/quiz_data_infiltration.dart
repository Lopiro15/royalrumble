// ---------------------------------------------------------------------------
// quiz_data_infiltration.dart — Base de données de l'Infiltration (Type 5)
//
// Structure :
//   - 'answer'       : réponse EN MAJUSCULES (saisie libre)
//   - 'hint1'        : indice vague (100 pts)
//   - 'hint2'        : indice domaine (50 pts)
//   - 'hint3'        : indice précis (20 pts)
//   - 'fullQuestion' : question complète révélée si aucun buzz
//
// Règles :
//   - La réponse doit être UN seul mot (sans espace) en majuscules
//   - hint1 très vague, hint3 presque révélateur
//   - fullQuestion = la vraie question si personne ne buzze
// ---------------------------------------------------------------------------

/// Questions disponibles pour l'Infiltration de Données.
const List<Map<String, String>> quizInfiltrationQuestions = [

  // ── PERSONNAGES HISTORIQUES ───────────────────────────────────────────────
  {
    'answer':       'NAPOLEON',
    'hint1':        '👁 Un homme de pouvoir du 19e siècle',
    'hint2':        '🏛 Domaine : Histoire de France',
    'hint3':        '📖 Il fut empereur des Français',
    'fullQuestion': 'Quel était le nom de famille de Bonaparte, l\'empereur ?',
  },
  {
    'answer':       'CLEOPATRE',
    'hint1':        '👁 Une figure légendaire de l\'Antiquité',
    'hint2':        '🏛 Domaine : Égypte ancienne',
    'hint3':        '📖 Elle était pharaonne et aima César puis Marc Antoine',
    'fullQuestion': 'Quel est le prénom de la célèbre reine d\'Égypte ?',
  },
  {
    'answer':       'EINSTEIN',
    'hint1':        '👁 Un génie du 20e siècle',
    'hint2':        '🏛 Domaine : Physique théorique',
    'hint3':        '📖 Il a formulé la théorie de la relativité',
    'fullQuestion': 'Quel est le nom de ce physicien Prix Nobel 1921 ?',
  },
  {
    'answer':       'SHAKESPEARE',
    'hint1':        '👁 Un créateur de génie anglais',
    'hint2':        '🏛 Domaine : Littérature et théâtre',
    'hint3':        '📖 Il a écrit Hamlet et Roméo et Juliette',
    'fullQuestion': 'Quel est le nom de ce dramaturge anglais du 16e siècle ?',
  },
  {
    'answer':       'DARWIN',
    'hint1':        '👁 Un naturaliste révolutionnaire',
    'hint2':        '🏛 Domaine : Biologie et évolution',
    'hint3':        '📖 Il a écrit "L\'Origine des espèces"',
    'fullQuestion': 'Quel scientifique a théorisé la sélection naturelle ?',
  },
  {
    'answer':       'MOZART',
    'hint1':        '👁 Un enfant prodige de la musique',
    'hint2':        '🏛 Domaine : Musique classique',
    'hint3':        '📖 Il est né à Salzbourg et a composé dès l\'âge de 5 ans',
    'fullQuestion': 'Quel est le nom de ce compositeur autrichien du 18e siècle ?',
  },
  {
    'answer':       'MARIE',
    'hint1':        '👁 Une scientifique doublement récompensée',
    'hint2':        '🏛 Domaine : Physique et chimie',
    'hint3':        '📖 Elle est la première femme Prix Nobel, et en a reçu deux',
    'fullQuestion': 'Quel est le prénom de Madame Curie ?',
  },
  {
    'answer':       'GANDHI',
    'hint1':        '👁 Un leader pacifiste du 20e siècle',
    'hint2':        '🏛 Domaine : Politique et indépendance',
    'hint3':        '📖 Il a conduit la lutte pour l\'indépendance de l\'Inde',
    'fullQuestion': 'Quel est le nom de ce leader de la non-violence indien ?',
  },

  // ── INVENTIONS & TECHNOLOGIE ──────────────────────────────────────────────
  {
    'answer':       'INTERNET',
    'hint1':        '👁 Une invention moderne indispensable',
    'hint2':        '🏛 Domaine : Informatique et télécommunications',
    'hint3':        '📖 Il relie des milliards d\'appareils dans le monde',
    'fullQuestion': 'Quel réseau mondial permet l\'échange de données ?',
  },
  {
    'answer':       'TELEPHONE',
    'hint1':        '👁 Un objet que tu utilises tous les jours',
    'hint2':        '🏛 Domaine : Communication',
    'hint3':        '📖 Alexander Graham Bell en est l\'inventeur en 1876',
    'fullQuestion': 'Quel appareil permet de parler à distance ?',
  },
  {
    'answer':       'IMPRIMERIE',
    'hint1':        '👁 Une révolution pour le savoir humain',
    'hint2':        '🏛 Domaine : Communication et culture',
    'hint3':        '📖 Gutenberg l\'a inventée au 15e siècle',
    'fullQuestion': 'Quelle invention a permis la diffusion des livres en masse ?',
  },
  {
    'answer':       'ELECTRICITE',
    'hint1':        '👁 Sans elle, le monde moderne s\'arrête',
    'hint2':        '🏛 Domaine : Physique et énergie',
    'hint3':        '📖 Tesla et Edison ont contribué à son développement',
    'fullQuestion': 'Quelle forme d\'énergie alimente nos maisons et appareils ?',
  },
  {
    'answer':       'AVION',
    'hint1':        '👁 Un moyen de transport qui vole',
    'hint2':        '🏛 Domaine : Transport et aviation',
    'hint3':        '📖 Les frères Wright ont réalisé le premier vol en 1903',
    'fullQuestion': 'Quel véhicule a révolutionné le transport aérien ?',
  },
  {
    'answer':       'VACCIN',
    'hint1':        '👁 Un outil médical qui sauve des millions de vies',
    'hint2':        '🏛 Domaine : Médecine et santé publique',
    'hint3':        '📖 Jenner l\'a développé contre la variole au 18e siècle',
    'fullQuestion': 'Quel médicament préventif protège contre les maladies infectieuses ?',
  },

  // ── GÉOGRAPHIE ────────────────────────────────────────────────────────────
  {
    'answer':       'AMAZONE',
    'hint1':        '👁 Un record naturel dans un continent lointain',
    'hint2':        '🏛 Domaine : Géographie et fleuves',
    'hint3':        '📖 C\'est le fleuve au plus grand débit au monde, en Amérique du Sud',
    'fullQuestion': 'Quel est le nom du plus grand fleuve en débit du monde ?',
  },
  {
    'answer':       'HIMALAYA',
    'hint1':        '👁 Un lieu extrême sur notre planète',
    'hint2':        '🏛 Domaine : Géographie et montagnes',
    'hint3':        '📖 C\'est la chaîne de montagnes qui contient l\'Everest',
    'fullQuestion': 'Quelle chaîne de montagnes est la plus haute du monde ?',
  },
  {
    'answer':       'SAHARA',
    'hint1':        '👁 Un endroit très chaud et très sec',
    'hint2':        '🏛 Domaine : Géographie africaine',
    'hint3':        '📖 C\'est le plus grand désert chaud du monde',
    'fullQuestion': 'Quel est le nom du grand désert nord-africain ?',
  },
  {
    'answer':       'ANTARCTIQUE',
    'hint1':        '👁 Le lieu le plus froid de la planète',
    'hint2':        '🏛 Domaine : Géographie polaire',
    'hint3':        '📖 C\'est le continent au pôle Sud',
    'fullQuestion': 'Comment s\'appelle le continent entouré par l\'océan Austral ?',
  },
  {
    'answer':       'PACIFIQUE',
    'hint1':        '👁 Une immensité qui couvre un tiers de la Terre',
    'hint2':        '🏛 Domaine : Géographie et océans',
    'hint3':        '📖 C\'est le plus grand et le plus profond des océans',
    'fullQuestion': 'Quel est le nom du plus grand océan du monde ?',
  },

  // ── SCIENCES & NATURE ─────────────────────────────────────────────────────
  {
    'answer':       'OXYGENE',
    'hint1':        '👁 Sans lui, nous ne pourrions pas respirer',
    'hint2':        '🏛 Domaine : Chimie et atmosphère',
    'hint3':        '📖 Son symbole chimique est O et son numéro atomique est 8',
    'fullQuestion': 'Quel gaz est essentiel à la respiration des êtres vivants ?',
  },
  {
    'answer':       'PHOTOSYNTHESE',
    'hint1':        '👁 Un processus vital pour toute vie sur Terre',
    'hint2':        '🏛 Domaine : Biologie végétale',
    'hint3':        '📖 C\'est le processus par lequel les plantes fabriquent leur nourriture avec la lumière',
    'fullQuestion': 'Quel processus permet aux plantes de convertir la lumière en énergie ?',
  },
  {
    'answer':       'DINOSAURE',
    'hint1':        '👁 Des créatures qui ont disparu il y a longtemps',
    'hint2':        '🏛 Domaine : Paléontologie',
    'hint3':        '📖 Ces reptiles géants ont régné il y a 65 millions d\'années',
    'fullQuestion': 'Comment appelle-t-on ces reptiles préhistoriques éteints ?',
  },
  {
    'answer':       'VOLCAN',
    'hint1':        '👁 Un phénomène naturel impressionnant',
    'hint2':        '🏛 Domaine : Géologie',
    'hint3':        '📖 Il projette de la lave en fusion depuis les profondeurs de la Terre',
    'fullQuestion': 'Quel est ce relief géologique qui peut entrer en éruption ?',
  },
  {
    'answer':       'NEUTRON',
    'hint1':        '👁 Une particule fondamentale de la matière',
    'hint2':        '🏛 Domaine : Physique atomique',
    'hint3':        '📖 C\'est une particule du noyau atomique sans charge électrique',
    'fullQuestion': 'Quelle particule du noyau n\'a pas de charge ?',
  },

  // ── CULTURE POPULAIRE & ARTS ──────────────────────────────────────────────
  {
    'answer':       'JOCONDE',
    'hint1':        '👁 Une œuvre mondialement connue',
    'hint2':        '🏛 Domaine : Peinture de la Renaissance',
    'hint3':        '📖 C\'est le tableau le plus célèbre du Louvre, peint par Léonard de Vinci',
    'fullQuestion': 'Quel est le nom de ce célèbre portrait peint par Léonard de Vinci ?',
  },
  {
    'answer':       'BEETHOVEN',
    'hint1':        '👁 Un génie de la musique malgré son handicap',
    'hint2':        '🏛 Domaine : Musique classique allemande',
    'hint3':        '📖 Il était sourd et a composé sa 9e symphonie dans cet état',
    'fullQuestion': 'Quel compositeur a écrit la célèbre "Lettre à Élise" ?',
  },
  {
    'answer':       'PYRAMIDE',
    'hint1':        '👁 Une construction monumentale millénaire',
    'hint2':        '🏛 Domaine : Architecture égyptienne',
    'hint3':        '📖 Ces tombeaux géants en pierre étaient construits pour les pharaons',
    'fullQuestion': 'Quelle structure architecturale servait de tombeau aux pharaons ?',
  },
  {
    'answer':       'TITANIC',
    'hint1':        '👁 Une tragédie maritime célèbre',
    'hint2':        '🏛 Domaine : Histoire maritime et cinéma',
    'hint3':        '📖 Ce paquebot a coulé en 1912 après avoir heurté un iceberg',
    'fullQuestion': 'Quel est le nom de ce célèbre paquebot naufragé en 1912 ?',
  },
  {
    'answer':       'OLYMPICS',
    'hint1':        '👁 Un événement mondial tous les 4 ans',
    'hint2':        '🏛 Domaine : Sport international',
    'hint3':        '📖 Ces jeux réunissent les meilleurs athlètes de chaque pays',
    'fullQuestion': 'Comment appelle-t-on ces grands jeux sportifs mondiaux ?',
  },

  // ── ANIMAUX ───────────────────────────────────────────────────────────────
  {
    'answer':       'BALEINE',
    'hint1':        '👁 Le plus grand animal vivant',
    'hint2':        '🏛 Domaine : Mammifères marins',
    'hint3':        '📖 La bleue peut mesurer jusqu\'à 30 mètres de long',
    'fullQuestion': 'Quel est le plus grand animal de la planète ?',
  },
  {
    'answer':       'CAMELEON',
    'hint1':        '👁 Un animal avec une capacité unique',
    'hint2':        '🏛 Domaine : Reptiles',
    'hint3':        '📖 Il peut changer de couleur selon son environnement',
    'fullQuestion': 'Quel reptile est capable de changer de couleur ?',
  },
  {
    'answer':       'PIEUVRE',
    'hint1':        '👁 Un animal marin très intelligent',
    'hint2':        '🏛 Domaine : Invertébrés marins',
    'hint3':        '📖 Elle possède 8 bras et peut s\'échapper de presque partout',
    'fullQuestion': 'Quel mollusque marin possède 8 tentacules et 3 cœurs ?',
  },
  {
    'answer':       'COLIBRI',
    'hint1':        '👁 Un oiseau d\'une dextérité incroyable',
    'hint2':        '🏛 Domaine : Ornithologie',
    'hint3':        '📖 C\'est le seul oiseau capable de voler en arrière',
    'fullQuestion': 'Quel est le plus petit oiseau du monde ?',
  },
];