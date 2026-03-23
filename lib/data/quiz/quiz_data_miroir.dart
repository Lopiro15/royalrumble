// ---------------------------------------------------------------------------
// quiz_data_miroir.dart — Base de données du Quiz Miroir (Type 3)
//
// Structure : { 'question', 'choices': [4 choix], 'answer' }
// La question s'affiche en miroir horizontal (Transform scaleX:-1).
//
// Règles pour ajouter une question :
//   - Questions courtes (< 60 caractères) → plus lisibles une fois inversées
//   - 4 choix toujours, dont 1 seul correct
//   - Éviter les accents complexes (plus difficiles à lire en miroir)
// ---------------------------------------------------------------------------

/// Questions disponibles pour le Quiz Miroir.
const List<Map<String, dynamic>> quizMiroirQuestions = [

  // ── GÉOGRAPHIE ────────────────────────────────────────────────────────────
  {'question': 'Quelle est la capitale de la France ?',        'choices': ['Madrid','Berlin','Paris','Rome'],             'answer': 'Paris'},
  {'question': 'Quelle est la capitale de l\'Espagne ?',       'choices': ['Barcelone','Séville','Madrid','Valence'],     'answer': 'Madrid'},
  {'question': 'Quel est le plus grand pays du monde ?',       'choices': ['Canada','Chine','USA','Russie'],              'answer': 'Russie'},
  {'question': 'Quel est le plus long fleuve du monde ?',      'choices': ['Amazone','Nil','Mississippi','Yangtsé'],      'answer': 'Nil'},
  {'question': 'Quel pays est surnommé le Pays du Soleil Levant ?', 'choices': ['Chine','Corée','Japon','Thaïlande'],    'answer': 'Japon'},
  {'question': 'Sur quel continent se trouve le Sahara ?',     'choices': ['Asie','Amérique','Australie','Afrique'],      'answer': 'Afrique'},
  {'question': 'Quel est le plus grand océan du monde ?',      'choices': ['Atlantique','Indien','Pacifique','Arctique'], 'answer': 'Pacifique'},
  {'question': 'Dans quel pays se trouve la Tour Eiffel ?',    'choices': ['Belgique','Suisse','France','Italie'],        'answer': 'France'},
  {'question': 'Combien de continents y a-t-il sur Terre ?',   'choices': ['5','6','7','8'],                              'answer': '7'},
  {'question': 'Quelle mer borde le nord de l\'Afrique ?',     'choices': ['Noire','Rouge','Baltique','Méditerranée'],    'answer': 'Méditerranée'},

  // ── MATHÉMATIQUES ─────────────────────────────────────────────────────────
  {'question': 'Combien font 7 × 8 ?',                         'choices': ['54','56','48','64'],                          'answer': '56'},
  {'question': 'Combien font 12 × 12 ?',                       'choices': ['132','144','124','148'],                      'answer': '144'},
  {'question': 'Combien de côtés a un hexagone ?',             'choices': ['5','6','7','8'],                              'answer': '6'},
  {'question': 'Quelle est la racine carrée de 64 ?',          'choices': ['6','7','8','9'],                              'answer': '8'},
  {'question': 'Combien font 15 % de 200 ?',                   'choices': ['20','25','30','35'],                          'answer': '30'},
  {'question': 'Combien de faces a un cube ?',                  'choices': ['4','5','6','8'],                              'answer': '6'},
  {'question': 'Combien font 9² ?',                            'choices': ['72','81','63','90'],                          'answer': '81'},
  {'question': 'Quel est le résultat de 1 000 ÷ 8 ?',         'choices': ['115','120','125','130'],                      'answer': '125'},

  // ── SCIENCES & NATURE ─────────────────────────────────────────────────────
  {'question': 'Quel animal est le plus rapide sur terre ?',    'choices': ['Lion','Guépard','Faucon','Dauphin'],          'answer': 'Guépard'},
  {'question': 'Quelle planète est la plus proche du Soleil ?', 'choices': ['Vénus','Terre','Mercure','Mars'],             'answer': 'Mercure'},
  {'question': 'De quoi les plantes ont-elles besoin pour vivre ?', 'choices': ['Sel','Lumière','Glace','Sable'],          'answer': 'Lumière'},
  {'question': 'Quel gaz respirons-nous principalement ?',      'choices': ['CO2','Azote','Oxygène','Hydrogène'],          'answer': 'Azote'},
  {'question': 'Combien d\'os compte le corps humain ?',        'choices': ['175','196','206','215'],                      'answer': '206'},
  {'question': 'À quelle température l\'eau bout-elle ?',       'choices': ['80°C','90°C','95°C','100°C'],                 'answer': '100°C'},
  {'question': 'Quelle est la plus grande planète du système solaire ?', 'choices': ['Saturne','Neptune','Jupiter','Uranus'], 'answer': 'Jupiter'},
  {'question': 'En quelle année l\'Homme a-t-il marché sur la Lune ?', 'choices': ['1965','1967','1969','1971'],           'answer': '1969'},
  {'question': 'Combien de chromosomes a l\'être humain ?',     'choices': ['23','42','46','48'],                          'answer': '46'},

  // ── CULTURE GÉNÉRALE ──────────────────────────────────────────────────────
  {'question': 'En quelle année a débuté la Seconde Guerre mondiale ?', 'choices': ['1935','1939','1941','1942'],          'answer': '1939'},
  {'question': 'Qui a peint la Joconde ?',                      'choices': ['Michel-Ange','Picasso','Raphaël','Léonard de Vinci'], 'answer': 'Léonard de Vinci'},
  {'question': 'Quel instrument a 88 touches ?',               'choices': ['Guitare','Piano','Violon','Harpe'],            'answer': 'Piano'},
  {'question': 'Combien de joueurs dans une équipe de foot ?',  'choices': ['9','10','11','12'],                           'answer': '11'},
  {'question': 'Quel sport se joue à Wimbledon ?',              'choices': ['Golf','Tennis','Cricket','Rugby'],            'answer': 'Tennis'},
  {'question': 'Dans quel pays a été inventée la pizza ?',      'choices': ['France','Espagne','Grèce','Italie'],          'answer': 'Italie'},
  {'question': 'Combien de cordes a une guitare classique ?',   'choices': ['4','5','6','7'],                              'answer': '6'},
  {'question': 'Quel métal précieux a le symbole Au ?',         'choices': ['Argent','Platine','Or','Cuivre'],             'answer': 'Or'},
  {'question': 'Quel est le symbole chimique de l\'eau ?',      'choices': ['O2','CO2','H2O','HO'],                        'answer': 'H2O'},
  {'question': 'Combien de lettres compte l\'alphabet français ?', 'choices': ['24','25','26','27'],                       'answer': '26'},
  {'question': 'Quel pays a remporté la plus de Coupes du Monde ?', 'choices': ['Allemagne','Argentine','Brésil','France'], 'answer': 'Brésil'},
  {'question': 'Combien de secondes dans une heure ?',          'choices': ['360','600','3600','6000'],                    'answer': '3600'},
  {'question': 'Quel est le livre le plus vendu au monde ?',    'choices': ['Le Coran','La Bible','Harry Potter','Don Quichotte'], 'answer': 'La Bible'},
  {'question': 'Quel pays a inventé les Jeux Olympiques ?',     'choices': ['Rome','Égypte','Grèce','Perse'],              'answer': 'Grèce'},
  {'question': 'En quelle année fut construite la Tour Eiffel ?', 'choices': ['1879','1885','1889','1893'],                'answer': '1889'},
  {'question': 'Quelle est la monnaie du Japon ?',              'choices': ['Yuan','Won','Baht','Yen'],                    'answer': 'Yen'},
];