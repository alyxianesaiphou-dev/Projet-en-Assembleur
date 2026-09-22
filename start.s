# ===== Section donnees =====
.data 
grille:     .space 100 #Grille de char de 10x10 soit 100 octet

# Constantes pour les tailles 
.eqv TAILLE_A, 5
.eqv TAILLE_B, 4
.eqv TAILLE_C, 3
.eqv TAILLE_S, 3
.eqv TAILLE_D, 2

.eqv NB_COLONNES, 10
.eqv NB_LIGNES, 10

nb_coups:       .word 0
nb_coups_but:   .word 0
msg_victoire:   .asciiz "\n VICTOIRE ! Vous avez coul� tous les navires ! BRAVO !\n"
msg_coup:       .asciiz "\n Coup n� "


.text
.globl __start
__start:
# ----- Main -----
main:
    # Initialisation de la grille (remplie avec des '.')
    jal initGrille

    # Placement des navires (A, B, C, S, D)
    # On met la taille dans $a0 et la lettre dans $a1
    
    jal initPartie

    # Affichage initial avec les navires
    jal displayGrille

    # Lancement de la simulation de jeu
    jal simulationJeu

    # Fin du programme
    la $a0, msg_victoire
    li $v0, 4
    syscall
    
    j exit

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1
initPartie:
    add     $sp, $sp, -4        # On reserve de la place en mémoire
    sw      $ra, 0($sp)         # Sauvegarde de l'adresse de retour 

    jal initGrille
    
    li  $a0, TAILLE_A
    li  $a1, 65 # code ASCII 'A' 
    jal setShip
    li  $a0, TAILLE_B  
    li  $a1, 66 # code ASCII 'B' 
    jal setShip
    li  $a0, TAILLE_C
    li  $a1, 67 # code ASCII 'C'
    jal setShip
    li  $a0, TAILLE_S
    li  $a1, 83 # code ASCII 'S'
    jal setShip
    li  $a0, TAILLE_D
    li  $a1, 68 # code ASCII 'D'
    jal setShip

    lw      $ra, 0($sp)                 # On recupere l'adresse de retour 
    add     $sp, $sp, 4                 # On libere l'espace memoire reserve
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]-
initGrille:
    la $t0, grille
    li $t1, 0   # on initialise l'index a 0
    li $t3, 46  # code ASCII '.'
boucle_initGrille:
    bge $t1, 100, end_initGrille  #si i(t1) >= 100, on sort de la boucle
    add $t2, $t0, $t1		  #calcul de l'adresse actuel
    sb $t3, 0($t2)
    addi $t1, $t1, 1		  #i++
    j boucle_initGrille
end_initGrille:
    jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]
displayGrille:
    add $sp, $sp, -4   # On reserve de la place en memoire
    sw $ra, 0($sp)
    jal displayLettres # Affiche A B C...

    la $t0, grille
    li $t1, 0
boucle_displayGrille:
    bge $t1, 100, end_displayGrille

    move $a0, $t1
    li $a1, 10
    jal getModulo
    bne $v0, $zero, afficher_case  #si reste != 0, ce n'est pas un debut de ligne

    # Début de ligne : afficher numéro ligne
    div $t1, $a1
    mflo $t2
    addi $a1, $t2, 1 # Numéro de ligne (1-10)
    
    # Petite astuce : si ligne < 10, afficher un espace avant
    bge $a1, 10, no_pad
    li $v0, 11
    li $a0, 32 # Espace
    syscall
no_pad:
    jal addLineCount

afficher_case:
    add $t2, $t0, $t1 #adresse de la case 
    lb $a0, ($t2)
    li $v0, 11
    syscall

    li $a0, ' ' # Espace entre les cases
    li $v0, 11
    syscall

    li $a1, 10
    move $a0, $t1
    jal getModulo  #i%10
    li $t3, 9
    bne $v0, $t3, pas_fin_ligne
    jal addNewLine # Fin de ligne -> retour \n

pas_fin_ligne:
    addi $t1, $t1, 1 # i++
    j boucle_displayGrille

