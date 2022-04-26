# Software install Script
#
# Applications to install:

#region Set logging
New-Item -ItemType Directory -force -path "c:\temp\"
$logFile = "c:\temp\" + (get-date -format 'yyyyMMdd') + '_softwareinstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}

Write-Host "Installing Core Apps"

# Connect to StorageAccount

$StorageAccountHostname = "samemdroid.file.core.windows.net"
$StorageAccountShareName = "apps/core-apps"
$SAS = "?sv=2020-08-04&ss=f&srt=sco&sp=rwdlc&se=2022-06-30T21:06:16Z&st=2022-04-06T13:06:16Z&spr=https&sig=lS0n1c%2FBQDP5LzFCwnAYxgV41X34LmfO2sPYwfvj9NY%3D"

# Create folders
$Localpath = "C:\programdata\wvd"
Write-Host "Installing Core Apps"

# Get azcopy
New-Item -ItemType Directory -force -path "$Localpath\Apps\azcopy"

Try {
    Invoke-WebRequest -uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile "$LocalPath\Apps\azcopy.zip"
    Expand-Archive "$LocalPath\Apps\azcopy.zip" "$LocalPath\Apps\azcopy" -force
    $AzCopy = "$(get-item "$LocalPath\Apps\azcopy\azcopy_windows*" | select-object -expand fullname)\azcopy.exe"
    $env:AZCOPY_LOG_LOCATION = "$localpath\Apps\azcopy"
    $env:AZCOPY_JOB_PLAN_LOCATION = "$localpath\Apps\azcopy"
    
    # Download installers
    $Source = "https://$StorageAccountHostname/$StorageAccountShareName$SAS"
    $Dest = "$LocalPath\Apps"
    
    Start-Process -FilePath "$AzCopy" -ArgumentList "copy `"$Source`" `"$Dest`" --recursive --preserve-smb-permissions=true --preserve-smb-info=true" -wait
    
    $AppList = import-csv -path "$LocalPath\Apps\core-apps\AppList.csv"
    
    Set-Location "$Localpath\Apps\core-apps"
    
    foreach ($app in $AppList) {
        $Installer = "$Localpath\Apps\core-apps$($app.installer)"
        
        Write-Host $app.Name
        Write-Host "$installer $($app.Parameters)"
    
        
    
        if ($app.installer.endswith("ps1")) {
            Write-Host "Powershell Script"
            if ($null -ne $app.Parameters) {
                $ArgumentList = "-argumentList $($app.Parameters)"
            } else {
            & $installer $ArgumentList
            }
            
        }
        if ($app.installer.endswith("exe")) {
            Write-Host "EXE Installer"
            if ($null -ne $app.Parameters) {
               Start-Process -FilePath "`"$installer`"" -Wait -Verb RunAs -ArgumentList $app.Parameters
            } else {
               Start-Process -FilePath "`"$installer`"" -Wait -Verb RunAs
            }
        }
       if ($app.installer.endswith("msi")) {
            Write-Host "MSI Installer"
            Start-Process msiexec.exe -Wait -Verb RunAs -ArgumentList  ("/I " + $Installer + " " + $app.Parameters)
            
        }
    }
    Write-Host "Completed"
    Write-Host "Cleanup Source Files"
    Set-Location "$env:temp"
    Remove-Item -Path $Localpath -Recurse -Force -Confirm:$false

} catch {

    Write-Host "ERROR: $($_.Exception.Message)"
}

#region Time Zone Redirection
$Name = "fEnableTimeZoneRedirection"
$value = "1"
# Add Registry value
try {
    New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services").PSObject.Properties.Name -contains $name) {
        Write-Host "Added time zone redirection registry key"
    }
    else {
        Write-Host "Error locating the time registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Error adding time registry KEY: $ErrorMessage"
}