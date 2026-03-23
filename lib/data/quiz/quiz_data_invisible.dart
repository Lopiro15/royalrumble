// ---------------------------------------------------------------------------
// quiz_data_invisible.dart — Base de données du Quiz Invisible (Type 1)
//
// Structure de chaque scène :
//   - 'scene'     : texte descriptif affiché pendant le flash (nullable si image)
//   - 'imagePath' : chemin asset image (nullable si texte) ex: 'assets/quiz/flash_01.png'
//   - 'questions' : liste de maps { 'q', 'choices', 'answer' }
//
// Pour ajouter une scène IMAGE :
//   1. Dépose l'image dans assets/quiz/images/
//   2. Déclare-la dans pubspec.yaml sous assets:
//        - assets/quiz/images/
//   3. Ajoute une entrée avec 'imagePath' renseigné et 'scene' à null
//
// Pour ajouter une scène TEXTE :
//   Ajoute une entrée avec 'scene' renseigné et 'imagePath' à null
// ---------------------------------------------------------------------------

/// Toutes les scènes disponibles pour le Quiz Invisible.
/// Le moteur tire une scène aléatoire puis UNE question aléatoire parmi ses 3.
const List<Map<String, dynamic>> quizInvisibleScenes = [

  // ── SCÈNES TEXTE ──────────────────────────────────────────────────────────

  {
    'scene': 'Un homme en CHAPEAU ROUGE monte un VÉLO VERT\ndans une rue pavée, sous la PLUIE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était le chapeau ?',  'choices': ['Bleu','Rouge','Noir','Jaune'],          'answer': 'Rouge'},
      {'q': 'Quel véhicule utilisait l\'homme ?',    'choices': ['Moto','Trottinette','Vélo','Voiture'],  'answer': 'Vélo'},
      {'q': 'Quel temps faisait-il ?',               'choices': ['Soleil','Neige','Brouillard','Pluie'],  'answer': 'Pluie'},
    ],
  },
  {
    'scene': 'Une FEMME en robe BLEUE lit un LIVRE JAUNE\nassise sur un BANC en bois, près d\'une fontaine.',
    'imagePath': null,
    'questions': [
      {'q': 'Quelle couleur portait la femme ?',      'choices': ['Rouge','Verte','Bleue','Noire'],        'answer': 'Bleue'},
      {'q': 'Que lisait-elle ?',                      'choices': ['Journal','Livre','Tablette','Carte'],   'answer': 'Livre'},
      {'q': 'Où était-elle assise ?',                 'choices': ['Herbe','Escalier','Banc','Mur'],        'answer': 'Banc'},
    ],
  },
  {
    'scene': 'Un CHIEN ORANGE court après un CHAT GRIS\ndans un jardin avec une CLÔTURE BLANCHE.',
    'imagePath': null,
    'questions': [
      {'q': 'Quelle couleur était le chien ?',        'choices': ['Marron','Noir','Orange','Blanc'],       'answer': 'Orange'},
      {'q': 'Quel animal fuyait ?',                   'choices': ['Lapin','Chat','Oiseau','Souris'],       'answer': 'Chat'},
      {'q': 'De quelle couleur était la clôture ?',   'choices': ['Marron','Verte','Grise','Blanche'],     'answer': 'Blanche'},
    ],
  },
  {
    'scene': 'Un enfant en T-SHIRT JAUNE joue avec\nun BALLON ROUGE devant une maison BLEUE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était le t-shirt ?',   'choices': ['Rouge','Vert','Jaune','Blanc'],         'answer': 'Jaune'},
      {'q': 'Avec quoi jouait l\'enfant ?',            'choices': ['Ballon','Vélo','Cerf-volant','Corde'], 'answer': 'Ballon'},
      {'q': 'De quelle couleur était la maison ?',    'choices': ['Rouge','Bleue','Jaune','Verte'],        'answer': 'Bleue'},
    ],
  },
  {
    'scene': 'Une VOITURE NOIRE est garée devant\nun SUPERMARCHÉ VERT. Il est 14H00.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était la voiture ?',   'choices': ['Rouge','Blanche','Noire','Bleue'],      'answer': 'Noire'},
      {'q': 'Devant quel bâtiment était-elle garée ?','choices': ['École','Hôpital','Supermarché','Gare'], 'answer': 'Supermarché'},
      {'q': 'Quelle heure était-il ?',                'choices': ['10H00','12H00','14H00','16H00'],        'answer': '14H00'},
    ],
  },
  {
    'scene': 'Un VIEUX MONSIEUR avec une CANNE BLEUE\nporte un SEAU ROUGE plein d\'EAU.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était la canne ?',     'choices': ['Verte','Bleue','Marron','Noire'],       'answer': 'Bleue'},
      {'q': 'Que portait-il ?',                       'choices': ['Valise','Sac','Seau','Panier'],         'answer': 'Seau'},
      {'q': 'Que contenait le seau ?',                'choices': ['Sable','Eau','Lait','Pommes'],          'answer': 'Eau'},
    ],
  },
  {
    'scene': 'Une TABLE RONDE en bois avec TROIS CHAISES\net un VASE VIOLET au centre.',
    'imagePath': null,
    'questions': [
      {'q': 'Quelle forme avait la table ?',          'choices': ['Carrée','Rectangulaire','Ronde','Ovale'],'answer': 'Ronde'},
      {'q': 'Combien y avait-il de chaises ?',        'choices': ['2','3','4','5'],                        'answer': '3'},
      {'q': 'De quelle couleur était le vase ?',      'choices': ['Rouge','Jaune','Violet','Vert'],        'answer': 'Violet'},
    ],
  },
  {
    'scene': 'Un CHAT BLANC dort sur un CANAPÉ ROUGE\nprès d\'une FENÊTRE OUVERTE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était le chat ?',      'choices': ['Noir','Gris','Blanc','Roux'],           'answer': 'Blanc'},
      {'q': 'Sur quoi dormait-il ?',                  'choices': ['Tapis','Canapé','Lit','Chaise'],        'answer': 'Canapé'},
      {'q': 'La fenêtre était-elle ouverte ?',        'choices': ['Oui','Non','Entrouverte','Cassée'],     'answer': 'Oui'},
    ],
  },
  {
    'scene': 'Un GÂTEAU AU CHOCOLAT avec CINQ BOUGIES\nposé sur une NAPPE ROSE à POIS BLANCS.',
    'imagePath': null,
    'questions': [
      {'q': 'Quel parfum avait le gâteau ?',          'choices': ['Vanille','Fraise','Chocolat','Citron'], 'answer': 'Chocolat'},
      {'q': 'Combien y avait-il de bougies ?',        'choices': ['3','4','5','6'],                        'answer': '5'},
      {'q': 'De quelle couleur était la nappe ?',     'choices': ['Bleue','Rose','Verte','Blanche'],       'answer': 'Rose'},
    ],
  },
  {
    'scene': 'Un AVION BLANC traverse un CIEL ORANGE\nau coucher du soleil, laissant une TRAÎNÉE GRISE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était l\'avion ?',     'choices': ['Gris','Rouge','Blanc','Bleu'],          'answer': 'Blanc'},
      {'q': 'De quelle couleur était le ciel ?',      'choices': ['Bleu','Orange','Noir','Rose'],          'answer': 'Orange'},
      {'q': 'Quelle couleur avait la traînée ?',      'choices': ['Blanche','Bleue','Grise','Noire'],      'answer': 'Grise'},
    ],
  },
  {
    'scene': 'Un MARCHAND vend des POMMES ROUGES\nsur un ÉTAL EN BOIS dans une RUE PIÉTONNE.',
    'imagePath': null,
    'questions': [
      {'q': 'Que vendait le marchand ?',              'choices': ['Oranges','Bananes','Pommes','Poires'],  'answer': 'Pommes'},
      {'q': 'De quelle couleur étaient les fruits ?', 'choices': ['Vertes','Jaunes','Rouges','Violettes'], 'answer': 'Rouges'},
      {'q': 'Sur quoi était posé l\'étal ?',          'choices': ['Métal','Bois','Plastique','Pierre'],    'answer': 'Bois'},
    ],
  },
  {
    'scene': 'Un GARÇON en VESTE VERTE pédale\nsur un VÉLO JAUNE sur un CHEMIN DE TERRE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était la veste ?',     'choices': ['Rouge','Bleue','Verte','Noire'],        'answer': 'Verte'},
      {'q': 'De quelle couleur était le vélo ?',      'choices': ['Rouge','Vert','Jaune','Blanc'],         'answer': 'Jaune'},
      {'q': 'Quel type de chemin empruntait-il ?',    'choices': ['Asphalte','Sable','Terre','Galets'],    'answer': 'Terre'},
    ],
  },
  {
    'scene': 'Une BIBLIOTHÈQUE MARRON contient\nDEUX RANGÉES DE LIVRES et un GLOBE TERRESTRE BLEU.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était la bibliothèque ?','choices': ['Noire','Blanche','Marron','Rouge'],   'answer': 'Marron'},
      {'q': 'Combien de rangées de livres y avait-il ?','choices': ['1','2','3','4'],                      'answer': '2'},
      {'q': 'De quelle couleur était le globe ?',      'choices': ['Vert','Bleu','Rouge','Jaune'],         'answer': 'Bleu'},
    ],
  },
  {
    'scene': 'Un PHARE BLANC et ROUGE se dresse\nsur des ROCHERS GRIS au bord de la MER.',
    'imagePath': null,
    'questions': [
      {'q': 'Quelles couleurs avait le phare ?',      'choices': ['Bleu et blanc','Blanc et rouge','Jaune et noir','Vert et blanc'], 'answer': 'Blanc et rouge'},
      {'q': 'Sur quoi le phare se trouvait-il ?',     'choices': ['Sable','Herbe','Rochers','Pilotis'],    'answer': 'Rochers'},
      {'q': 'De quelle couleur étaient les rochers ?','choices': ['Noirs','Beiges','Gris','Bruns'],        'answer': 'Gris'},
    ],
  },
  {
    'scene': 'Une FEMME aux CHEVEUX ROUX porte\nun PARAPLUIE VIOLET par temps de BROUILLARD.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur étaient ses cheveux ?','choices': ['Blonds','Bruns','Roux','Noirs'],        'answer': 'Roux'},
      {'q': 'De quelle couleur était le parapluie ?', 'choices': ['Rouge','Bleu','Violet','Vert'],         'answer': 'Violet'},
      {'q': 'Quel temps faisait-il ?',                'choices': ['Pluie','Soleil','Brouillard','Neige'],  'answer': 'Brouillard'},
    ],
  },
  {
    'scene': 'Un ROBOT ARGENTÉ tient une FLEUR ROUGE\ndans sa MAIN GAUCHE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était le robot ?',     'choices': ['Doré','Blanc','Argenté','Noir'],        'answer': 'Argenté'},
      {'q': 'Que tenait-il ?',                        'choices': ['Ballon','Fleur','Livre','Clé'],         'answer': 'Fleur'},
      {'q': 'Dans quelle main tenait-il l\'objet ?',  'choices': ['Droite','Gauche','Les deux','Aucune'],  'answer': 'Gauche'},
    ],
  },
  {
    'scene': 'Un POISSON ORANGE nage dans\nun AQUARIUM CARRÉ posé sur une TABLE NOIRE.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était le poisson ?',   'choices': ['Rouge','Bleu','Orange','Jaune'],        'answer': 'Orange'},
      {'q': 'Quelle forme avait l\'aquarium ?',        'choices': ['Rond','Hexagonal','Carré','Ovale'],     'answer': 'Carré'},
      {'q': 'De quelle couleur était la table ?',     'choices': ['Blanche','Brune','Noire','Grise'],      'answer': 'Noire'},
    ],
  },
  {
    'scene': 'Un POMPIER en TENUE JAUNE descend\nune ÉCHELLE ROUGE depuis un IMMEUBLE GRIS.',
    'imagePath': null,
    'questions': [
      {'q': 'De quelle couleur était la tenue ?',     'choices': ['Rouge','Orange','Jaune','Bleue'],       'answer': 'Jaune'},
      {'q': 'De quelle couleur était l\'échelle ?',   'choices': ['Jaune','Rouge','Grise','Noire'],        'answer': 'Rouge'},
      {'q': 'De quelle couleur était l\'immeuble ?',  'choices': ['Beige','Blanc','Gris','Marron'],        'answer': 'Gris'},
    ],
  },
  {
    'scene': 'Une VACHE NOIRE ET BLANCHE broute\ndans un PRÉ VERT sous un CIEL NUAGEUX.',
    'imagePath': null,
    'questions': [
      {'q': 'Quelles couleurs avait la vache ?',      'choices': ['Marron et blanc','Noir et blanc','Gris et blanc','Roux et blanc'], 'answer': 'Noir et blanc'},
      {'q': 'Que faisait-elle ?',                     'choices': ['Dormait','Courait','Broutait','Buvait'],'answer': 'Broutait'},
      {'q': 'Comment était le ciel ?',                'choices': ['Ensoleillé','Nuageux','Orageux','Rose'],'answer': 'Nuageux'},
    ],
  },
  {
    'scene': 'Un CHÂTEAU MÉDIÉVAL en PIERRE GRISE\nse reflète dans un LAC BLEU.',
    'imagePath': null,
    'questions': [
      {'q': 'En quoi était construit le château ?',   'choices': ['Bois','Brique','Pierre','Métal'],       'answer': 'Pierre'},
      {'q': 'Quel type de construction était-ce ?',   'choices': ['Cathédrale','Château','Tour','Fort'],   'answer': 'Château'},
      {'q': 'Dans quoi se reflétait-il ?',            'choices': ['Rivière','Lac','Étang','Mer'],          'answer': 'Lac'},
    ],
  },
  {
    'scene': 'TROIS ENFANTS en MAILLOTS COLORÉS\nplongent dans une PISCINE BLEUE.',
    'imagePath': null,
    'questions': [
      {'q': 'Combien d\'enfants y avait-il ?',        'choices': ['2','3','4','5'],                        'answer': '3'},
      {'q': 'Que faisaient-ils ?',                    'choices': ['Nageaient','Plongeaient','Couraient','Jouaient'], 'answer': 'Plongeaient'},
      {'q': 'De quelle couleur était la piscine ?',   'choices': ['Verte','Grise','Bleue','Blanche'],      'answer': 'Bleue'},
    ],
  },

  // ── SCÈNES IMAGE (exemples — à activer quand les assets sont prêts) ────────
  // Pour activer : renseigner 'imagePath' et mettre 'scene' à null
  // Les images doivent être déclarées dans pubspec.yaml

   {
     'scene': null,
     'imagePath': 'assets/quiz/images/cuisine.jpg',
     'questions': [
       {'q': 'Combien y avait-il de chaises ?',      'choices': ['2','3','4','6'],    'answer': '4'},
       {'q': 'De quelle couleur étaient les murs ?', 'choices': ['Blancs','Jaunes','Verts','Gris'], 'answer': 'Blancs'},
      {'q': "Qu'est-ce qui était posé au milieu de la table ?",  'choices': ['Livre','Assiette','Vase','Lampe'], 'answer': 'Vase'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/conteneur.jpg',
    'questions': [
      {'q': 'Quelle marque est écrite sur le conteneur VERT ?',
       'choices': ['Hapag-Lloyd','ONE','Evergreen','Triton'],         'answer': 'Evergreen'},
      {'q': 'De quelle couleur sont les conteneurs Hapag-Lloyd ?',
       'choices': ['Verts','Blancs','Rouges','Orange'],               'answer': 'Orange'},
      {'q': 'De quel type est le sol dans la cour ?',
       'choices': ['Asphalte','Béton','Pavés','Gravier'],             'answer': 'Pavés'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/golf.jpg',
    'questions': [
      {'q': 'De quelle couleur est le drapeau sur le green ?',
       'choices': ['Rouge','Blanc','Jaune','Bleu'],                   'answer': 'Jaune'},
      {'q': 'Combien de balles de golf voit-on sur le green ?',
       'choices': ['1','2','3','4'],                                  'answer': '2'},
      {'q': 'Que représentent les zones de sable sur le parcours ?',
       'choices': ['Lacs','Chemins','Bunkers','Zones de départ'],     'answer': 'Bunkers'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/panneau.jpg',
    'questions': [
      {'q': 'Quel est le premier panneau en haut (direction autoroute) ?',
       'choices': ['Maison','Maman','Boulangerie','Boulot'],          'answer': 'Boulot'},
      {'q': 'Quelle distance indique le panneau MAMAN ?',
       'choices': ['1,2 m','3,4 m','5,6 m','7,8 m'],                 'answer': '3,4 m'},
      {'q': 'Quel site est indiqué en bas à droite de l\'image ?',
       'choices': ['Konbini','Topito','Demotivateur','9gag'],         'answer': 'Topito'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/route.jpg',
    'questions': [
      {'q': 'De quelle couleur sont les feux de circulation ?',
       'choices': ['Rouges','Orange','Verts','Éteints'],              'answer': 'Verts'},
      {'q': 'De quelle couleur sont les barrières de chantier ?',
       'choices': ['Orange et blanc','Rouge et blanc','Jaune et noir','Bleu et blanc'], 'answer': 'Rouge et blanc'},
       {'q': 'Quelle couleur a la pancarte en arrière-plan ?',            'choices': ['Vert','Orange','Rouge','Bleu'], 'answer': 'Bleu'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/succes.jpg',
    'questions': [
      {'q': 'Quel mot apparaît tout en bas de l\'escalier ?',
       'choices': ['FOCUS','HUSTLE','VISION','RISKS'],                'answer': 'RISKS'},
      {'q': 'Quel mot se trouve au sommet de l\'escalier ?',
       'choices': ['HUSTLE','DISCIPLINE','SUCCESS','VISION'],         'answer': 'SUCCESS'},
      {'q': 'De quelle couleur sont les marches de l\'escalier ?',
       'choices': ['Blanches','Grises','Noires','Marron'],            'answer': 'Noires'},
    ],
  },
  {
    'scene': null,
    'imagePath': 'assets/quiz/images/tennis.jpg',
    'questions': [
      {'q': 'Combien de raquettes de tennis voit-on ?',
       'choices': ['1','2','3','4'],                                  'answer': '2'},
      {'q': 'Quelle marque est visible sur la bouteille ?',
       'choices': ['Evian','Vittel','Starbucks','Nike'],              'answer': 'Starbucks'},
      {'q': 'De quelle couleur est la balle de tennis ?',
       'choices': ['Orange','Blanche','Jaune','Verte'],               'answer': 'Jaune'},
    ],
  },
];