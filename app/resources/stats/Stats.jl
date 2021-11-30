module Stats

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Stat

@kwdef mutable struct Stat <: AbstractModel
  id::DbId = DbId()
  package_uuid::String = ""
  status::Int = 0
  region::String = ""
  date::String = ""
  request_count::Int = 0
end

end
