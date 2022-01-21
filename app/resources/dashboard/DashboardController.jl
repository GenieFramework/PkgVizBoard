module DashboardController

using Genie, Stipple, StippleUI, StipplePlotly
using Genie.Renderers.Html
using Dashboard

function dashboard()
  html(:dashboard, "dashboard.jl", model = Dashboard.factory(), context = @__MODULE__)
end

end