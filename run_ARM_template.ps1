
Connect-AzAccount
$SubscriptionId = "YourSubId"
Select-AzSubscription -Subscription (Get-AzSubscription -SubscriptionId $SubscriptionId)

$VMsize = "Standard_D2ds_v4"
$vmNumber = "4"
$Dedicated = $true
$vNetName = ""
$vNetSubnet = ""
$vNetRSG = ""
$Publisher = "MicrosoftWindowsDesktop"
$Offer = "windows-11"
$Sku = "win11-21h2-avd"
#$Offer = "office-365"
#$Sku = "win11-21h2-avd-m365"
$vmAdminPassword = "LocalAdminPC"
$vmAdminID = "LocalAdmin"
$HostpoolName = ""
$AvailSetExists = $false
$ResourceGroupName = ""
$rdshNamePrefix = "VM-"
$NumberOfInstances = 1
$aadJoin = $true
$regInfo = New-AzWvdRegistrationInfo -ResourceGroupName $ResourceGroupName -hostPoolName $hostPoolName -ExpirationTime ([datetime]::UtcNow.AddDays(1).AddHours(1))
$hostPoolToken = $regInfo.Token

$params = @{
rdshVmSize = $VMsize
vmNumber = $vmNumber
rdshVMDiskType = 'StandardSSD_LRS'
DedicatedDesktop = $Dedicated
existingVnetName = $vNetName
existingSubnetName = $vNetSubnet
virtualNetworkResourceGroupName = $vNetRSG
imagePublisher = $Publisher
imageOffer = $Offer
imageSKU = $Sku
vmAdminPassword = $vmAdminPassword
vmAdminID = $vmAdminID
HostPoolName = $HostpoolName
AvailSetExists = $AvailSetExists
rdshNamePrefix = $rdshNamePrefix
NumberOfInstances = $NumberOfInstances
aadJoin = $aadJoin
hostPoolToken = $hostPoolToken
}

New-AZResourceGroupDeployment `
-ResourceGroupName "$ResourceGroupName" `
-Mode Incremental `
-Name "Provisioning-Sessionhost-$vmNumber" `
-TemplateFile ".\AVD-NewSessionHost.json" `
-TemplateParameterObject $params