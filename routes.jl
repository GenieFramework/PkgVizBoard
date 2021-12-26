using DashboardController, StatsController
using Genie, Stipple, StippleUI, StipplePlotly

route("/", DashboardController.dashboard)
