
# Can import dbatools
Describe "Module is good to go" {
    Context "dbatools imports" {
        $null = Import-Module dbatools
        $module = Get-Module dbatools
        It "Module was imported" {
            $module | Should Not BeNullOrEmpty
        }
        It "Module version is 1.0.67" {
            $module.Version | Should Be "1.0.67"
        }
        It "Module should import 583 commands" {
            (get-command -module dbatools | Measure).Count | Should Be 583
        }
    }
}

# credential exists
Describe "Credentials exist" {
    Context "Credential exists" {
        It "Credential is not null" {
            $credential | Should Not BeNullOrEmpty
        }
    }
    Context "username is sa" {
        It "Username is sa" {
            $credential.UserName | Should Be "sa"
        }
    }
}
# two instances
Describe "Two instances are available" {
    Context "Two instances are up" {
        $mssql1 = Connect-DbaInstance -SqlInstance mssql1 -SqlCredential $credential
        $mssql2 = Connect-DbaInstance -SqlInstance mssql2 -SqlCredential $credential
        It "mssql1 is available" {
            $mssql1.Name | Should Not BeNullOrEmpty
            $mssql1.Name | Should Be 'mssql1'
        }
        It "mssql2 is available" {
            $mssql2.Name | Should Not BeNullOrEmpty
            $mssql2.Name | Should Be 'mssql2'
        }
    }
}
# mssql1 has 2 databases
Describe "mssql1 databases are good" {
    Context "AdventureWorks2017 is good" {
        $db = Get-DbaDatabase -SqlInstance mssql1 -SqlCredential $credential
        $adventureWorks = $db | where name -eq 'AdventureWorks2017'
        It "AdventureWorks2017 is available" {
            $adventureWorks | Should Not BeNullOrEmpty
        }
        It "AdventureWorks status is normal" {
            $adventureWorks.Status | Should Be Normal
        }
        It "AdventureWorks Compat is 140" {
            $adventureWorks.Compatibility | Should Be 140
        }
    }
    Context "Indexes are fixed on HumanResources.Employee (bug)" {
        $empIndexes = (Get-DbaDbTable -SqlInstance mssql1 -SqlCredential $credential -Database AdventureWorks2017 -Table Employee).indexes | select name, IsUnique
        It "There are now just two indexes" {
            $empIndexes.Count | Should Be 2
        }
        It "There should be no unique indexes" {
            $empIndexes.IsUnique | Should BeFalse
        }
    }
    Context "DatabaseAdmin is good" {
        $db = Get-DbaDatabase -SqlInstance mssql1 -SqlCredential $credential
        $DatabaseAdmin = $db | where name -eq 'DatabaseAdmin'
        It "DatabaseAdmin is available" {
            $DatabaseAdmin | Should Not BeNullOrEmpty
        }
        It "DatabaseAdmin status is normal" {
            $DatabaseAdmin.Status | Should Be Normal
        }
        It "DatabaseAdmin Compat is 140" {
            $DatabaseAdmin.Compatibility | Should Be 140
        }
    }
}

Describe "Backups worked" {
    Context "AdventureWorks was backed up" {
        $instanceSplat = @{
            SqlInstance   = 'mssql1'
            SqlCredential = $credential
        }
        It "AdventureWorks has backup history" {
            Get-DbaDbBackupHistory @instanceSplat | Should Not BeNullOrEmpty
        }
    }
}

Describe "Proc architecture is x64" {
    Context "Proc arch is good" {
        It "env:processor_architecture should be AMD64" {
            $env:PROCESSOR_ARCHITECTURE | Should Be "AMD64"
        }
    }
}
