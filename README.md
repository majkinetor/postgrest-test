# Postgrest Windows test

This repository contains basic setup and test for Postgrest.

## Usage

The repository uses embedded invoke-build. You can call it directly using `./Invoke-Build.ps1`. Its easier to setup alias: `Set-Alias ib $pwd\Invoke-Build.ps1`

To get list of all tasks run `ib ?`:

```
> ib ?

Name           Jobs Synopsis
----           ---- --------
Deps           {}   Install postgresql12 postgrerest and superbenchmarker via chocolatey
RecreateDb     {}   Recreate database using db.sql. Pass aTodosCount to specify number of todo items to seed (default 100K)
Run            {}   Run postgrest backend
Todos          {}   Get 50 todo items with random offset
Todo           {}   Get single todo item with random id
PerfTestBulk   {}   Start perf test with limit set to 50 todo items and random offset
PerfTestSingle {}   Start perf test with single random todo item
```

## Quick start

1. Install local dependencies before first run: in administrative shell run: `ib Deps`<br>
This will install postgresql (with password `test`), postgrest & superbenchmarker via chocolatey.
2. Create database with: `ib RecreateDatabase`.<br>
Modify number of created todo items via `-aTodosCount` argument - by default 100K records are randomly created.
1. Start backend with `ib Run`.
2. Test with `ib Todo` (gets single random todo item) or `ib Todos` (gets bulk todo's)