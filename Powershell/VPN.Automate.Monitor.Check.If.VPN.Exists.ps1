Function New-ClientVPN {

    Param(
        [Parameter(
            Mandatory = $true,
            HelpMessage='help message'
        )]
        [string]$ServerAddress
        ,[Parameter(
            Mandatory = $true,
            HelpMessage='help message'
        )]
        [ValidateSet('Automatic','Ikev2','L2tp','Pptp','Sstp')]
        [string]$TunnelType
        ,[Parameter(
            Mandatory = $false,
            HelpMessage='help message'
        )]
        [boolean]$AllUserConnection = $true
        ,[Parameter(
            Mandatory = $true,
            HelpMessage='help message'
        )]
        [string]$PresharedKey
        ,[Parameter(
            Mandatory = $true,
            HelpMessage='help message'
        )]
        [ValidateSet('Chap','Eap','MachineCertificate','MSChapv2','Pap')]
        [string]$AuthenticationMethod
        ,[Parameter(
            Mandatory = $false,
            HelpMessage='help message'
        )]
        [ValidateSet(0,1)]
        [int32]$SplitTunnel = 0
        ,[Parameter(
            Mandatory = $false,
            HelpMessage='help message'
        )]
        [string]$ClientName = 'Automated'
    )


    Function Invoke-Output {
        param ([string[]]$output)
        $output = $output -join "`n"
        Write-Output $output
    }


    # Define vars
    $output = @()
    $vpnName = "$clientName VPN"
    # Removing all non word characters from client name
    $ClientName = $ClientName -replace '[\W]', ''


    # Handling NULL or $false from Automate can be difficult so we're using 1/0 and translating to $true/$false
    If ($SplitTunnel -eq 1) {
        $SplitTunnel = $true
    } Else {
        $SplitTunnel = $false
    }


    If ($SplitTunnel) {
        $vpnConfigHash = @{
            Name = $vpnName
            ServerAddress = $ServerAddress
            TunnelType = $TunnelType
            AllUserConnection = $AllUserConnection
            L2tpPsk = $PresharedKey
            AuthenticationMethod = $AuthenticationMethod
            SplitTunnel = $true
            Force = $true
        }
    } Else {
        $vpnConfigHash = @{
            Name = $vpnName
            ServerAddress = $ServerAddress
            TunnelType = $TunnelType
            AllUserConnection = $AllUserConnection
            L2tpPsk = $PresharedKey
            AuthenticationMethod = $AuthenticationMethod
            Force = $true
        }
    }


    # See if the VPN connection already exists
    $vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName -EA 0
    If (!$vpnPresent) {
        Try {
            # Create the VPN connection
            $output += "$vpnName does not exist, creating connection..."
            # the variablse being used here that were never defined in this script are passed in from Automate. It's
            # taking values from EDFs and setting them as powershell variables before it calls this script. Because of
            # this the script will fail if called standalone w/o the monitor.
            Add-VpnConnection @vpnConfigHash
            # Check for the VPN connection again to see if it exists now
            $vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName -EA 0
            If ($vpnPresent) {
                $output += "!SUCCESS: Created $vpnName successfully"
                Invoke-Output $output
                Break
            } Else {
                $output += "!ERROR: Failed to created $vpnName"
                Invoke-Output $output
                Break
            }
        } Catch {
            # If there was an error thrown during VPN connection creation it will come here and put out this error
            $output += "!ERROR: There was a problem when attempting to create $vpnName. Error output: $error"
            Invoke-Output $output
            Break
        }
    } Else {
        Try {
            $output += "Verified $vpnName already exists, checking configuration..."
            # Check the VPN connection properties. If the settings are different than the ones we are sending,
            # delete the VPN connection, then recreate it with the accurate settings.
            If (($vpnPresent).ServerAddress -ne $ServerAddress -or ($vpnPresent).AuthenticationMethod -ne $AuthenticationMethod -or ($vpnPresent).TunnelType -ne $TunnelType -or ($vpnPresent).SplitTunneling -ne $SplitTunnel) {
                $output += "$vpnName has settings that do not match the configuration sent from Automate, recreating VPN connection..."
                Remove-VpnConnection -AllUserConnection -Name $vpnName -Force
                Add-VpnConnection @vpnConfigHash
                $output += "!SUCCESS: Created $vpnName successfully"
            } Else {
                $output += "!SUCCESS: Verified all $vpnName settings match configurations from Automate!"
            }
            Invoke-Output $output
            Break
        } Catch {
            # If we're here then this means something went wrong when removing/creating the VPN connection above
            $output += "!ERROR: Failed to created $vpnName. Error ourput: $error"
            Invoke-Output $output
            Break
        }
    }
}