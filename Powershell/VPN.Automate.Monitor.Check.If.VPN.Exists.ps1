## $clientName is passed in from the monitor. It pulls this value from the ClientName
## EDF located at the Client level.
$vpnName = "$clientName VPN"
## See if the VPN connection already exists
$vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName
If (!$vpnPresent) {
    Try {
        ## Create the VPN connection
        Write-Warning "$vpnName does not exist, creating connection..."
        Add-VpnConnection -Name $vpnName -ServerAddress $serverAddress -TunnelType $tunnelType -AllUserConnection -L2tpPsk $presharedKey -AuthenticationMethod $authenticationMethod -Force
        ## Check for the VPN connection again to see if it exists now
        $vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName
        If ($vpnPresent) {
            Write-Output "!SUCCESS: Created $vpnName successfully"
            Break
        } Else {
            Write-Warning "!ERROR: Failed to created $vpnName"
            Break
        }
    } Catch {
        ## If there was an error thrown during VPN connection creation it will come here and put out this error
        Write-Warning "!ERROR: There was a problem when attempting to create $vpnName"
        Break
    }
} Else {
    ## If the tunnel already exists the script goes straight to here and exits
    Write-Output "!SUCCESS: Verified $vpnName exists"
    Break
}