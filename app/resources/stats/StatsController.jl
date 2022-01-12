module StatsController

module API

module V1

using Dashboard, Packages, Stats
using Genie.Router, Genie.Renderers.Json, Genie.Renderers.Js, Genie.Cache
using SearchLight
using Dates


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


function badge()
  packages, regions, startdate, enddate = inputs()
  isempty(packages) && return (Json.error("Argument `packages` is required") |> json)

  package = packages[1]
  data = stats([package], regions, startdate, enddate) |> first
  total = data[package] |> values |> collect |> sum

  Dict(
    :schemaVersion => 1,
    :label => "$package downloads",
    :message => total,
    :color => "#9558B2",
    :namedLogo => "Julia"
  ) |> json
end


end # V1

end # API

end # StatsController