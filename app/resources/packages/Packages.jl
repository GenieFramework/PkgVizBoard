module Packages

using HTTP, TOML
using SearchLight

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Package

@kwdef mutable struct Package <: AbstractModel
  id::DbId = DbId()
  uuid::String = ""
  name::String = ""
end

const PKGLISTURL = "https://raw.githubusercontent.com/JuliaRegistries/General/master/Registry.toml"

function getpackagelist() :: Dict{String,Any}
  ((HTTP.get(PKGLISTURL).body |> String) |> TOML.parse)["packages"]
end

function insertnames()
  for (uuid, pkginfo) in getpackagelist()
    SearchLight.update_or_create(Package(uuid = uuid, name = pkginfo["name"]), uuid = uuid)
  end
end

end
