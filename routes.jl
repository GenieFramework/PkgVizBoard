using DashboardController

using Genie, Stipple, StippleUI, StipplePlotly

const assets_config = Genie.Assets.AssetsConfig(package = "PkgVizBoard")

#=== config ==#

# for m in [Genie, Stipple, StippleUI, StipplePlotly]
#   m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
# end

#== server ==#

route("/", DashboardController.dashboard)