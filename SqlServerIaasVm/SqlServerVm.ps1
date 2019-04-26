## Customize following parameters if running demos at home :)
$vmName = "GAB2019VR-SqlVm"

##

# Create new RG
$rg = Get-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope" -ErrorAction SilentlyContinue
if(!$rg) {
    $rg = New-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope"
}

## Deploy a SQL Server optimized VM starting from template available at https://github.com/OmegaMadLab/OptimizedSqlVm
$paramFile = Get-Content ".\SqlServerVm.parameters.json" | ConvertFrom-Json
$paramFile.parameters.vmName.value = $vmName
$paramFile.parameters.dnsLabelPrefix.value = $vmName.ToLower()
$paramFile | ConvertTo-Json | Set-Content ".\SqlServerVm.parameters.json"

New-AzResourceGroupDeployment `
    -Name "SQLVM" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateUri "https://raw.githubusercontent.com/OmegaMadLab/OptimizedSqlVm/master/azuredeploy.json" `
    -TemplateParameterFile ".\SqlServerVm.parameters.json" `
    -AsJob
