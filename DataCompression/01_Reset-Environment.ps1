Import-Module dbatools

$path = Split-Path $MyInvocation.MyCommand.Path

$config = Import-PowerShellDataFile -Path "$path\Config.psd1"

Write-Output ("Running with Instance: {0}" -f $config.Instance2016 )
Write-Output ("Running with Database: {0}" -f $config.Database )
Write-Output ("Running with BackupFile: {0}" -f $config.BackupFile )

Remove-DbaDatabase -SqlInstance $config.Instance2016 -Database $config.Database -Confirm:$false

Restore-DbaDatabase -SqlInstance $config.Instance2016 -Path $config.BackupFile -DatabaseName $Config.Database -useDestinationDefaultDirectories

## Run Some Activity
Write-Output ("Running workload from {0}" -f $config.WorkloadFile)
$null = Invoke-Sqlcmd2 -ServerInstance $config.Instance2016 -Database $config.Database -InputFile $config.WorkloadFile -ParseGO

Write-Output '-----'
Write-Output 'Go filter SSMS for sales schema'