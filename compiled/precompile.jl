using Genie
Genie.loadapp(pwd())

import HTTP

@info "Hitting routes"
params() # to force initialize the params collection
Genie.Router.params!(:packages, "Genie,Stipple")
for r in Genie.Router.routes()
  try
    r.action()
  catch
  end
end

try
  @info "Starting server"
  up()
catch
end

try
  @info "Making requests"
  HTTP.request("GET", "http://localhost:8000/?packages=Genie,Stipple")
  HTTP.request("GET", "http://localhost:8000/api/v1/regions")
  HTTP.request("GET", "http://localhost:8000/api/v1/packages")
  HTTP.request("GET", "http://localhost:8000/api/v1/stats?packages=Genie,Stipple")
  HTTP.request("GET", "http://localhost:8000/api/v1/badge/Genie")
  HTTP.request("GET", "http://localhost:8000/api/v1/badge/Genie/color:blue")
catch
end

try
  @info "Stopping server"
  Genie.Server.down!()
catch
end

