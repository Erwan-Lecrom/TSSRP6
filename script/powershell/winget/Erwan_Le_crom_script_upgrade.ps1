<#
.DESCRIPTION
    Script permettant d'installer, mettre à jour ou desinstaller un logiciel via winget
.PARAMETER Choice
    install/update/uninstall
    install pour installer
    update pour mettre à jour 
    uninstall pour desinstaller 
.PARAMETER Software
    correspond au logiciel à utiliser
.PARAMETER Path
    correspond au chemin ou installer le logiciel
    par défaut il est définis sur le chemin courant
.PARAMETER Source
    correspond à la source utilise par winget 
    par défault il est définis sur winget

.NOTES
    Author: Erwan Le crom
    Date:   11/03/2024   
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("install", "update", "uninstall")]
    [string]$Choice,
    [Parameter(Mandatory = $true)]
    [string]$Software,
    [Parameter(Mandatory = $false)]
    [string]$Path,
    [Parameter(Mandatory = $false)]
    [string]$Source
)
#Requires -RunAsAdministrator

$tssr = "$env:USERPROFILE\TSSR"

# test l'existence du répertoire TSSR
if (!(Test-Path -Path $tssr)) {
    New-Item -Path $tssr -ItemType Directory 
}
# test l'existence du fichier de log 
if (!(Test-Path -Path $tssr\RESULTAT.log -PathType Leaf)) {
    New-Item -Path $tssr\RESULTAT.log -ItemType file
} 
$tracefile = "$tssr\RESULTAT.log"

# si le chemin n'est pas précise il prend par défaut le chemin courant
if ($null -eq $PATH) {
    $PATH = Get-Location
}
# si la source n'est pas précise elle est définis par défaut sur winget
if ($null -eq $SOURCE) {
    $SOURCE = "winget"
}

switch ($CHOICE){
    "install" {
        # si le choix est l'installation 
        Write-Output $tracefile
        Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Installation $SOFTWARE"
        Add-Content $tracefile "                    .... winget install -l $PATH --Name $Id -e --silent --force --skip-dependencies --accept-package-agreements --log $tssr\$SOFTWARE.log"
        winget install -l $PATH --Name $SOFTWARE -s winget --force --silent --skip-dependencies --accept-package-agreements --log $tssr\$SOFTWARE.log
         # si la commande précédente échoue 
        if (-not $?) {
            $exitcode = $LASTEXITCODE
            Add-Content $tracefile "$exitcode $error[0]"
            exit $exitcode
        } else {
            Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Fin $SOFTWARE"
        } 
    }
    "update" {
        # si le choix est la mise à jour 
        Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Mise à jour $SOFTWARE"
        Add-Content $tracefile "                    .... winget upgrade --Name $SOFTWARE -e --force --silent --skip-dependencies"
        winget upgrade --Name $SOFTWARE -s winget --force --silent --skip-dependencies
         # si la commande précédente échoue 
        if (-not $?) {
            $exitcode = $LASTEXITCODE
            Add-Content $tracefile "$exitcode $error[0]"
            exit $exitcode
        } else {
            Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Fin $SOFTWARE"
        } 
    }
    "uninstall" {
        # si le choix est la suppression
        Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Desinstallation $SOFTWARE"
        Add-Content $tracefile "                    .... winget uninstall --Name $SOFTWARE --force --purge"
        winget uninstall --Name $SOFTWARE -s winget --force --purge
        # si la commande précédente échoue 
        if (-not $?) {
            $exitcode = $LASTEXITCODE
            Add-Content $tracefile "$exitcode $error[0]"
            exit $exitcode
        } else {
            Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Fin $SOFTWARE"
        } 
    }
}