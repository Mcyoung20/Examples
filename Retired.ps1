# IMPORTANT: YOU WILL GET A WALL OF RED TEXT WHEN YOU RUN THIS SCRIPT
# AS LONG AS IT ALL PERTAINS TO GET-ADUSER IT IS WORKING PROPERLY


#Sets up the current date so old lists won't be overwritten
$FileDate =  (Get-Date).toString("MM-dd-yyyy")

# Create a yyyMMddHHmmss.Z formatted date string in UTC. Change the date before running this script.
$RetireDate= ( Get-Date 'Monday, December 31, 2018 2:41:59 PM' ).ToUniversalTime().ToString('yyyMMddHHmmss.Z')

#Imports list from Ninja. That list is created by exporting all workstations and uploading them to the IT Share.
$NinjaList = Import-Csv \\*SERVER*\NinjaExport.csv

#Runs through the list to find which computers are older than the retire date and puts them into a CSV.
foreach ($Computer in $NinjaList){
    #For some reason, Ninja put a space in their object, so this line exists to make the space less annoying. Without it, the filter does not work.
    $Name = $Computer."Display Name"

    #Checks the user attached to the computer.
    $NinjaUser = $Computer."Last LoggedIn User"
    $Domain = $NinjaUser.split("\",2)[0]
    $UN = $NinjaUser.split("\",2)[1]
    $User = Get-ADUser $UN

    #If the user is not disabled, gets the computer object and adds it to to CSV. Otherwise, moves on to the next computer.
    if ("$User.Enabled" -ne "False") {
        Get-ADComputer -Filter {name -eq $Name -and whenCreated -lt $RetireDate} -Properties Name,OperatingSystem,Created,LastLogonDate,Description |
        Select-Object  Name,OperatingSystem,Created,LastLogonDate,Description |
        Export-Csv -Path \\*SERVER*\EOLList_$FileDate.csv -Append
    }
}
