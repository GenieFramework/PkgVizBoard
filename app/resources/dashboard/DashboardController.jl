module DashboardController

using Genie, Stipple, StippleUI, StipplePlotly
using Genie.Renderers.Html
using Dashboard
using PkgVizBoard

function dashboard()
  html(:dashboard, "dashboard.jl", model = Dashboard.factory(), context = @__MODULE__)
end

end