using PackageCompiler

PackageCompiler.create_sysimage(
  [
    "CSV",
    "DataFrames",
    "Dates",
    "FileIO",
    "GLM",
    "GZip",
    "Genie",
    "HTTP",
    "Humanize",
    "Inflector",
    "Logging",
    "LoggingExtras",
    "OrderedCollections",
    "SearchLight",
    "SearchLightSQLite",
    # "Stipple",
    # "StipplePlotly",
    # "StippleUI",
    "TOML"
  ],
  sysimage_path = "compiled/sysimg.so",
  precompile_execution_file = "compiled/precompile.jl"
)