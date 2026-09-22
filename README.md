Simulation de Bataille Navale (Assembleur MIPS)
Ce projet est une simulation automatisée du célèbre jeu de la Bataille Navale, développée en langage Assembleur MIPS. Il gère de manière autonome la création du plateau, le placement de la flotte et la résolution de la partie via un algorithme de recherche.   
S
+ 1
Fonctionnalités principales
Génération du plateau : Création d'une grille de 10 colonnes par 10 lignes (100 octets alloués en mémoire).   
S
Interface console : Affichage de la grille avec des en-têtes de colonnes (lettres de A à J) et de lignes (numéros de 1 à 10).   
S
Placement aléatoire : Positionnement horizontal ou vertical de 5 navires de tailles différentes (5, 4, 3, 3 et 2 cases) en vérifiant que les emplacements sont libres.   
S
Simulation autonome : Le programme choisit des coordonnées de tir aléatoires pour attaquer la flotte.   
S
Traque récursive : Dès qu'un navire est touché, un algorithme récursif explore les cases adjacentes (haut, bas, gauche, droite) pour le couler complètement avant de reprendre les tirs aléatoires.   
S
Suivi des tirs : Remplacement des cases vides (.) par des indicateurs d'eau (~) ou de navire touché (X) après chaque tir.   
S
Conditions de victoire : Le jeu compte le nombre total de coups tirés et s'arrête automatiquement en affichant un message de victoire dès que les 17 cases constituant la flotte ont été détruites.   
S
Installation et exécution
Téléchargez un émulateur MIPS compatible avec les appels système (comme MARS, qui supporte le syscall 42 pour la génération de nombres aléatoires utilisé dans ce code).   
S
Ouvrez le fichier start.s dans le logiciel.   
S
Compilez (Assemble) le programme.
Lancez l'exécution (Run). La console affichera le placement initial de la flotte puis détaillera la simulation coup par coup jusqu'au message de fin.   
S
