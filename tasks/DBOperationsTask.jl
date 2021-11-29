module DBOperationsTask

using SearchLight, SearchLightSQLite
using CSV

Base.convert(::Type{String}, _::Missing) = ""
Base.convert(::Type{Int}, _::Missing) = 0
Base.convert(::Type{Int}, s::String) = parse(Int, s)


# function populate_stats()
#   for row in CSV.Rows(joinpath("$(pwd())", "$(CSV_PATH)", "package_requests_by_region_by_date.csv"))
#     m = Pkgrequest()
    
#     if(!ismissing(row.client_type) && row.client_type == "user")
#       m.package_uuid = row.package_uuid
#       m.status = parse(Int, row.status)
#       m.region = row.region
#       m.date = row.date
#       m.request_count = parse(Int, row.request_count)
#       save(m)
#     end
#   end
# end

"""
Create table, dump ddata, load data, drop table etc
"""
function runtask()
  #populating_data()
end

end
