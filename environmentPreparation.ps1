# Create new RG
$rg = Get-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope" -ErrorAction SilentlyContinue
if(!$rg) {
    $rg = New-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope"
}

## Create new vnet
# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "Subnet1" `
  -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $rg.Location `
  -Name "Gab2019VrDemoVnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

## Create NSG with opened SSH and RDP
# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "SSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 `
  -Access "Allow"

# Create an inbound network security group rule for port 3389
$nsgRuleRdp = New-AzNetworkSecurityRuleConfig `
  -Name "RDP"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389 `
  -Access "Allow"

# Create a network security group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $rg.Location `
  -Name "DemoNsg" `
  -SecurityRules $nsgRuleSSH,$nsgRuleRdp

# Assign NSG to Subnet1
$vnet.Subnets[0].NetworkSecurityGroup = $nsg
$vnet | Set-AzVirtualNetwork