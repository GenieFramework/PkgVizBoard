module Stats

import SearchLight: AbstractModel, DbId
import Base: @kwdef

using Dates

export Stat

@kwdef mutable struct Stat <: AbstractModel
  id::DbId = DbId()
  package_uuid::String = ""
  package_name::String = ""
  status::Int = 0
  region::String = ""
  date::Date = ""
  request_count::Int = 0
end

end
