# Script permettant de modifier la destination des mails envoyes depuis les boites partagees
# et de définir si oui ou non l'adresse de la boite partagée doit être visible 
#dans le carnet d'adresse global 
# il prend en charge toutes les boites partagées du tenant
 

Install-Module -Name ExchangeOnlineManagement -RequiredVersion 2.0.3
Import-Module ExchangeOnlineManagement
$UserCredential = Get-Credential

Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

Get-Mailbox -Filter '(RecipientTypeDetails -eq "SharedMailbox")' | Select Alias,HiddenFromAddressListsEnabled,MessageCopyForSentAsEnabled | Foreach-Object {

Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor Green
Write-Host ETAT DE LA BOITE: $_.Alias  
If ($_.HiddenFromAddressListsEnabled -eq $True)
{write-Host  Visible dans le GAL: OUI}
Else 
{write-Host  Visible dans le GAL: NON}
If ($_.MessageCopyForSentAsEnabled -eq $True)
{write-Host  Copie éléments envoyes dans la boite: OUI}
Else 
{write-Host  Copie éléments envoyes dans la boite: NON}

$modif= Read-Host Voulez-vous apporter des modifications sur la boite $_Alias  "(O/N)" ?
while("o","n","O","N" -notcontains $modif )
{Read-Host Voulez-vous apporter des modifications sur la boite $_Alias  "(O/N)" ?}

If ($modif -eq 'o' -Or $modif -eq 'O')
    {
        $modifGAL= Read-Host Affichage de la BAL $_Alias dans le GAL  "(O/N)" ?
        while("o","n","O","N" -notcontains $modif )
        {Read-Host Présence Affichage de la BAL $_Alias dans le GAL  "(O/N)" ?}
        If ($modifGAL -eq 'o' -Or $modifGAL -eq 'O')
        {Set-Mailbox $_.Alias -HiddenFromAddressListsEnabled $true}
        Else
        {Set-Mailbox $_.Alias -HiddenFromAddressListsEnabled $false}
        
        $modifCOPY= Read-Host Copie des messages envoyés dans la BAL partagée $_Alias "(O/N)" ?
        while("o","n","O","N" -notcontains $modifCOPY )
        {Read-Host Copie des messages envoyés dans la BAL partagée $_Alias "(O/N)" ?}
        If ($modifCOPY -eq 'o' -Or $modifCOPY -eq 'O')
        {Set-Mailbox $_.Alias -MessageCopyForSentAsEnabled $true}
        Else
        {Set-Mailbox $_.Alias -MessageCopyForSentAsEnabled $false}
    }
    Else
    {Write-Host AUCUN CHANGEMENT POUR LA BOITE $_Alias}
}
Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' } | Remove-PSSession
exit