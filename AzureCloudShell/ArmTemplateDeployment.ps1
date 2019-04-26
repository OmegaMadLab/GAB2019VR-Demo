New-AzResourceGroupDeployment -Name "SqlDB" `
    -ResourceGroupName "GAB2019VR-Demo-RG" `
    -TemplateFile $HOME/gab2019vr-demo/AzureCloudShell/simpleSQL.json `
    -TemplateParameterFile $HOME/gab2019vr-demo/AzureCloudShell/simpleSQL.parameters.json `
    -AsJob