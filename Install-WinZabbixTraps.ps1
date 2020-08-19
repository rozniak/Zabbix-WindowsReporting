﻿<#
    .SYNOPSIS
    This script is used for installing the PowerShell scripts used for providing Zabbix
    traps into the task scheduler on the local machine.

    .DESCRIPTION
    This script first queries for the IP of the Zabbix Server or Proxy that is then
    embedded as part of the parameters used in the scheduled task actions. The tasks are
    scheduled to run hourly into order to provide data to Zabbix via traps.
    
    .PARAMETER ZabbixIP
    The IP address of the Zabbix server/proxy to send the value to.
    
    .PARAMETER ComputerName
    The hostname that should be reported to Zabbix, in case the hostname you set up in
    Zabbix isn't exactly the same as this computer's name.
    
    .EXAMPLE
    Install-WinZabbixTraps.ps1 -ZabbixIP 10.0.0.240

    .NOTES
    Author: Rory Fewell
    GitHub: https://github.com/rozniak
    Website: https://oddmatics.uk
#>

Param (
    [Parameter(Position=0, Mandatory=$TRUE)]
    [ValidatePattern("^(\d+\.){3}\d+$")]
    [string]
    $ZabbixIP,
    [Parameter(Position=1, Mandatory=$FALSE)]
    [ValidatePattern(".+")]
    [string]
    $ComputerName = $env:COMPUTERNAME,
    [Parameter(Position=2, Mandatory=$FALSE)]
    [string]
    $ZabbixRoot   = $env:ProgramFiles + "\Zabbix Agent"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

$nextHour = [System.DateTime]::Now.AddHours(1);
$oneHour  = New-TimeSpan -Hours 1;

$globalTrigger = New-ScheduledTaskTrigger -Once                         `
                                          -At                 $nextHour `
                                          -RepetitionInterval $oneHour;
$guid          = Get-Content -Path "$scriptRoot\task-guid"
$systemAccount = New-ScheduledTaskPrincipal -UserID    "NT AUTHORITY\SYSTEM" `
                                            -LogonType ServiceAccount        `
                                            -RunLevel  Highest;

# Set up WU agent update counter task
#
$wuCountFilePath = "$ZabbixRoot\WINREPORTS\Get-WUUpdateCount.ps1";
$wuCountTitle    = "Count Windows Updates for Client (Zabbix Trap)";

$wuCountActionArgs =
    (
        "-NoProfile",
        "-NoLogo",
        "-File",
        "`"$wuCountFilePath`"",
        "-ZabbixIP",
        $ZabbixIP,
        "-ComputerName",
        $ComputerName
    ) -join " ";
$wuCountAction     = New-ScheduledTaskAction -Execute  "powershell.exe"   `
                                             -Argument $wuCountActionArgs;

$wuCountTask = Register-ScheduledTask -TaskName    $wuCountTitle  `
                                      -Trigger     $globalTrigger `
                                      -Action      $wuCountAction `
                                      -Principal   $systemAccount `
                                      -Description $guid          `
               | Out-Null;
