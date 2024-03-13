#______________________________________________________________
# Add all properties of an user in a domain from a csv file
# Author : me
# Date : 2024
#______________________________________________________________


# Import modules pyad, hashlib, csv, logging
import pyad
import csv
import logging

# Define domain name and OU 
domain = "mondomaine.com"
ou_dn = "ou=Informatique,dc=mondomaine,dc=com"

# Verify domain name is correct
try:
    # Find the name from domain
    domain_name = pyad.adbase.ADObject.from_dn(domain)
except pyad.pyadexceptions.InvalidDomainName:
    # Error control
    print(f"Invalid domain name !")
    exit()

# Verify if DNS name is resolved
try:
    # Find domain controller
    dc = pyad.adbase.ADObject.from_dn(domain.get_domain_controller())
except pyad.pyadexceptions.DCNotFound:
    # Error control
    print(f"Couldn't resolve DNS name for domain: {domain_name}!")
    exit()

# Find the OU in the domain
ou = pyad.adcontainer.ADContainer.from_dn(ou_dn)

# Define Log file
try:
    # Open log file in write mode
    logging.basicConfig(filename="utilisateurs.log", level=logging.INFO, format="%(asctime)s %(message)s")
except IOError as e:
    # Error control
    print(f"Error to open the Log file : {e}")
    exit()

# Function UPDATE_USER
def UPDATE_USER(user, attributes):
    # Read the Attributes and values 
    for attribute, value in attributes.items():
        # Update user
        user.update_attribute(attribute, value)

# Open the CSV file
with open(".\utilisateurs.csv", "r") as csvfile:
    # Object reader 
    lecteur = csv.reader(csvfile)
    # Ignore the header
    next(lecteur)
    # Read all the lines
    for ligne in lecteur:
        try:
            # Retrieve the values of the user properties
            nom = ligne[0]
            prenom = ligne[1]
            mail = ligne[3]
            groupe = ligne[4]
            nomcomplet = ligne[5]
            nomutilisateur = ligne[6]
            telephone = ligne[7]
            titre = ligne[8]
            service = ligne[9]

            # Add user in the OU
            utilisateur = pyad.aduser.ADUser.create(nom, ou, enable=True)

            # Dictionnary of other properties
            attributes = {
                "givenName": prenom,
                "mail": mail,
                "displayName": nomcomplet,
                "sAMAccountName": nomutilisateur,
                "telephoneNumber": telephone,
                "title": titre,
                "department": service
            }

            # Use of the dictionnay
            UPDATE_USER(utilisateur, attributes)

            # Add user in the dedicated group
            groupe = pyad.adgroup.ADGroup.from_cn(groupe)
            groupe.add_members([utilisateur])

            # Change password at first login
            utilisateur.set_user_account_control_setting("PASSWORD_EXPIRED", True)

            # Error control
            print(f"User {nomcomplet} - creation successfull.")

            # Log the result in the log file
            logging.info(f"User {nomcomplet} - creation successfull.")

        except Exception as e:
            # Error control
            print(f"Error during creation process of the user - {nomcomplet} : {e}")

            # Log the result in the log file
            logging.error(f"Error during creation process of the user - {nomcomplet} : {e}")

        finally:
            # Close the CSV file even if an exception occurs
            csvfile.close()

