## $clientName is passed in from the monitor. It pulls this value from the ClientName
## EDF located at the Client level.
$vpnName = "$clientName VPN"
## See if the VPN connection already exists
$vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName -EA 0
If (!$vpnPresent) {
    Try {
        ## Create the VPN connection
        Write-Warning "$vpnName does not exist, creating connection..."
        ## the variablse being used here that were never defined in this script are passed in from Automate. It's
        ## taking values from EDFs and setting them as powershell variables before it calls this script. Because of
        ## this the script will fail if called standalone w/o the monitor.
        Add-VpnConnection -Name $vpnName -ServerAddress $serverAddress -TunnelType $tunnelType -AllUserConnection -L2tpPsk $presharedKey -AuthenticationMethod $authenticationMethod -Force
        ## Check for the VPN connection again to see if it exists now
        $vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName -EA 0
        If ($vpnPresent) {
            Write-Output "!SUCCESS: Created $vpnName successfully"
            Break
        } Else {
            Write-Warning "!ERROR: Failed to created $vpnName"
            Break
        }
    } Catch {
        ## If there was an error thrown during VPN connection creation it will come here and put out this error
        Write-Warning "!ERROR: There was a problem when attempting to create $vpnName. Error output: $error"
        Break
    }
} Else {
    Try {
        Write-Output "!SUCCESS: Verified $vpnName exists"
        ## Check the VPN connection properties. If the settings are different than the ones we are sending,
        ## delete the VPN connection, then recreate it with the accurate settings.
        If (($vpnPresent).ServerAddress -ne $serverAddress -or ($vpnPresent).AuthenticationMethod -ne $authenticationMethod -or ($vpnPresent).TunnelType -ne $tunnelType) {
            Write-Warning "$vpnName has settings that do not match the configuration sent from Automate, recreating VPN connection..."
            Remove-VpnConnection -AllUserConnection -Name $vpnName -Force
            Add-VpnConnection -Name $vpnName -ServerAddress $serverAddress -TunnelType $tunnelType -AllUserConnection -L2tpPsk $presharedKey -AuthenticationMethod $authenticationMethod -Force
            Write-Output "!SUCCESS: Created $vpnName successfully"
        }
    } Catch {
        ## If we're here then this means something went wrong when removing/creating the VPN connection above
        Write-Warning "!ERROR: Failed to created $vpnName. Error ourput: $error"
    }
}