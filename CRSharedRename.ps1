# Set the log file path
$Logfile = "\\corp-rs-01\it\young\CRSharedRename.log"

# Define the Write-Log function to add timestamped text to the log file
function Write-Log {
    Param ([string]$LogString)

    # Add the current date and time to the log message
    $Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    $LogMessage = "$Stamp $LogString"

    # Append the log message to the log file
    Add-content $LogFile -value $LogMessage
}

# Specify the path to the CSV file
$csvFilePath = "\path\to\your\mapping.csv"

# Specify the base directory where the folders are located
$baseDirectory = "\path\to\your\base\directory"

# Load the CSV file into an array
$csvData = Import-Csv -Path $csvFilePath

# Loop through each row in the CSV data
foreach ($row in $csvData) {
    $oldName = $row.OldName
    $newName = $row.NewName

    $oldFolderPath = Join-Path -Path $baseDirectory -ChildPath $oldName
    $newFolderPath = Join-Path -Path $baseDirectory -ChildPath $newName

    if (Test-Path -Path $oldFolderPath -PathType Container) {
        try {
            Write-Log "Renaming folder '$oldName' to '$newName'"
            Rename-Item -Path $oldFolderPath -NewName $newName -Force
            Write-Log "Renamed folder '$oldName' to '$newName'"
            }
        catch {
            Write-Log "Failed to rename folder '$oldName' to '$newName'"
        }

    } else {
        Write-Log "Folder '$oldName' not found"
    }
}