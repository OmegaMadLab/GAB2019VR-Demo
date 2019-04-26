## Customize following parameters if running demos at home :)
$vmName = "gab2019vr-demo-linux"

##

# Create new RG
$rg = Get-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope" -ErrorAction SilentlyContinue
if(!$rg) {
    $rg = New-AzResourceGroup -Name "GAB2019VR-Demo-RG" -Location "WestEurope"
}

$vm = Get-AzVm -ResourceGroupName $rg.ResourceGroupName -Name $vmName -ErrorAction SilentlyContinue
if(!$vm) {
    Write-host "Preparing configuration for $VmName..."

    # Create a public IP address and specify a DNS name
    $pip = New-AzPublicIpAddress `
      -ResourceGroupName $rg.ResourceGroupName `
      -Location $rg.Location `
      -AllocationMethod Dynamic `
      -IdleTimeoutInMinutes 4 `
      -Name $vmName `
      -DomainNameLabel $vmName

    # Create a virtual network card and associate with public IP address
    $nic = New-AzNetworkInterface `
      -Name "$vmName-Nic" `
      -ResourceGroupName $rg.ResourceGroupName `
      -Location $rg.Location `
      -SubnetId (Get-AzVirtualNetwork -ResourceGroupName $rg.ResourceGroupName).Subnets[0].Id `
      -PublicIpAddressId $pip.Id

    # Define a credential object
    $securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

    # Create a virtual machine configuration
    $vmConfig = New-AzVMConfig `
      -VMName $vmName `
      -VMSize "Standard_B1s" | `
    Set-AzVMOperatingSystem `
      -Linux `
      -ComputerName $vmName `
      -Credential $cred `
      -DisablePasswordAuthentication | `
    Set-AzVMSourceImage `
      -PublisherName "Canonical" `
      -Offer "UbuntuServer" `
      -Skus "19.04" `
      -Version "latest" | `
    Add-AzVMNetworkInterface `
      -Id $nic.Id

    Write-Host "Creating SSH key pairs..."

    # Generate SSH keys in Cloud Shell
    ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa 

    # Ensure VM config is updated with SSH keys
    $sshPublicKey = Get-Content "$HOME\.ssh\id_rsa.pub"
    Write-Host "Public key: $sshPublicKey"
    Write-Host "Adding it to VM configuration..."
    Add-AzVMSshPublicKey -VM $vmConfig -KeyData $sshPublicKey -Path "/home/azureuser/.ssh/authorized_keys"

    Write-Host "Configuration prepared for $vmName. Creating VM..."
    # Create a virtual machine
    New-AzVM -ResourceGroupName $rg.ResourceGroupName `
        -Location $rg.Location `
		-VM $vmConfig
		
	Write-Host "VM created. Connect with: ssh azureuser@$($pip.DnsSettings.Fqdn)"
}
else {
	$pip = Get-AzPublicIpAddress | ? Name -like "$vmName*"
	Write-Host "VM already exists. Connect with: ssh azureuser@$($pip.DnsSettings.Fqdn)"
}



