module StatsController

using Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, Stats

function stats()
    json(:stats, :statsview, stats = all(Stat))
end

end