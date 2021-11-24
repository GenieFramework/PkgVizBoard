module Pkgrequests

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Pkgrequest

@kwdef mutable struct Pkgrequest <: AbstractModel
  id::DbId = DbId()
  package_uuid::String = ""
  status::Int = 0
  client_type::String = ""
  region::String = ""
  date::String = ""
  request_addrs::Int = 0
  request_count::Int = 0
  cache_misses::Int = 0
  body_bytes_sent::Int = 0
  request_time::String = ""
end

end
