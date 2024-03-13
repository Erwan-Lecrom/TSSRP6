#Requires -RunAsAdministrator

Import-Module ActiveDirectory
# store system variables 
$existingVariables = Get-Variable
# Define domain name and OU 
$domain = "mondomaine.com"
$ou_dn = "ou=Informatique,dc=mondomaine,dc=com"

# Verify domain name is correct
try {
    # Find the name from domain
    $domain_name = Get-ADDomain -Identity $domain
} catch {
    # Error control
    Write-Output "Invalid domain name"
    exit 2 
}

# Verify if DNS name is resolved
try {
    # Find domain controller
    $dc = Resolve-DnsName -Name $domain -Server 127.0.0.1
} catch {
    # Error control
    Write-Output "Couldn't resolve DNS name for domain $domain_name"
    exit 3 
}

# Find the OU in the domain
$ou = Get-ADOrganizationalUnit -Identity $ou_dn
# define log file path 
$logFilePath = ".\utilisateur.log"
#check if log file exist
if (-not (Test-Path -Path $logFilePath -PathType Leaf)) {
    New-Item -Path $logFilePath -ItemType File
}
# function that create line to log file 
function create_log_line ([String]$Message) {
    Add-Content -Path $logFilePath $Message 
}

#import csv 
$csvPath = ".\ad-list.csv"
$csvData = Import-Csv -Path $csvPath -Delimiter ','
# read csv data 
foreach ($ligne in $csvData) {
    try {
        $nom = $ligne.nom
        $prenom = $ligne.prenom
        $mail = $ligne.mail 
        $groupe = $ligne.groupe
        $nomcomplet = $ligne.nomcomplet
        $nomutilisateur = $ligne.nomutilisateur 
        $telephone = $ligne.telephone 
        $titre = $ligne.titre 
        $service = $ligne.service
        $secpasswd = ConvertTo-SecureString -String "Azerty123*" -AsPlainText -Force
        # add user in the OU 
        New-ADUser -Name $nom -Path $ou -Enabled $true -AccountPassword $secpasswd
        # attribute that countains other properties
        $attributes = @{
            "givenName"=$prenom;
            "emailaddress"=$mail;
            "displayName"=$nomcomplet;
            "sAMAccountName"=$nomutilisateur;
            "officephone"=$telephone;
            "title"=$titre;
            "department"=$service
        }
        $utilisateur = Get-ADUser -Filter "Name -eq `"$nom`""
        # update the user with attributes
        Write-Output $utilisateur | Set-ADUser @attributes
        # add user to group 
        $ADGroup = Get-ADGroup -Filter "Name -eq `"$groupe`""
        Add-ADGroupMember -Identity $ADGroup -Members $utilisateur
        # change password at first login
        Write-Output $utilisateur | Set-ADUser -ChangePasswordAtLogon $true
        $messageLog = "User $nomcomplet - creation successfull"
        Write-Output $messageLog
        Add-Content -Path $logFilePath -Value $messageLog
    } catch {
        $errorMessage = "Error during creation process of the user - $nomcomplet : $_.Exception"
        Write-Output $errorMessage
        Add-Content -Path $logFilePath -Value $errorMessage
    } finally {
        # remove variable excluding system variable
        Get-Variable | Where-Object Name -notin $existingVariables.Name | Remove-Variable
    }
}
