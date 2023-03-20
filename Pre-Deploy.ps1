#Sets a variable for the current computer name
$FriendlyName = $env:computername

#Configure remote session
$RemoteADServer = "SERVER FQDN"


#Creates function for list of OU locations
function Write-Location
    {
        Write-Host "1. Bruce"
        Write-Host "2. Camas"
        Write-Host "3. Corporate"
        Write-Host "4. Fontana"
        Write-Host "5. Fresno"
        Write-Host "6. Hawaii"
        Write-Host "7. Jensen Family Members"
        Write-Host "8. Jensen Water Resources"
        Write-Host "9. Kingsburg"
        Write-Host "10. Lakeside"
        Write-Host "11. Las Vegas"
        Write-Host "12. Lockeford"
        Write-Host "13. Martinez"
        Write-Host "14. MetalTech"
        Write-Host "15. Olson"
        Write-Host "16. Ontario"
        Write-Host "17. Orland"
        Write-Host "18. Phoenix"
        Write-Host "19. Portland"
        Write-Host "20. Puyallup"
        Write-Host "21. QMC"
        Write-Host "22. Sacramento"
        Write-Host "23. Santa Rosa"
        Write-Host "24. Sparks"
        Write-Host "25. Tucson"
    }

    #Creates function for list of AutoCAD Deployments
    function Write-CAD
    {
        Write-Host "1. AutoCAD Mechanical_Inventor_Vault.bat"
        Write-Host "2. AutoCAD_Inventor_Vault.bat"
        Write-Host "3. Inventor_Vault.bat"
    }

#Prompts for the computer location, evaluates input, and verifies
do {
        Write-Location
        $location = Read-Host "Please select the location of the computer being deployed"

        #Sets the $OU to the coresponding location based on read-host input from $location
        switch ($location)
        {
            1 {$OU = "OU=Computers,OU=Bruce,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Bruce"}
            2 {$OU = "OU=Computers,OU=Camas,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Camas"}
            3 {$OU = "OU=Computers,OU=Corporate,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Corporate"}
            4 {$OU = "OU=Computers,OU=Fontana,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo ="Fontana"}
            5 {$OU = "OU=Computers,OU=Fresno,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Fresno"}
            6 {$OU = "OU=Computers,OU=Hawaii,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Hawaii"}
            7 {$OU = "OU=Computers,OU=Jensen Family Members,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Jensen Family Members"}
            8 {$OU = "OU=Computers,OU=Jensen Water Resources,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Water Resources"}
            9 {$OU = "OU=Computers,OU=Kingsburg,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Kingsburg"}
            10 {$OU = "OU=Computers,OU=Lakeside,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Lakeside"}
            11 {$OU = "OU=Computers,OU=Las Vegas,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Las Vegas"}
            12 {$OU = "OU=Computers,OU=Lockeford,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Lockeford"}
            13 {$OU = "OU=Computers,OU=Martinez,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Martinez"}
            14 {$OU = "OU=Computers,OU=MetalTech,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "MetalTech"}
            15 {$OU = "OU=Computers,OU=Olson,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Olson"}
            16 {$OU = "OU=Computers,OU=Ontario,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Ontario"}
            17 {$OU = "OU=Computers,OU=Orland,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Orland"}
            18 {$OU = "OU=Computers,OU=Phoenix,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Phoenix"}
            19 {$OU = "OU=Computers,OU=Portland,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Portland"}
            20 {$OU = "OU=Computers,OU=Puyallup,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Puyallup"}
            21 {$OU = "OU=Computers,OU=QMC,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "QMC"}
            22 {$OU = "OU=Computers,OU=Sacramento,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Sacramento"}
            23 {$OU = "OU=Computers,OU=Santa Rosa,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Santa Rosa"}
            24 {$OU = "OU=Computers,OU=Sparks,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Sparks"}
            25 {$OU = "OU=Computers,OU=Tuscon,OU=Jensen,DC=JPC,DC=LOCAL"; $Geo = "Tuscon"}
        }
        $Verify = Read-Host "Is $Geo the correct location? [y/n]"
    } until ($Verify -eq "y")

#Gathers credentials for Remote PSSession
$Username = Read-Host "Please enter your admin username"
$RemotePassword = Read-Host "Enter password" -AsSecureString
[pscredential]$Credential = New-Object System.Management.Automation.PSCredential($Username, $RemotePassword) #Create credential object
$RemoteSession = New-PSSession -ComputerName $RemoteADServer -Credential $Credential

#Establishes a PSSession with $RemoteADServer and move the computer object to the $OU defined by $location
try{
        $ErrorCode = Invoke-Command -Session $RemoteSession -ArgumentList ($OU,$FriendlyName) -ScriptBlock {
            param(
            [string]$OU,
            [string]$FriendlyName
            )
            try {
                $Identity = Get-ADComputer $FriendlyName
                $Computer = $Identity.distinguishedname
                Move-ADObject -Identity $Computer -TargetPath $OU
            }
            catch {
                $ErrorCode = "true"
                return $ErrorCode
            }
        }
    }
    catch {
        if($ErrorCode -eq "true"){
            Write-Host "Unable to move computer. Please move computer manually, then return to this script and press any key to continue."
            Pause
        }
    }
