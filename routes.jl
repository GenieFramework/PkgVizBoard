using DashboardController
using Genie, Stipple, StippleUI, StipplePlotly

#=== config ==#

if Genie.Configuration.isprod()
  for m in [Genie, Stipple, StippleUI, StipplePlotly]
    m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
  end
end

#== server ==#

route("/", DashboardController.dashboard)