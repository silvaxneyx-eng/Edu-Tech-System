#Requires -RunAsAdministrator
param(
    [Parameter(Mandatory = $true)]
    [string]$Usuario,

    [Parameter(Mandatory = $true)]
    [string]$Senha
)

$senhaSegura = ConvertTo-SecureString $Senha -AsPlainText -Force
New-LocalUser -Name $Usuario -Password $senhaSegura -FullName $Usuario -ErrorAction Stop | Out-Null
$adminGroup = (Get-LocalGroup -SID 'S-1-5-32-544').Name
Add-LocalGroupMember -Group $adminGroup -Member $Usuario -ErrorAction Stop
Write-Host "Usuario '$Usuario' criado e adicionado ao grupo '$adminGroup'." -ForegroundColor Green
