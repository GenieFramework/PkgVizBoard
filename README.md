Local setup:

- Download the database from [here](https://www.dropbox.com/s/3h48n0xk3gc2x1y/dev.sqlite?dl=0)
- Place the dev.sql in `db/dev.sqlite`
- In project root

```julia-repl
PkgVizBoard $ julia --project
julia> ]
pkg(1.6)> activate .
pkg(1.6)> instantiate
```

- close julia repl session

- In root of directory

```shell
PkgVizBoard $ bin/runtask ImportPackageNamesTask
PkgVizBoard $ bin/runtask S3DBTask
```

- starting the app(in project root)

```shell
PkgVizBoard $ bin/server
```

Visit http://localhost:8080/
