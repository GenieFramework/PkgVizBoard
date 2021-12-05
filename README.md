# Runtask from commandline

```julia
$ bin/runtask ImportPackageNamesTask
$ bin/runtask S3DBTask
```
----
Tasks are created to run from command line. Hook up with cron jobs
## How to not run Tasks
---

```julia
julia> using Genie.Toolbox
julia> Toolbox.printtasks(PkgVizBoard)
julia> PkgVizBoard.S3DownloadTask.runtask()
```

