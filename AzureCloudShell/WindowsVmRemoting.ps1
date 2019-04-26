# Activate prereq for remote management - VM must have a public IP assigned
Enable-AzVMPSRemoting -Name "GAB2019VR-SqlVm" -ResourceGroupName "GAB2019VR-Demo-RG" -Protocol https -OsType Windows

# Execute commands on a remote machine
Invoke-AzVMCommand -Name "GAB2019VR-SqlVm" -ResourceGroupName "GAB2019VR-Demo-RG" -Scriptblock {Get-ComputerInfo} -credential (Get-Credential)

# Open an interactive session
Enter-AzVM -Name "GAB2019VR-SqlVm" -ResourceGroupName "GAB2019VR-Demo-RG" -credential (Get-Credential)