using DashboardController, StatsController
using Genie, Stipple, StippleUI, StipplePlotly

#=== config ==#

if Genie.Configuration.isprod()
  for m in [Genie, Stipple, StippleUI, StipplePlotly]
    m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
  end
end

#== server ==#

route("/", DashboardController.dashboard)

route("/api/v1/regions", StatsController.API.V1.regions, method = GET)
route("/api/v1/packages", StatsController.API.V1.packages, method = GET)
[route("/api/v1/stats", StatsController.API.V1.search, method = m) for m in [GET, POST]]
route("/api/v1/badge/:packages", StatsController.API.V1.badge, method = GET)
route("/api/v1/badge/:packages/:options", StatsController.API.V1.badge, method = GET, named = :get_api_v1_badge_packages_options)