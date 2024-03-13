#!/bin/bash
# Author : PFo
# Date : 2023

# je vérifie si le script est execute avec des droits admin
if [[ $EUID -ne 0 ]]; then
        echo "ce script doit être executé avec des droit root"
        exit 2
fi 

# _____________________ FUNCTIONS _______________________________
F_Aide() {
        echo "  ----- Aide ----- "
        echo "  ${1##*/} Param"
        echo "          ou Param = le chemin du dossier courant !"
}
# _____________________ FUNCTIONS _______________________________

# Debut du script ###############################################

# Point A _______________________________________________________
# Parametres en entree
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        F_Aide "$0"
        exit 0
elif [ -z "$1" ]; then
        echo "Merci d'ajouter 1 parametre a la ligne de ce programme"
        exit 8
else
        echo "Utilisation du repertoire  $1"
        F_Aide "$1"
fi

# Recuperation du point de depart
ICI=$(pwd)

# Deplacement dans le repertoire s'il existe
if [ -d $1 ]; then 
        cd $1
else 
        echo "$1 n'est pas un bon repertoire"
        exit 1
fi

# Liste des fichiers dans le dossier courant
ls -f

# Affichage de l'utilisateur qui s'est logue 
echo "Utilisateur logue :" ; whoami
currentUser=$(whoami)
# Positionnenment dans le repertoire Documents utilisateur courant
cd $HOME/Documents

# Creation du dossier TSSR
mkdir TSSR
cd TSSR
TSSRdir=$(pwd)

# Creation du dossier Log dans le dossier TSSR
mkdir Log
cd Log

# Copy de l'avant-dernier fichier Syslog
cp /var/log/syslog.1 ./
if [ $? -ne 0 ]; then
        "Erreur de copie du fichier Syslog"
        exit 3
    else
        echo "Copie realisee par cp"
fi

# Point B _______________________________________________________
# Recherche dans le fichier des dates et heures de demarrage du systeme
awk '/Starting/ && /boot process/' ./syslog.1 
# !!! Merci d'afficher le nombre de lignes obtenu par la precedente commande
awk '/Starting/ && /boot process/' ./syslog.1 | wc -l 
# !!! Merci de realiser la meme commande avec un autre outil disponible sous Linux nativement
cat ./syslog.1 | grep 'Starting' | grep 'boot process' 

# Demande des initiales de l'utilisateur qui a lance le script
PN_init=""
while [ "$PN_init" = "" ]; do
    read -p "Saisir Vos initiales en majuscule :" PN_init
done

# Creation du fichier vide avec les initiales fournies
fileboot=$PN_init-Boot_Init.$(date +'%d-%m-%y').txt
touch $fileboot

# !!! Merci d'envoyer dans le fichier qui vient d'etre cree les lignes de la commandes AWK ci-dessus. 
awk '/Starting/ && /boot process/' ./syslog.1 >> $fileboot
# Point C _______________________________________________________
# !!! Merci d'affecter l'heure a la variable $TPS
TPS =$(date +%H)
# !!! Merci de creer la fonction PointC qui affiche a l'ecran la valeur des parametres passes a la fonction
F_PointC() {
       for i in $*; do 
                echo $i;
                echo $i>>$fileboot
        done 
}
#       et les envoies dans le fichier $PN_init-PointC.$(date +'%d-%m-%y').txt
F_PointC $PN_init $TPS

# Point D _______________________________________________________
# !!! Merci de commenter les 3 lignes suivantes 

# recupere la liste des utilisateurs, leur uid, leur group principal,leur repertoire par defaut ainsi que leur shell 
#awk -F ':' '{print $1,$3,$5,$6,$7}' /etc/passwd

# recupere la liste des groupes ainsi que leur gid 
#awk -F ':' '{print $1,$3,$4}' /etc/group

# recupere les infos sur l'utilisateur courant (uid, gid ainsi que les groupes)
#id  

# !!! Merci de creer et d'ajouter l'utilistateur TSSR au groupe SUDO avec le shell KSH (!/etc/shells)
useradd TSSR -G sudo -s /usr/bin/ksh 

# Point E _______________________________________________________
# Affichage de diverses informations sur le systeme
uname -a
# Lister les 5 derniers utilisateurs connectes
last -n 5
# Espace libre sur les partitions
df -h
# Espace utilise dans le repertoire TSSR avec affichage des valeurs en Mb/Gb
du $TSSRdir -h 
# !!! Merci d'afficher les process actifs de l'utilisateur logue
ps -aux | grep $currentUser
# Trouver dans le fichier log du repertoire /var/log l'information indiquant le dernier shutdown lance
cat /var/log/syslog | grep shutdown | tail -n 1

# Affichage des daemon actifs
systemctl list-units --type service
# !!! Merci de trouver une autre commande pour afficher les daemon actifs
find /etc/systemd/system/ -name *.service

# Point F _______________________________________________________
# !!! Merci de recuperer a l'aide de la commande -curl- l'information a l'adresse suivante : 
#           https://assets.digitalocean.cnanoom/articles/command-line-intro/verne_twenty-thousand-leagues.txt
curl https://assets.digitalocean.cnanoom/articles/command-line-intro/verne_twenty-thousand-leagues.txt -o verne_twenty-thousand-leagues.txt

# Point G _______________________________________________________
# !!! Transferer l'ensemble des commandes que vous avez saisi dans votre terminal dans le fichier MesCmd_Linux.txt afin d'en avoir un historique
# je recupere la sortie 10 du script et renvoie le resultat dans le fichier MesCmd_Linux.txt
history > MesCmd_Linux.txt
# !!! Merci d'ecrire un bloc de script qui affichera toutes les lettres de l'alphabet avec le numero d'ordre devant chaque lettre
for i in {a..z}; do 
        echo "$(printf '%d' "'$i") : $i"
done 

# Retour point de depart
cd $ICI



# Fin du script ###############################################
# Felicitations si vous etes arrives ici et que votre script fonctionne !

# PS : don't forget to run this script you need to change the mode of this file with : chmod +x filename.sh