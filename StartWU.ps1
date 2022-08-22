Try {
$output = Get-Package -Name PSWindowsUpdate
If ($null -ne $output) {
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
New-item -Path $env:TMP -Name "logWU.txt" -ItemType "file" -Value "Script has be performed!"
}

} catch  {
write-host ("same errors!")

}
