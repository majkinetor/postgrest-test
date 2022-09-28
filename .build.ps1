param (
    [string] $aPostgrePassword = (property PGPASSWORD test),
    [int]    $aPerfLength = 60,
    [int]    $aTodosCount = (property ATODOSCOUNT 100000)
)

#Synopsis: Install postgresql12 postgrerest and superbenchmarker via chocolatey
task Deps {
    if (!(Get-Command choco -ea 0)) { throw "Chocolatey installation is required: Run: iwr https://chocolatey.org/install.ps1 | iex" }
    choco install postgresql14 --params '/Password:test'
    choco install postgrest
    choco install superbenchmarker
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    Update-SessionEnvironment
}

#Synopsis: Recreate database using db.sql. Pass aTodosCount to specify number of todo items to seed (default 100K)
task RecreateDb {
    $Env:PGPASSWORD = $aPostgrePassword
    Get-Content .\db.sql -Raw | Expand-PoshString | psql -Upostgres
}

#Synopsis: Run postgrest backend
task Run {
    if (!(Test-Path C:\postgrest\postgrest.exe)) { throw 'C:\postgrest\postgrest.exe not found' }

    $cmd = "C:\postgrest\postgrest.exe postgrest.conf"
    $cmdTitle = 'postgrest server'

    Start-Process 'cmd.exe' -ArgumentList "/D /C title $cmdTitle & $cmd"
}

#Synopsis: Run inside Windows Sandbox
task RunSandboxed {
    .\Test-Sandbox.ps1 -Script {
        cd postgrest-test
        Set-Alias ib $pwd\Invoke-Build.ps1
        ib Deps, RecreateDb, Run, Todo, Todos
    }
}

#Synopsis: Get 50 todo items with random offset
task Todos {
    Invoke-RestMethod "http://localhost:3000/todos?id=gt.$(Get-Random $aTodosCount)&order=id&limit=50"
}

#Synopsis: Get single todo item with random id
task Todo {
    Invoke-RestMethod "http://localhost:3000/todos?id=eq.$(Get-Random $aTodosCount)"  | Out-String
}

#Synopsis: Start perf test with limit set to 50 todo items and random offset
task PerfTestBulk {
    sb -c 10 -N $aPerfLength  -u "http://localhost:3000/todos?id=gt.{{{id:RAND_INTEGER:[1:$aTodosCount]}}}&order=id&limit=50" -t sb_headers.txt
}

#Synopsis: Start perf test with limit set to 50 todo items and random offset (alternative)
task PerfTestBulk2 {
    sb -c 10 -N $aPerfLength  -u "http://localhost:3000/todos?order=id&limit=50&offset={{{offset:RAND_INTEGER:[1:$aTodosCount]}}}" -t sb_headers.txt
}

#Synopsis: Start perf test with single random todo item
task PerfTestSingle {
    sb -c 10 -N $aPerfLength  -u "http://localhost:3000/todos?id=eq.{{{offset:RAND_INTEGER:[1:$aTodosCount]}}}"
}

function Expand-PoshString() {
    [CmdletBinding()]
    param ( [parameter(ValueFromPipeline = $true)] [string] $str)

    "@`"`n$str`n`"@" | iex
}
