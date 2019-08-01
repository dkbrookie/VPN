$vpnName = $vpnName -replace ('e:','')
$vpnName = "$vpnName VPN"
$vpnPresent = Get-VpnConnection -AllUserConnection -Name $vpnName
If (!$vpnPresent) {
    Write-Warning "!ERROR: $vpnName does not exist!"
} Else {
    Write-Output "Verified $vpnName exists"
}