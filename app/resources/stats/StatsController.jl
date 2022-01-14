module StatsController

module API

module V1

using Dashboard, Packages, Stats
using Genie.Router, Genie.Renderers.Json, Genie.Cache
using SearchLight
using Dates
using Humanize


function __init__()
  Cache.init()
end


function inputs()
  packages = split(params(:packages, ""), ',', keepempty = false)
  regions = split(params(:regions, Dashboard.ALL_REGIONS), ',', keepempty = false)
  startdate = Dates.format(params(:startdate, today() - Month(1)) |> Date, "yyyy-mm-dd")
  enddate = Dates.format(params(:enddate, today()) |> Date, "yyyy-mm-dd")

  packages, regions, startdate, enddate
end


stats(args...) = Dashboard.stats(Stats.search(args...))


function search()
  packages, regions, startdate, enddate = inputs()

  (:stats => Dict(
    :request => Dict(
      :packages => packages,
      :regions => regions,
      :startdate => startdate,
      :enddate => enddate
    ),
    :response => stats(packages, regions, startdate, enddate)
  )) |> json
end


function regions()
  (:regions => Dashboard.REGIONS) |> json
end


function packages()
  withcache(:packages, 24 * 60 * 60) do # 24h cache
    (:packages => all(Package, order = "name")) |> json
  end
end


function parseoptions(options)
  result = Dict{Symbol,String}()

  isempty(options) && return result

  try
    opts = split(options, '-', keepempty = false)
    for opt in opts
      key, value = split(opt, ':', keepempty = true)
      result[Symbol(key)] = value
    end
  catch ex
    @error ex
    return result
  end

  result
end


function badge()
  packages, regions, startdate, enddate = inputs()
  isempty(packages) && return (Json.error("Argument `packages` is required") |> json)

  options = parseoptions(params(:options, ""))
  label = get(options, :label, "downloads")
  sep = get(options, :sep, "")
  color = get(options, :color, "blueviolet")
  logo = get(options, :logo, "Julia")

  package = packages[1]
  withcache(string(package, label, sep, color, logo), 24 * 60 * 60) do # 24h cache
    data = stats([package], [Dashboard.ALL_REGIONS], Date("2021-09-01"), today) |> first
    total = data[package] |> values |> collect |> sum

    Dict(
      :schemaVersion => 1,
      :label => "$package $label",
      :message => "$(Humanize.digitsep(total, seperator = sep))",
      :color => color,
      :namedLogo => logo
    ) |> json
  end
end


end # V1

end # API

end # StatsController