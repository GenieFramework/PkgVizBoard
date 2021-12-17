using DashboardController

using Genie, Stipple, StippleUI, StipplePlotly

#=== config ==#

# for m in [Genie, Stipple, StippleUI, StipplePlotly]
#   m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
# end

#== server ==#

route("/", DashboardController.dashboard)