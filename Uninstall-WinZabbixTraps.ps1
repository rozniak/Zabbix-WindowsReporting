<#
    .SYNOPSIS
    This script is used for uninstalling the PowerShell scripts used for providing
    Zabbix traps into the task scheduler on the local machine.

    .DESCRIPTION
    This script will uninstall all scheduled tasks found with the GUID of the Windows
    Zabbix trap tasks in their description.

    .EXAMPLE
    Uninstall-WinZabbixTraps.ps1

    .NOTES
    Author: Rory Fewell
    GitHub: https://github.com/rozniak
    Website: https://oddmatics.uk
#>

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

$guid  = Get-Content -Path "$scriptRoot\task-guid"
$tasks = Get-ScheduledTask | Where-Object { $_.Description -eq $guid }

foreach ($task in $tasks)
{
    $task | Unregister-ScheduledTask -Confirm:$FALSE
}
