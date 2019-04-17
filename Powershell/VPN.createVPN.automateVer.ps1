If (!($serverAddress)) {
  Write-Warning "!ERROR: No server address defined, exiting script"
  Break
}
If (!($connectionName)) {
  Write-Warning "!ERROR: No connection name was defined, exiting script"
  Break
}
If (!($presharedKey)) {
  Write-Warning "!ERROR: No preshare key was defined, exiting script"
  Break
}
If (!($tunnelType)) {
  Write-Warning "!ERROR: No tunnel type was defined, exiting script"
  Break
}
If (!($authenticationMethod)) {
  Write-Warning "!ERROR: No authentication method was defined, exiting script"
  Break
}
Add-VpnConnection -Name $connectionName -ServerAddress $serverAddress -TunnelType $tunnelType -AllUserConnection -L2tpPsk $presharedKey -AuthenticationMethod $authenticationMethod -Force
