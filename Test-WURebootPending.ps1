<#
    .SYNOPSIS
    This script is used for checking if a reboot is needed by Windows Update.

    .DESCRIPTION
    This script tests the RebootRequired key in the registry to find out whether
    Windows Update needs the machine rebooted to finish installing pending updates.
    
    .EXAMPLE
    Test-WURebootPending.ps1

    .NOTES
    Author: Rory Fewell
    GitHub: https://github.com/rozniak
    Website: https://oddmatics.uk
#>

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
{
    return 1;
}
else
{
    return 0;
}