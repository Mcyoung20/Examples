#Defines the group to search for users and the group to add those users to
$OldGroup = ""
$TargetGroup = ""

$LogServer = ""
#Sets up logging with function to add desired timestamped text
New-Item $LogServer\GroupMove.log
$Logfile = "$LogServer\GroupMove.log"
function Write-Log
    {
        Param ([string]$LogString)
        $Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
        $LogMessage = "$Stamp $LogString"
        Add-content $LogFile -value $LogMessage
    }

#Attempts to create an array of all users in $OldGroup
try {
    $OldGroupUsers = Get-ADGroupMember "$OldGroup"
    Write-Log "Generating list of AD Users and writing to $OldGroup Array"
    $Success = $true
}
catch {
    Write-Log "Unable to create array."
    $Success = $false
    exit
}

if ($Success -eq $true) {
    Write-Log "Succesfully created $OldGroup Array"
}

#Creates a CSV of the existing Target group for restoration purposes
Get-ADGroupMember "$TargetGroup" |
Select-Object Name,SAMAccountName |
Export-Csv -Path $LogServer\GroupMoveRollback.csv -Force

#Itterates through $OldGroup array and moves object into $TargetGroup
foreach ($User in $OldGroupUsers){
    
    #Makes an easy variable to use with the members flag
    $SAM = $User.SAMAccountName
   
    try {
        $Attempt = Add-ADGroupMember -Identity "$TargetGroup" -Members $SAM
        $Success = $true
        Write-Log "Adding $SAM to $TargetGroup"
        }
    catch {
        $Success = $false
        Write-Log "Unable to add $SAM to $TargetGroup"
        #Adds move status as a property to the object
        $Attempt | Add-Member -MemberType NoteProperty -Name Status -Value "Failed" -Force
        
        #Sets up table for CSV log, then exports the log
        $CSVTable = $Attempt | Select-Object name,SAMAccountName,Status
        $CSVTable | Export-Csv $LogServer\SuccessLog.csv -Append
        continue
    }
    
    if ($Success -eq $true) {
        Write-Log "Sucessfully added $SAM to $TargetGroup"
        
        #Adds move status as a property to the object
        $Attempt | Add-Member -MemberType NoteProperty -Name Status -Value "Moved Succesfully" -Force
        
        #Sets up table for CSV log, then exports the log
        $CSVTable = $Attempt | Select-Object name,SAMAccountName,Status
        $CSVTable | Export-Csv $LogServer\SuccessLog.csv -Append
        continue
    }

}