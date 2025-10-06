#Requires -Modules "Az.Accounts", "Az.Resources", "Microsoft.Entra"
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$LogicAppName,
    [Parameter(Mandatory=$true)]
    [string]$Tenant,
    [Parameter(Mandatory=$true)]
    [string]$Subscription
)

$GRAPH_APP_ID = "00000003-0000-0000-c000-000000000000"

Connect-AzAccount -TenantId $Tenant -Subscription $Subscription  | Out-Null
Connect-MgGraph -TenantId $Tenant -Scopes "AppRoleAssignment.ReadWrite.All", "Application.Read.All" -NoWelcome

Write-Host "AZ context"
Get-AzContext | Format-List
Write-Host "MG context"
Get-MgContext | Format-List

$GraphPermissions = @()
$GraphPermissions = @("User.Read.All")

$LogicAppMSI = Get-EntraServicePrincipal -Filter "displayName eq '$LogicAppName'"
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$GRAPH_APP_ID'"

foreach ($GraphPermission in $GraphPermissions) {

    $GraphAppRole = $GraphServicePrincipal.AppRoles | 
        Where-Object Value -eq $GraphPermission |
        Where-Object AllowedMemberTypes -contains "Application"

    $bodyParam = @{
        PrincipalId = $LogicAppMSI.Id
        ResourceId  = $GraphServicePrincipal.Id
        AppRoleId   = $GraphAppRole.Id
    }

    Write-Host "Assigning $GraphPermission to $($LogicAppMSI.DisplayName)"
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $LogicAppMSI.Id -BodyParameter $bodyParam
}
