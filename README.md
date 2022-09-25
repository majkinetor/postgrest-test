# Postgrest Windows test

This repository contains basic setup and test for [Postgrest](https://github.com/PostgREST/postgrest). All dependencies are automatically installed, database is automatically created so you can start testing and tweaking in minutes.

## Usage

The repository uses embedded [Invoke-Build](https://github.com/nightroman/Invoke-Build) to run tasks.

To get list of all tasks run with `?`:

```
> ./Invoke-Build.ps1 ?

Name           Jobs Synopsis
----           ---- --------
Deps           {}   Install postgresql14, postgrerest 10, and latest superbenchmarker via chocolatey
RecreateDb     {}   Recreate database using db.sql. Pass aTodosCount to specify number of todo items to seed (default 100K)
Run            {}   Run postgrest backend
RunSandboxed   {}   Run inside Windows Sandbox
Todos          {}   Get 50 todo items with random offset
Todo           {}   Get single todo item with random id
PerfTestBulk   {}   Start perf test with limit set to 50 todo items and random offset
PerfTestBulk2  {}   Start perf test with limit set to 50 todo items and random offset (alternative)
PerfTestSingle {}   Start perf test with single random todo item
```

## Quick start

1. Open administrative shell in repository root and type: `Set-Alias ib $pwd\Invoke-Build.ps1`
2. Install local dependencies only on first run: `ib Deps`<br>
This will install postgresql (with password `test`), postgrest & superbenchmarker via chocolatey. If you use existing installation specify password with `$Env:PGPASSWORD`.
2. Create database with: `ib RecreateDb`.<br>
Modify number of created todo items via `-aTodosCount` argument - by default 100K records are randomly created.
1. Start backend with `ib Run`.
2. Test with `ib Todo` (gets single random todo item) or `ib Todos` (gets bulk todo's)


## Run in Windows Sandbox

Run everything in [Windows Sandbox](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview) using the following command:

```ps1
ib RunSandboxed
```

which executes the following script inside VM:

```ps1
cd postgrest-test
Set-Alias ib $pwd\Invoke-Build.ps1
ib Deps, RecreateDb, Run, Todo, Todos
```

![screenshot](screenshot.png)

## Notes

- [postgrest-benchmark](https://github.com/steve-chavez/postgrest-benchmark)<br>
Another benchmark, using NixOs and K6