end_displayGrille:
    jal addNewLine
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, $v0, $a0
displayLettres:
    add $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Espace initial pour alignement
    li $a0, 32
    li $v0, 11
    syscall
    syscall
    syscall 

    li $t0, 0 #compteur j = 0
boucle_displayLettres:
    bge $t0, NB_COLONNES, end_displayLettres #si j>=10, fin
    li $a0, 65       # code ASCII'A'
    add $a0, $a0, $t0  # 65 + j 
    li $v0, 11
    syscall
    li $a0, 32       # Espace
    li $v0, 11
    syscall
    addi $t0, $t0, 1 #j++
    j boucle_displayLettres

end_displayLettres:
    jal addNewLine
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : quotient du modulo + 1)
addLineCount:
    li $v0, 1
    move $a0, $a1
    syscall
    li $a0, ' '
    li $v0, 11
    syscall
    jr $ra

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $
getModulo:
    div $a0, $a1
    mfhi $v0        # MARS a une instruction pour le reste
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0
getAleatoire:
    li $a0, 0    
    li $v0, 42   #syscall 42 permet la g�n�ration d'un nombre al�atoire
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caraètre pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]
setShip:
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    move $s0, $a0    # Taille
    move $s4, $a1    # Lettre

    # Choisir direction (0 ou 1)
    li $a1, 2
    jal getAleatoire
    move $s1, $a0
    beq $s1, 1, placeVerticale
    j placeHorizontale

end_setShip:
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]
placeHorizontale:
boucle_placeH:
    # Ligne aléatoire (0-9)
    li $a1, 10
    jal getAleatoire
    move $s2, $a0   # Ligne

    # Colonne aléatoire (0 à 10-Taille)
    li $t0, 10
    sub $t0, $t0, $s0  #10 - Taille du bateau
    addi $t0, $t0, 1   # Borne sup est exclusive, donc +1
    move $a1, $t0
    jal getAleatoire
    move $s3, $a0   # Colonne

    # Vérification
    jal verifPlaceHorizontale
    beq $v0, $zero, placeH  # Si v0=0, on place
    j boucle_placeH         # Sinon on recommence

placeH:
    # Calcul adresse de départ
    la $t0, grille
    mul $t1, $s2, 10    #ligne * 10(ex: 5*10)
    add $t1, $t1, $s3   #+colonne  (ex: + 4)
    add $t0, $t0, $t1   #adresse   (ex: 54)

    li $t3, 0		#compteur k = 0
placementH_boucle:
    beq $t3, $s0, placeH_fin   #si k==tailleBateau, fini
    sb $s4, 0($t0)	       #ecrit la lettre
    addi $t0, $t0, 1	       #case suivante +1
    addi $t3, $t3, 1	       # k++
    j placementH_boucle
placeH_fin:
    j end_setShip

# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, 
verifPlaceHorizontale:
    la   $t0, grille
    mul  $t1, $s2, 10
    add  $t1, $t1, $s3
    add  $t0, $t0, $t1

    li   $t1, 0		#k = 0
    li   $t4, 46        # '.'
check_h_loop:
    beq  $t1, $s0, check_ok   # Fin de boucle, OK
    lb   $t5, 0($t0)	      #lit la case
    bne  $t5, $t4, check_fail # Si != '.', Echec
    addi $t0, $t0, 1	      # case suivante
    addi $t1, $t1, 1	      # k++
    j    check_h_loop

# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]
placeVerticale:
boucle_placeV:
    # Colonne aléatoire (0-9)
    li $a1, 10
    jal getAleatoire
    move $s3, $a0   # Colonne

    # Ligne aléatoire (0 à 10-Taille)
    li $t0, 10
    sub $t0, $t0, $s0
    addi $t0, $t0, 1
    move $a1, $t0
    jal getAleatoire
    move $s2, $a0   # Ligne

    # Vérification
    jal verifPlaceVerticale
    beq $v0, $zero, placeV
    j boucle_placeV

placeV:
    # Placement effectif
    la $t0, grille
    mul $t1, $s2, 10
    add $t1, $t1, $s3
    add $t0, $t0, $t1

    li $t3, 0
