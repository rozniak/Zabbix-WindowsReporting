<#
    .SYNOPSIS
    This script is used for obtaining the number of updates available to be installed
    on the Windows Update client.

    .DESCRIPTION
    This script uses the Microsoft.Update.Session COM object in order to make a WU
    search call to the default WU server to discover updates applicable to the client.
    These updates are counted and the final number is pushed to Zabbix via Zabbix Trap.

    .PARAMETER ZabbixIP
    The IP address of the Zabbix server/proxy to send the value to.
    
    .PARAMETER ComputerName
    The hostname that should be reported to Zabbix, in case the hostname you set up in
    Zabbix isn't exactly the same as this computer's name.
    
    .EXAMPLE
    Get-WUUpdateCount.ps1 -ZabbixIP 10.0.0.240

    .NOTES
    Author: Rory Fewell
    GitHub: https://github.com/rozniak
    Website: https://oddmatics.uk
#>

Param (
    [Parameter(Position=0, Mandatory=$TRUE)]
    [ValidatePattern("^(\d+\.){3}\d+$")]
    [String]
    $ZabbixIP,
    [Parameter(Position=1, Mandatory=$FALSE)]
    [ValidatePattern(".+")]
    [String]
    $ComputerName = $env:COMPUTERNAME
)

$wuAgent    = New-Object -ComObject "Microsoft.Update.Session";
$wuSearcher = $wuAgent.CreateUpdateSearcher();
$wuResults  = $wuSearcher.Search("");

# Push value to Zabbix
#
$arch = [System.IntPtr]::Size * 8;

& ($env:ProgramFiles + "\Zabbix Agent\bin\win" + $arch + "\zabbix_sender.exe") ("-z", $ZabbixIP, "-p", "10051", "-s", $ComputerName, "-k", "wuauclt.count", "-o", $wuResults.Updates.Count);