using Genie
Genie.loadapp(pwd())

include("packages.jl")
using PrecompileSignatures

for p in PACKAGES
  @show "Precompiling signatures for $p"
  Core.eval(@__MODULE__, Meta.parse("import $p"))
  Core.eval(@__MODULE__, Meta.parse("@precompile_signatures($p)"))
end

import HTTP

@info "Hitting routes"
Genie.Router.params!(:packages, "Genie,Stipple")
for r in Genie.Router.routes()
  try
    r.action()
  catch
  end
end

const PORT = 50515

try
  @info "Starting server"
  up(PORT)
catch
end

try
  @info "Making requests"
  @time HTTP.request("GET", "http://localhost:$PORT/?packages=Genie,Stipple")
  @time HTTP.request("GET", "http://localhost:$PORT/api/v1/regions")
  @time HTTP.request("GET", "http://localhost:$PORT/api/v1/packages")
  @time HTTP.request("GET", "http://localhost:$PORT/api/v1/stats?packages=Genie,Stipple")
  @time HTTP.request("GET", "http://localhost:$PORT/api/v1/badge/Genie")
  @time HTTP.request("GET", "http://localhost:$PORT/api/v1/badge/Genie/color:blue")
catch
end

try
  @info "Stopping server"
  Genie.Server.down!()
catch
end

