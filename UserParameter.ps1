# Add the Windows reporting keys and their respective PowerShell scripts
#
UserParameter=wuauclt.pendingreboot,powershell -NoProfile -NoLogo -File "%ProgramFiles%\Zabbix Agent\WINREPORTS\Test-WURebootPending.ps1"