// ---------------------------------------------------------------------------
// quiz_data_mot_fantome.dart — Base de données du Mot Fantôme (Type 2)
//
// Structure : { 'definition': texte affiché, 'answer': mot EN MAJUSCULES }
// Le joueur doit taper la réponse lettre par lettre sur le clavier chaotique.
//
// Règles pour ajouter une question :
//   - La réponse doit être UN SEUL MOT en majuscules, sans accents ni espaces
//   - Préférer des mots de 3 à 8 lettres (plus court = trop facile, plus long = frustrant)
//   - La définition doit être très simple et directe
// ---------------------------------------------------------------------------

/// Questions disponibles pour le Mot Fantôme.
const List<Map<String, String>> quizMotFantomeQuestions = [

  // ── ANIMAUX ───────────────────────────────────────────────────────────────
  {'definition': 'Animal qui fait MIAOU 🐱',              'answer': 'CHAT'},
  {'definition': 'Animal qui aboie 🐶',                   'answer': 'CHIEN'},
  {'definition': 'Animal rayé noir et blanc 🦓',          'answer': 'ZEBRE'},
  {'definition': 'Gros animal gris à trompe 🐘',          'answer': 'ELEPHANT'},
  {'definition': 'Roi de la jungle 🦁',                   'answer': 'LION'},
  {'definition': 'Animal le plus rapide sur terre 🐆',    'answer': 'GUEPARD'},
  {'definition': 'Oiseau qui ne vole pas, vit au pôle 🐧','answer': 'MANCHOT'},
  {'definition': 'Animal à coquille qui vit dans la mer 🐢','answer': 'TORTUE'},
  {'definition': 'Insecte qui produit du miel 🍯',        'answer': 'ABEILLE'},
  {'definition': 'Amphibien vert qui coasse 🐸',          'answer': 'GRENOUILLE'},

  // ── NATURE & MÉTÉO ─────────────────────────────────────────────────────────
  {'definition': 'Astre qui brille la nuit 🌙',           'answer': 'LUNE'},
  {'definition': 'Astre du système solaire le plus proche ☀️', 'answer': 'SOLEIL'},
  {'definition': 'Eau congelée qui tombe du ciel ❄️',     'answer': 'NEIGE'},
  {'definition': 'Arc coloré après la pluie 🌈',          'answer': 'ARC'},
  {'definition': 'Saison la plus chaude 🌞',              'answer': 'ETE'},
  {'definition': 'Saison avec des feuilles qui tombent 🍂','answer': 'AUTOMNE'},
  {'definition': 'Masse d\'eau entourée de terre 🏝',     'answer': 'ILE'},
  {'definition': 'Sommet enneigé très haut ⛰',           'answer': 'MONTAGNE'},
  {'definition': 'Cours d\'eau qui rejoint la mer 🏞',    'answer': 'RIVIERE'},
  {'definition': 'Grande étendue d\'eau salée 🌊',        'answer': 'OCEAN'},

  // ── NOURRITURE ────────────────────────────────────────────────────────────
  {'definition': 'Fruit jaune des singes 🍌',             'answer': 'BANANE'},
  {'definition': 'Fruit rouge qu\'on cueille en été 🍓',  'answer': 'FRAISE'},
  {'definition': 'Légume orange riche en vitamine A 🥕',  'answer': 'CAROTTE'},
  {'definition': 'Boisson chaude du matin ☕',             'answer': 'CAFE'},
  {'definition': 'Aliment de base fait avec de la farine 🍞','answer': 'PAIN'},
  {'definition': 'Dessert glacé à lécher 🍦',             'answer': 'GLACE'},
  {'definition': 'Plat italien allongé cuit dans l\'eau 🍝','answer': 'PATE'},
  {'definition': 'Fromage jaune avec des trous 🧀',       'answer': 'GRUYERE'},
  {'definition': 'Boisson sucrée pétillante 🥤',          'answer': 'SODA'},
  {'definition': 'Gâteau plat qu\'on mange au petit-déj 🥞','answer': 'CREPE'},

  // ── OBJETS DU QUOTIDIEN ───────────────────────────────────────────────────
  {'definition': 'Instrument pour écrire ✏️',             'answer': 'CRAYON'},
  {'definition': 'On le consulte pour connaître l\'heure ⌚','answer': 'MONTRE'},
  {'definition': 'On l\'utilise pour téléphoner 📱',      'answer': 'TELEPHONE'},
  {'definition': 'Meuble où on dort 🛏',                  'answer': 'LIT'},
  {'definition': 'On s\'en sert pour couper 🔪',          'answer': 'COUTEAU'},
  {'definition': 'Sert à ouvrir une porte 🗝',            'answer': 'CLE'},
  {'definition': 'Écran rectangulaire dans le salon 📺',  'answer': 'TELEVISION'},
  {'definition': 'On s\'y regarde le matin 🪞',           'answer': 'MIROIR'},
  {'definition': 'Contient des vêtements pour voyager 🧳','answer': 'VALISE'},
  {'definition': 'Lumière qu\'on tient à la main 🔦',     'answer': 'LAMPE'},

  // ── COULEURS & FORMES ─────────────────────────────────────────────────────
  {'definition': 'Couleur du ciel par beau temps ☀️',     'answer': 'BLEU'},
  {'definition': 'Couleur de l\'herbe 🌿',                'answer': 'VERT'},
  {'definition': 'Couleur du sang 🩸',                    'answer': 'ROUGE'},
  {'definition': 'Figure à 3 côtés △',                   'answer': 'TRIANGLE'},
  {'definition': 'Figure parfaitement ronde ○',           'answer': 'CERCLE'},
];