module DashboardController

using Genie, Stipple, StippleUI, StipplePlotly
using Genie.Renderers.Html

using PkgVizBoard
using PkgVizBoard.Dashboard

function dashboard()
  html(:dashboard, "dashboard.jl", model = PkgVizBoard.Dashboard.factory(), context = @__MODULE__)
end

end