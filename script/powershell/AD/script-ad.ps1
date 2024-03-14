<#
.DESCRIPTION
    Script qui permet de créer des utilisateurs dans un domaien 
.PARAMETER Path
    correspond au chemin qui contient le csv
.PARAMETER Domaine
    correpond au domaine Active Directory où créer les utilisateurs 
.PARAMETER Log 
    correspond au fichier où doit être enregister les logs de ce script
.NOTES
    Author: Erwan Le crom
    Date:   13/03/2024   
#>
[cmdletbinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$Path = '.\ad-list.csv',
    [Parameter(Mandatory = $false)]
    [string]$Domaine = 'mondomaine.com',
    [Parameter(Mandatory = $false)]
    [string]$Log = '.\utilisateur.log'
)

# check if run as administrator
#Requires -RunAsAdministrator
# check if powershell 7 minimum is used
#Requires -Version 7

Import-Module ActiveDirectory
# check if activedirectory module is loaded
#Requires -Modules ActiveDirectory

# Define OU 
$ou_dn = "OU=Informatique,DC=mondomaine,DC=com"

# Verify domain name is correct
try {
    # Find the name from domain
    Get-ADDomain -Identity $Domaine
} catch {
    # Error control
    Write-Host -ForegroundColor Red "Invalid domain name"
    exit 2 
}

# Verify if DNS name is resolved
try {
    # Find domain controller
    Resolve-DnsName -Name $Domaine -Server 127.0.0.1
} catch {
    # Error control
    Write-Host -ForegroundColor Red  "Couldn't resolve DNS name for domain $Domaine"
    exit 3 
}

# Find the OU in the domain
try {
    Get-ADOrganizationalUnit -Identity $ou_dn
} catch {
    Write-Host -ForegroundColor Red "Organization Unit $ou_dc not exist"
    exit 4
}

#check if log file exist
if (-not (Test-Path -Path $Log -PathType Leaf)) {
    New-Item -Path $Log-ItemType File
}
# function that create line to log file 
function create_log_line ([String]$Message) {
    Write-Host -ForegroundColor Red $Message
    Add-Content -Path $Log $Message 
}

#import csv 
$csvData = Import-Csv -Path $Path -Delimiter ','
# read csv data 
foreach ($ligne in $csvData) {
    try {
        $groupe = $ligne.groupe
        $password = -Join((48..57) + (65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
        $attributes = @{
            "Name"=$ligne.nomutilisateur;
            "Surname"=$ligne.nom;
            "givenName"=$ligne.prenom;
            "emailaddress"=$ligne.mail ;
            "displayName"=$ligne.nomcomplet;
            "sAMAccountName"=$ligne.nomutilisateur ;
            "officephone"=$ligne.telephone ;
            "title"=$ligne.titre;
            "department"=$ligne.service;
            "changePasswordAtLogon"=$true;
            "AccountPassword"=ConvertTo-SecureString -String $password -AsPlainText -Force;
            "Enabled"=$true;
            "Path"=$ou_dn
        }
        # add user in the OU 
        $utilisateur = New-ADUser @attributes -PassThru  
        # remove attributes
        # add user to group 
        $ADGroup = Get-ADGroup -Filter "Name -eq `"$groupe`""
        Add-ADGroupMember -Identity $ADGroup -Members $utilisateur
        $messageLog = "User $nomcomplet - creation successfull with password $password"
        create_log_line -Message $messageLog
    } catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
        $alreadyExist = "User $nomcomplet already exist"
        create_log_line -Message $alreadyExist
    } catch {
        $errorMessage = "Error during creation process of the user - $nomcomplet : $_.Exception"
        create_log_line -Message $errorMessage
    } finally {
    }
}
