# Define paths to required files
# Path to the CSV file containing the names of computers to be scanned
$csvFilePath = "input file path"

# Path to the CSV file storing the names of computers that have already been scanned
$scannedComputersFilePath = "desired output path"

# Path to the output CSV file where the results of the scanning will be stored
$outputCsvPath = "desired output path"

# Time delay (in seconds) between each scan to prevent overloading the network or the system
$delaySeconds = 0

# Import the names of computers from the csvFilePath CSV file, eliminating any duplicates
$computers = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty ComputerName -Unique

# Initialize an array to hold the names of computers that have already been scanned
$scannedComputers = @()

# If the scannedComputersFilePath file exists, import the computer names from it, again eliminating duplicates
if (Test-Path -Path $scannedComputersFilePath) {
    $scannedComputers = Get-Content -Path $scannedComputersFilePath | Where-Object { $_ -ne "" } | Select-Object -Unique
}

# Initialize a variable to hold the maximum number of printers found on any computer
$maxPrinters = 0

# Initialize an array to hold the existing data from previous scans
$existingData = @()
# If the outputCsvPath file exists, import its content and determine the maximum number of printers found on any computer during previous scans
if (Test-Path -Path $outputCsvPath) {
    $existingData = @(Import-Csv -Path $outputCsvPath)
    $maxPrinters = ($existingData[0].PSObject.Properties.Name | Where-Object { $_ -match 'Printer\d+' } | Measure-Object).Count
}

# Loop through each computer in the $computers array
foreach ($computer in $computers) {
    # If a computer has already been scanned, skip it and move to the next iteration
    if ($scannedComputers -contains $computer) {
        Write-Host "Skipping computer: $computer (already scanned)"
        continue
    }

    try {
        # Attempt to get the printer information from the remote computer
        $printers = Get-WmiObject -Class Win32_Printer -ComputerName $computer -ErrorAction Stop |
                    Select-Object -ExpandProperty Name

        # Create a new object to hold the computer's name and its printer(s)
        $printerObject = [PSCustomObject]@{
            'ComputerName' = $computer
        }

        # Loop through each printer, adding it as a separate property to the $printerObject object
        for ($i = 0; $i -lt $printers.Count; $i++) {
            $printerObject | Add-Member -NotePropertyName "Printer$i" -NotePropertyValue $printers[$i]
        }

        # If a computer has more printers than the current $maxPrinters value, update $maxPrinters and ensure all objects have the same number of printer properties
        if ($printers.Count -gt $maxPrinters) {
            $maxPrinters = $printers.Count

            foreach ($info in $existingData) {
                for ($i = $info.PSObject.Properties.Name.Where({$_ -match 'Printer\d+'}).Count; $i -lt $maxPrinters; $i++) {
                    $info | Add-Member -NotePropertyName "Printer$i" -NotePropertyValue $null
                }
            }
        }

        # Add the $printerObject object to the $existingData array
        $existingData += $printerObject

        # Add the scanned computer's name to the $scannedComputers array
        $scannedComputers += $computer

        # Append the scanned computer's name to the scannedComputersFilePath file
        Add-Content -Path $scannedComputersFilePath -Value ("$computer`n")
    }
    catch {
        # If an error occurs, ignore it and continue with the next iteration
        continue
    }

    # Delay the next iteration by the time specified in the $delaySeconds variable
    Start-Sleep -Seconds $delaySeconds
}

# Export the scanning results stored in the $existingData array to the outputCsvPath CSV file
$existingData | Export-Csv -Path $outputCsvPath -NoTypeInformation -Force