placementV_boucle:
    beq $t3, $s0, placeV_fin
    sb $s4, 0($t0)
    addi $t0, $t0, 10
    addi $t3, $t3, 1
    j placementV_boucle
placeV_fin:
    j end_setShip

# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3
verifPlaceVerticale:
    la   $t0, grille
    mul  $t1, $s2, 10
    add  $t1, $t1, $s3
    add  $t0, $t0, $t1

    li   $t1, 0
    li   $t4, 46        # '.'
check_v_loop:
    beq  $t1, $s0, check_ok
    lb   $t5, 0($t0)
    bne  $t5, $t4, check_fail
    addi $t0, $t0, 10   # +10 pour descendre
    addi $t1, $t1, 1
    j    check_v_loop

# Retours Communs Vérifications 
check_ok:
    li $v0, 0   # 0 = Succès
    jr $ra
check_fail:
    li $v0, 1   # 1 = Échec (Occupé)
    jr $ra
    
# simulationJeu 
simulationJeu:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    sw   $zero, nb_coups
    sw   $zero, nb_coups_but

boucle_simulation:
    # Vérifier victoire (17 touches totales)
    lw   $t0, nb_coups_but
    li   $t1, 17
    bge  $t0, $t1, fin_simulation 

    # Tirer coordonnées aléatoires 
    li   $a1, 10
    jal  getAleatoire
    move $s2, $a0       # Ligne

    li   $a1, 10
    jal  getAleatoire
    move $s3, $a0       # Colonne

    # Appel Traque 
    move $a0, $s2
    move $a1, $s3
    jal  traque

    # Affichage du coup 
    # Saut de ligne
    li $v0, 11
    li $a0, 10
    syscall

    # "Coup num X"
    la $a0, msg_coup
    li $v0, 4
    syscall
    
    lw $a0, nb_coups
    li $v0, 1
    syscall
    
    # Saut de ligne
    li $v0, 11
    li $a0, 10
    syscall

    # Afficher la grille
    jal displayGrille

    # Recommencer
    j boucle_simulation

fin_simulation:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# traque (Recursive) 
traque:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)    # Ligne
    sw   $a1, 8($sp)    # Colonne

    # Adresse Mémoire = grille + (ligne*10) + col
    la   $t0, grille
    mul  $t1, $a0, 10
    add  $t1, $t1, $a1
    add  $t2, $t0, $t1  
    lb   $t3, 0($t2)    # Contenu de la case

    # Cas arrêt : Déjà visité ('~' ou 'X')
    li   $t4, 126       # '~'
    beq  $t3, $t4, retour_traque
    li   $t4, 88        # 'X'
    beq  $t3, $t4, retour_traque

    # Compter coup
    lw   $t5, nb_coups
    addi $t5, $t5, 1
    sw   $t5, nb_coups

    # Test Eau vs Navire
    li   $t4, 46        # '.'
    bne  $t3, $t4, cas_navire_trouve

    # C'est de l'eau -> Plouf '~'
    li   $t4, 126
    sb   $t4, 0($t2)
    j    retour_traque

cas_navire_trouve:
    # C'est un navire -> Touché 'X'
    lw   $t5, nb_coups_but
    addi $t5, $t5, 1
    sw   $t5, nb_coups_but
    
    li   $t4, 88        # 'X'
    sb   $t4, 0($t2)

    # Récursivité (4 directions)
    # HAUT
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    addi $a0, $a0, -1
    blt  $a0, 0, test_bas
    jal  traque

test_bas:
    # BAS
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    addi $a0, $a0, 1
    li   $t9, 10
    bge  $a0, $t9, test_gauche
    jal  traque

test_gauche:
    # GAUCHE
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    addi $a1, $a1, -1
    blt  $a1, 0, test_droite
    jal  traque

test_droite:
    # DROITE
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    addi $a1, $a1, 1
    li   $t9, 10
    bge  $a1, $t9, retour_traque
    jal  traque

retour_traque:
    lw   $ra, 0($sp)
    addi $sp, $sp, 12
    jr   $ra

# EXIT 
exit:
    li $v0, 10
    syscall
