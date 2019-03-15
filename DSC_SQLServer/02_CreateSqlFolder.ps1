Configuration CreateSqlFolder {

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node @('dscsvr1', 'dscsvr2') {
        File CreateDataDir {
            DestinationPath = 'C:\SQL2017\SQLData\'
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateLogDir {
            DestinationPath = 'C:\SQL2017\SQLLogs\'
            Ensure          = 'Present'
            Type            = 'Directory'
        }
    }
}

Get-Command -CommandType Configuration

CreateSqlFolder -Output .\Output\ 

## cleanup
Remove-Item .\output\*.mof