// ---------------------------------------------------------------------------
// quiz_data_enchere.dart — Base de données de l'Enchère Inversée (Type 4)
//
// Structure : { 'question', 'hint1', 'hint2', 'choices': [4], 'answer' }
// Les indices doivent être de difficulté croissante :
//   - hint1 : domaine très général
//   - hint2 : détail précis qui aide sans trop révéler
//
// Règles :
//   - Questions difficiles en premier (sans indice = challenge)
//   - hint1 doit rester vague (domaine, époque, catégorie)
//   - hint2 peut être plus précis mais pas la réponse directe
// ---------------------------------------------------------------------------

/// Questions disponibles pour l'Enchère Inversée.
const List<Map<String, dynamic>> quizEnchereQuestions = [

  // ── SCIENCES ──────────────────────────────────────────────────────────────
  {
    'question': 'Quel scientifique a formulé la théorie de la relativité ?',
    'hint1':    '💡 Domaine : Physique théorique',
    'hint2':    '💡 Il a reçu le Prix Nobel de Physique en 1921',
    'choices':  ['Newton','Einstein','Curie','Hawking'],
    'answer':   'Einstein',
  },
  {
    'question': 'Quel élément chimique a le symbole Fe ?',
    'hint1':    '💡 C\'est un métal très commun',
    'hint2':    '💡 On l\'utilise pour fabriquer de l\'acier',
    'choices':  ['Cuivre','Aluminium','Fer','Zinc'],
    'answer':   'Fer',
  },
  {
    'question': 'Quel scientifique a découvert la pénicilline ?',
    'hint1':    '💡 C\'est un médecin britannique',
    'hint2':    '💡 Sa découverte fut accidentelle en 1928',
    'choices':  ['Pasteur','Fleming','Curie','Koch'],
    'answer':   'Fleming',
  },
  {
    'question': 'À quelle vitesse se propage la lumière dans le vide ?',
    'hint1':    '💡 C\'est une constante fondamentale de la physique',
    'hint2':    '💡 Elle est d\'environ 300 000 km/s',
    'choices':  ['150 000 km/s','200 000 km/s','299 792 km/s','350 000 km/s'],
    'answer':   '299 792 km/s',
  },
  {
    'question': 'Quel gaz est le plus abondant dans l\'atmosphère terrestre ?',
    'hint1':    '💡 Ce n\'est pas l\'oxygène',
    'hint2':    '💡 Il représente environ 78 % de l\'air',
    'choices':  ['Oxygène','CO2','Azote','Argon'],
    'answer':   'Azote',
  },
  {
    'question': 'Combien de paires de chromosomes possède l\'être humain ?',
    'hint1':    '💡 Domaine : Biologie génétique',
    'hint2':    '💡 Le total de chromosomes est 46',
    'choices':  ['21','22','23','24'],
    'answer':   '23',
  },
  {
    'question': 'Quel est le plus petit os du corps humain ?',
    'hint1':    '💡 Il se trouve dans une zone liée aux sens',
    'hint2':    '💡 Il est situé dans l\'oreille',
    'choices':  ['Coccyx','Étrier','Radius','Phalange'],
    'answer':   'Étrier',
  },
  {
    'question': 'Quelle planète possède le plus grand nombre de lunes connues ?',
    'hint1':    '💡 C\'est une géante gazeuse',
    'hint2':    '💡 Elle est connue pour ses anneaux spectaculaires',
    'choices':  ['Jupiter','Uranus','Neptune','Saturne'],
    'answer':   'Saturne',
  },
  {
    'question': 'Quel organe produit l\'insuline ?',
    'hint1':    '💡 C\'est un organe du système digestif',
    'hint2':    '💡 Il se situe derrière l\'estomac',
    'choices':  ['Foie','Rate','Pancréas','Rein'],
    'answer':   'Pancréas',
  },

  // ── HISTOIRE ──────────────────────────────────────────────────────────────
  {
    'question': 'Quelle est la plus haute montagne du monde ?',
    'hint1':    '💡 Située entre le Népal et la Chine',
    'hint2':    '💡 Elle culmine à 8 848 mètres',
    'choices':  ['K2','Mont Blanc','Everest','Kilimandjaro'],
    'answer':   'Everest',
  },
  {
    'question': 'Quel pays a inventé l\'imprimerie à caractères mobiles ?',
    'hint1':    '💡 En Europe occidentale, au 15e siècle',
    'hint2':    '💡 Gutenberg était originaire de ce pays',
    'choices':  ['France','Angleterre','Allemagne','Italie'],
    'answer':   'Allemagne',
  },
  {
    'question': 'En quelle année Christophe Colomb a-t-il découvert l\'Amérique ?',
    'hint1':    '💡 C\'est à la fin du 15e siècle',
    'hint2':    '💡 Il naviguait pour le compte de l\'Espagne',
    'choices':  ['1488','1492','1498','1504'],
    'answer':   '1492',
  },
  {
    'question': 'Quelle était la monnaie de la France avant l\'euro ?',
    'hint1':    '💡 Elle était utilisée depuis le Moyen-Âge',
    'hint2':    '💡 Elle portait le nom d\'une unité de poids',
    'choices':  ['Mark','Peseta','Franc','Lire'],
    'answer':   'Franc',
  },
  {
    'question': 'Quel pharaon a fait construire la grande pyramide de Gizeh ?',
    'hint1':    '💡 Il régna en Égypte ancienne',
    'hint2':    '💡 Son nom commence par la lettre K',
    'choices':  ['Ramsès II','Toutankhamon','Kheops','Nefertiti'],
    'answer':   'Kheops',
  },
  {
    'question': 'Quelle ville fut détruite par l\'éruption du Vésuve en 79 après J.-C. ?',
    'hint1':    '💡 C\'était une ville romaine prospère',
    'hint2':    '💡 Elle fut ensevelie sous les cendres',
    'choices':  ['Rome','Naples','Pompéi','Herculanum'],
    'answer':   'Pompéi',
  },
  {
    'question': 'Quel traité a mis fin à la Première Guerre mondiale ?',
    'hint1':    '💡 Il a été signé en 1919',
    'hint2':    '💡 Il porte le nom d\'un château près de Paris',
    'choices':  ['Traité de Paris','Traité de Versailles','Traité de Rome','Armistice de Berlin'],
    'answer':   'Traité de Versailles',
  },
  {
    'question': 'Qui était le premier Président des États-Unis ?',
    'hint1':    '💡 Il fut élu en 1789',
    'hint2':    '💡 Son portrait figure sur le billet d\'un dollar',
    'choices':  ['Lincoln','Jefferson','Adams','Washington'],
    'answer':   'Washington',
  },

  // ── GÉOGRAPHIE ────────────────────────────────────────────────────────────
  {
    'question': 'Quelle est la capitale du Brésil ?',
    'hint1':    '💡 C\'est une ville d\'Amérique du Sud',
    'hint2':    '💡 Ce n\'est pas Rio de Janeiro ni São Paulo',
    'choices':  ['Rio de Janeiro','São Paulo','Salvador','Brasília'],
    'answer':   'Brasília',
  },
  {
    'question': 'Quel est le pays le plus peuplé du monde ?',
    'hint1':    '💡 C\'est en Asie',
    'hint2':    '💡 Il a dépassé la Chine en 2023',
    'choices':  ['Chine','Indonésie','Inde','Pakistan'],
    'answer':   'Inde',
  },
  {
    'question': 'Quelle est la plus longue chaîne de montagnes du monde ?',
    'hint1':    '💡 Elle se trouve sur un continent de l\'hémisphère sud',
    'hint2':    '💡 Elle longe la côte ouest de l\'Amérique du Sud',
    'choices':  ['Rocheuses','Himalaya','Alpes','Andes'],
    'answer':   'Andes',
  },
  {
    'question': 'Dans quel pays se trouve le fleuve Amazone ?',
    'hint1':    '💡 C\'est en Amérique du Sud',
    'hint2':    '💡 La plus grande forêt tropicale du monde s\'y trouve',
    'choices':  ['Argentine','Pérou','Colombie','Brésil'],
    'answer':   'Brésil',
  },

  // ── CULTURE & ARTS ────────────────────────────────────────────────────────
  {
    'question': 'Combien d\'os compte le squelette humain adulte ?',
    'hint1':    '💡 C\'est un nombre entre 200 et 210',
    'hint2':    '💡 Les bébés en ont davantage, certains fusionnent en grandissant',
    'choices':  ['175','206','250','312'],
    'answer':   '206',
  },
  {
    'question': 'Qui a composé la Cinquième Symphonie ?',
    'hint1':    '💡 C\'est un compositeur allemand',
    'hint2':    '💡 Il était sourd quand il l\'a composée',
    'choices':  ['Mozart','Chopin','Beethoven','Bach'],
    'answer':   'Beethoven',
  },
  {
    'question': 'Dans quel pays fut inventé le cinéma ?',
    'hint1':    '💡 Ce fut à la fin du 19e siècle',
    'hint2':    '💡 Les frères Lumière en sont les inventeurs',
    'choices':  ['États-Unis','Angleterre','Allemagne','France'],
    'answer':   'France',
  },
  {
    'question': 'Qui a écrit Don Quichotte ?',
    'hint1':    '💡 C\'est un auteur espagnol',
    'hint2':    '💡 Il vécut au 16e et 17e siècle',
    'choices':  ['Lope de Vega','Cervantes','Calderón','Quevedo'],
    'answer':   'Cervantes',
  },
  {
    'question': 'Quel peintre a coupé son oreille ?',
    'hint1':    '💡 C\'est un post-impressionniste',
    'hint2':    '💡 Il a peint les Tournesols et La Nuit étoilée',
    'choices':  ['Gauguin','Monet','Van Gogh','Cézanne'],
    'answer':   'Van Gogh',
  },
  {
    'question': 'Quel est le sport le plus pratiqué dans le monde ?',
    'hint1':    '💡 Il se joue avec un ballon rond',
    'hint2':    '💡 Il oppose deux équipes de 11 joueurs',
    'choices':  ['Basketball','Tennis','Cricket','Football'],
    'answer':   'Football',
  },
  {
    'question': 'Quel quel est le roman le plus vendu de tous les temps ?',
    'hint1':    '💡 C\'est un roman de fantasy pour la jeunesse',
    'hint2':    '💡 Son héros est un jeune sorcier à lunettes',
    'choices':  ['Le Seigneur des Anneaux','Harry Potter','Twilight','Narnia'],
    'answer':   'Harry Potter',
  },

  // ── TECHNOLOGIE ───────────────────────────────────────────────────────────
  {
    'question': 'Qui a fondé Microsoft ?',
    'hint1':    '💡 C\'est une entreprise américaine fondée dans les années 70',
    'hint2':    '💡 L\'un des fondateurs s\'appelle Bill',
    'choices':  ['Steve Jobs','Elon Musk','Bill Gates','Mark Zuckerberg'],
    'answer':   'Bill Gates',
  },
  {
    'question': 'En quelle année le premier iPhone est-il sorti ?',
    'hint1':    '💡 C\'était dans les années 2000',
    'hint2':    '💡 Steve Jobs l\'a présenté lors d\'une keynote mémorable',
    'choices':  ['2005','2006','2007','2008'],
    'answer':   '2007',
  },
  {
    'question': 'Quel langage de programmation a créé le World Wide Web ?',
    'hint1':    '💡 Ce n\'est pas vraiment un langage de programmation',
    'hint2':    '💡 C\'est le langage des pages web',
    'choices':  ['CSS','JavaScript','HTML','Python'],
    'answer':   'HTML',
  },

  // ── SPORT ─────────────────────────────────────────────────────────────────
  {
    'question': 'Combien de joueurs forment une équipe de basketball ?',
    'hint1':    '💡 C\'est un nombre impair sur le terrain',
    'hint2':    '💡 Moins que le foot, plus que le tennis',
    'choices':  ['4','5','6','7'],
    'answer':   '5',
  },
  {
    'question': 'Quel pays a remporté le plus de Coupes du Monde de football ?',
    'hint1':    '💡 C\'est un pays d\'Amérique du Sud',
    'hint2':    '💡 Il en a remporté 5 au total',
    'choices':  ['Argentine','Uruguay','Allemagne','Brésil'],
    'answer':   'Brésil',
  },
  {
    'question': 'Quel athlète détient le record du 100m masculin ?',
    'hint1':    '💡 C\'est un sprinter jamaïcain',
    'hint2':    '💡 Son record est de 9,58 secondes',
    'choices':  ['Carl Lewis','Asafa Powell','Usain Bolt','Justin Gatlin'],
    'answer':   'Usain Bolt',
  },
  {
    'question': 'Dans quel sport marque-t-on des "tries" ?',
    'hint1':    '💡 C\'est un sport collectif',
    'hint2':    '💡 Le ballon est ovale',
    'choices':  ['Football américain','Cricket','Hockey','Rugby'],
    'answer':   'Rugby',
  },
  {
    'question': 'Combien de sets faut-il gagner pour remporter un match de tennis en Grand Chelem masculin ?',
    'hint1':    '💡 C\'est plus que 2',
    'hint2':    '💡 Le match peut durer 5 sets au maximum',
    'choices':  ['2','3','4','5'],
    'answer':   '3',
  },
];