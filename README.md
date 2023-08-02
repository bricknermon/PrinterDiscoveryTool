# PowerShell Remote Printer Scanner

This repository contains a PowerShell script (`PrinterScanner.ps1`) which remotely scans and inventories printers connected to a list of computers. The script reads computer names from a provided CSV file, scans each computer for connected printers, and then writes the results to an output CSV file.

## How it works

The script iteratively scans through each computer listed in the input CSV file. For each computer, it fetches the information of connected printers and creates an entry with the computer's name and printer(s) details. If a computer has already been scanned in a previous run, it is skipped.

The output is a CSV file where each row represents a computer, and the columns correspond to the computer's name and connected printers.

The script also maintains a delay between each scan to prevent overloading the network or the computer running the script.

## Prerequisites

1. You should have PowerShell installed on your machine. This script was developed and tested on PowerShell 5.1.

2. The computer running this script should have network access to the computers being scanned.

## Usage

1. Set up your input CSV file with the list of computers to be scanned. This file should have a single column titled 'ComputerName' with the names of the computers.

2. Modify the `PrinterScanner.ps1` script to update the path variables (`$csvFilePath`, `$scannedComputersFilePath`, `$outputCsvPath`) at the top of the script with the appropriate paths for your input CSV file, output CSV file, and the file that keeps track of already scanned computers.

3. Run the script using PowerShell ISE or the PowerShell command line.

## Support

If you encounter any issues or have questions, please open an issue on this GitHub repository.

## Contributing

Contributions are welcome! Please open a pull request with your changes or improvements.


