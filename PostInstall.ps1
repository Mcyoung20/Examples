#Sets up logging with function to add desired timestamped text
mkdir C:\Logs
New-Item C:\Logs\PostInstall.log
$Logfile = "C:\Logs\PostInstall.log"
function Write-Log
    {
        Param ([string]$LogString)
        $Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
        $LogMessage = "$Stamp $LogString"
        Add-content $LogFile -value $LogMessage
    }
#Pulls scripts down from gitlab repo
Set-Location C:\scripts
try {
    mkdir c:\scripts
    Invoke-WebRequest http://gitlab.jensen/myoung/deploymentscripts/-/raw/main/Click-Me.bat?inline=false -OutFile c:\scripts\Click-Me.bat
    Invoke-WebRequest http://gitlab.jensen/myoung/deploymentscripts/-/raw/main/Pre-Deploy.ps1?inline=false -OutFile c:\scripts\Pre-Deploy.ps1
    Write-Log "Downloading scripts from GitLab..."
}
catch {
    Write-Log "Unable to download scripts from GitLab"
}

Write-Log "Scripts downloaded succesfully"

#Installs Office 365 with custom configuration
Write-Log "Installing Office 365"
try {
    Set-Location 'C:\Jensen\Office 365'
    start-process -FilePath "C:\Jensen\Office 365\setup.exe" -ArgumentList "/configure configuration.xml" -PassThru -Wait
}
catch {
      Write-Log "Office 365 could not be installed"
}
Write-Log "Office 365 installed succesfully"

#Installs all apps. Will hopefully set up logging later, maybe.
start-process -filepath "C:\windows\system32\msiexec.exe" -argumentlist '/i "C:\Jensen\googlechromestandaloneenterprise64.msi" /q' -PassThru -wait #Installs Google Chrome

Set-Location c:\Jensen

#Start-Process -Wait -FilePath Dell-Command-Update-Windows-Universal-Application_CJ0G9_WIN_4.7.1_A00.EXE -ArgumentList '/s /v/qn' -PassThru #Intalls Dell Command Update

#Start-Process -Wait -FilePath 'c:\Jensen\lcv\System-Interface-Foundation-Update-64.exe' -ArgumentList '/verysilent /norestart' -PassThru #Part 1 of Lenovo Commercial Vantage install

#Start-Process -Wait -FilePath 'c:\Jensen\lcv\VantageService.3.12.13.0-lite.exe' -ArgumentList '/verysilent /norestart' -PassThru #Part 2 of Lenovo Commercial Vantage install

Start-Process -filepath "C:\windows\system32\msiexec.exe" -argumentlist '/package "C:\Jensen\FortiClientVPN.msi" /quiet /norestart' -PassThru -wait #Installs Forticlient

Start-Process -filepath "C:\Program Files\Fortinet\FortiClient\FCConfig.exe" -argumentlist '-m all -f "C:\Jensen\jensen vpn.conf" -o import -i 1 -p Welcome2# -q' -Wait

Set-Location c:\Jensen

#copy-item c:\Jensen\IT-Support.url C:\Users\Public\Desktop -force -verbose #Creates IT Support icon on Public Desktop

copy-item c:\Scripts\Click-Me.bat C:\Users\Public\Desktop -force -verbose #Copies Click-Me.bat to public desktop

Start-Process -Wait -FilePath 'C:\Jensen\MitelConnect.exe' -ArgumentList '/s /v/qn' -PassThru #Installs Mitel Connect app

start-process -filepath "C:\windows\system32\msiexec.exe" -argumentlist '/package "C:\Jensen\AgentInstaller-LAPTOPS-EN.msi" /q /norestart' -Wait -PassThru #Installs Vipre

Set-Location c:\Jensen 

Start-Process -Wait -FilePath "C:\Jensen\AcroRdrDC2200120142_en_US.exe" -ArgumentList ' /sAll /rs /msi EULA_ACCEPT=YES' -PassThru #Installs Acrobat Reader
 
net user administrator /active:no #Disables built-in administrator account since it's not being used

net user administrator "J4nk4ssP@ssw0rd!" #Sets built-in admin password to protect against enable attacks

 #Installs the Windows Update module
 try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #Force TLS1.2
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force #Installs NuGet so that the module can install
    Install-Module -Name PSWindowsUpdate -Force -confirm:$False #Installs the module
    Import-Module -Name PSWindowsUpdate -ErrorAction Stop #Import the update module
}
catch {
    Write-Host "PSWindowsUpdate Could not install"
}

try {
    Install-WindowsUpdate  -AcceptAll -MicrosoftUpdate -forceInstall -Ignorereboot -Confirm:$false -ErrorAction stop #Install all updates, continues on error via try-catch
}
catch {
    Write-Host Windows Updates have failed 
}


#This section permanently disables fastboot
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power

HiberbootEnabled DWORD 0


#Sets Execution policy for running click-me.bat
Set-ExecutionPolicy unrestricted

#Removes all of the scripts
Remove-Item C:\Scripts\PostInstall.ps1
Remove-Item C:\Users\Public\Desktop\Step1.bat