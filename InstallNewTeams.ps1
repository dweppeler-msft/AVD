
Try {

    # Uninstall Microsoft Teams Classic Machine Wide Installer
    Write-Host "Checking if Teams Classic Machine Wide Installer is installed..."
    $TeamsMachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Teams Machine-Wide Installer"}

    if ($null -ne $TeamsMachineWide) {
    Write-Host "Teams Classic Machine Wide Installer is installed..."
    Write-Host "Uninstalling the Teams Classic Machine Wide Installer now..."
    $TeamsMachineWide.Uninstall()
    Write-Host "Successfully uninstalled the Teams Classic Machine Wide Installer..."
    } else { Write-Host "Teams Classic Machine Wide Installer is NOT installed..."}
       
    # Download Edge WebView2 Sources
    Write-Host "Downloading Edge WebView2 sources..."
    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile 'c:\windows\temp\MicrosoftEdgeWebview2Setup.exe'
    # Wait 10s
    Start-Sleep -Seconds 10
    # Install Edge WebView2 silently
    Write-Host "Installing Edge WebView2 now..."
    Start-Process -FilePath 'c:\windows\temp\MicrosoftEdgeWebview2Setup.exe' -Args '/silent /install' -Wait -PassThru
    Write-Host "Successfully installed Edge WebView2..."

    # Download Remote Desktop WebRTC Redirector Service Sources
    Write-Host "Downloading Remote Desktop WebRTC Redirector Service sources..."
    Invoke-WebRequest -Uri 'https://aka.ms/msrdcwebrtcsvc/msi' -OutFile 'c:\windows\temp\MsRdcWebRTCSvc_HostSetup.msi'
    # Wait 10s
    Start-Sleep -Seconds 10
    # Install Edge WebView2 silently
    Write-Host "Installing Remote Desktop WebRTC Redirector Service now..."
    Start-Process -FilePath 'c:\windows\temp\MsRdcWebRTCSvc_HostSetup.msi' -Args '/quiet' -Wait -PassThru
    Write-Host "Successfully installed Remote Desktop WebRTC Redirector Service..."

    # Download Microsoft Teams Sources
    Write-Host "Downloading Microsoft Teams sources..."
    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409' -OutFile 'c:\windows\temp\teamsbootstrapper.exe'
    # Wait 10s
    Start-Sleep -Seconds 10
    # Install Microsoft Teams silently
    Write-Host "Installing Microsoft Teams now..."
    Start-Process -FilePath 'c:\windows\temp\teamsbootstrapper.exe' -Args '-p' -Wait -PassThru
    Write-Host "Successfully installed Microsoft Teams..."
    Write-Host "Enabling Microsoft Teams for VDI..."
    New-Item -Path 'HKLM:\SOFTWARE\Microsoft\' -Name Teams -Value "" -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name "IsWVDEnvironment" -Type "Dword" -Value "1" -Force
    Write-Host "Successfully enabled Microsoft Teams for VDI..."
           
    } catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

