$tssr = "$env:USERPROFILE\TSSR"
$currentDirectory = Get-Location

# Je test l'existence du répertoire TSSR
if (!(Test-Path -Path $tssr)) {
    New-Item -Path $tssr -ItemType Directory 
}
# Je test l'existence du fichier de log 
if (!(Test-Path -Path $tssr\RESULTAT.log -PathType Leaf)) {
    New-Item -Path $tssr\RESULTAT.log -ItemType file
} 

$tracefile = "$tssr\RESULTAT.log"
$Softwares = @(
    @{
        Name = "Putty";
        Id = "Putty.Putty"
    },
    @{
        Name = "Mobaxterm";
        Id = "Mobatek.MobaXterm"
    },
    @{
        Name = "SYSINTERNALS SUITE";
        Id = "9P7KNL5RWT25"
    },
    @{
        Name = "DOCKER CLI";
        Id = "Docker.DockerCLI"
    }
)

Add-Content $tracefile " ----------------- Installation des Applications"

<#
    Fonction qui permet d'installer un logiciel via winget 
    
    --Name contient le nom du logiciel
    --Id contient l'Identifiant du logiciel sur winget 
#>
function Install-Softwares{
    param (
        [hashtable[]]$Softwares
    )
    foreach ($Software in $Softwares) {
        Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Installation $Software.Name"
        Add-Content $tracefile "                    .... WINGET install -l $currentDirectory --Id $Id --silent --force --skip-dependencies --log $tssr\$($Software.Name).log"
        winget install --Id $Software.Id --accept-package-agreements --silent --force --skip-dependencies --log $tssr\$Name.log 
        if (-not $?) {
            Add-Content $tracefile "$LASTEXITCODE $error[0]"
            exit $LASTEXITCODE
        } else {
            Add-Content $tracefile "$(Get-date -Format "yyyy/mm/dd HH:mm")      ----------------- Fin $Software.Name"
        } 
    }
}

Install-Softwares -Softwares $Softwares

# sortie normale du script 
exit 0