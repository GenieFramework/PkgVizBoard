using Genie.Router
using PkgrequestsController

route("/") do
  serve_static_file("welcome.html")
end

route("/data", PkgrequestsController.pkgrequests_api)