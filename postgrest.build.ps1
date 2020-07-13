param (
    [string] $aPostgrePassword = (property PGPASSWORD test),
    [int]    $aPerfLength = 60,
    [int]    $aTodosCount = (property ATODOSCOUNT 100000)
)

#Synopsis: Install postgresql12 postgrerest and superbenchmarker via chocolatey
task Deps {
    if (!(Get-Command choco -ea 0)) { throw "Chocolatey installation is required: Run: iwr https://chocolatey.org/install.ps1 | iex" }
    choco install postgresql12 --params '/Password:test'
    choco install postgrerest --version 7.0.1
    choco install superbenchmarker
    Write-Host "Restart shell"
}

#Synopsis: Recreate database using db.sql. Pass aTodosCount to specify number of todo items to seed (default 100K)
task RecreateDb {
    $Env:PGPASSWORD = $aPostgrePassword
    Get-Content .\db.sql -Raw | Expand-PoshString | psql -Upostgres
}

#Synopsis: Run postgrest backend
task Run {
    $cmd = "C:\postgrest\postgrest.exe postgrest.conf"
    $cmdTitle = 'postgrest server'

    start 'cmd.exe' -ArgumentList "/D /C title $cmdTitle & $cmd"
}

#Synopsis: Get 50 todo items with random offset
task Todos {
    Invoke-RestMethod "http://localhost:3000/todos?limit=50&offset=$(Get-Random $aTodosCount)" -Headers @{ Prefer = "count=planned" }
}

#Synopsis: Get single todo item with random id
task Todo {
    Invoke-RestMethod "http://localhost:3000/todos?id=eq.$(Get-Random $aTodosCount)"  | Out-String
}

#Synopsis: Start perf test with limit set to 50 todo items and random offset
task PerfTestBulk {
    sb -c 10 -N $aPerfLength  -u "http://localhost:3000/todos?limit=50&offset={{{offset:RAND_INTEGER:[1:$aTodosCount]}}}" -t sb_headers.txt
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