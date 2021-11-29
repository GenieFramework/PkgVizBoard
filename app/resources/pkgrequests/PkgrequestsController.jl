module PkgrequestsController

using Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, Pkgrequests

function pkgrequests_api()
    json(:pkgrequests, :pkgrequestsview, pkgrequests = all(Pkgrequest))
end

end