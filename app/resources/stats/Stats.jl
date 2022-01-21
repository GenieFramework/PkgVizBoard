module Stats

using SearchLight
using Dashboard
using Dates

export Stat

Base.@kwdef mutable struct Stat <: AbstractModel
  id::DbId = DbId()
  package_uuid::String = ""
  package_name::String = ""
  status::Int = 0
  region::String = ""
  date::Date = ""
  request_count::Int = 0
  year::Int = 0
  month::String = ""
end


function intervalgroup(groupinterval)
  groupinterval in [Dashboard.DAY, Dashboard.MONTH, Dashboard.YEAR] || (groupinterval = Dashboard.DAY)

  if groupinterval == Dashboard.DAY
    "stats.date"
  elseif groupinterval == Dashboard.MONTH
    "stats.month"
  elseif groupinterval == Dashboard.YEAR
    "stats.year"
  else
    error("invalid group interval")
  end
end


function search(pkg_names, regions, startdate, enddate, groupinterval = Dashboard.DAY)
  isempty(pkg_names) || isempty(regions) && return

  pkg_names = map(pkg_names) do pkg
      (endswith(pkg, ".jl") ? pkg[1:end-3] : pkg) |> lowercase
  end

  where_filters = SQLWhereEntity[
      SQLWhereExpression("LOWER(package_name) IN ( $(repeat("?,", length(pkg_names))[1:end-1] ) )", pkg_names),
      SQLWhereExpression("date >= ? AND date <= ?", startdate, enddate)
  ]

  Dashboard.ALL_REGIONS in regions ||
    push!(where_filters, SQLWhereExpression("region IN ( $(repeat("?,", length(regions))[1:end-1] ) )", regions))

  SearchLight.find(Stat, SQLQuery(columns = SQLColumns(Stat, (request_count = SQLColumn("SUM(stats.request_count) AS stats_request_count", raw = true),) ),
                                  where = where_filters, order = ["stats.date"], group = ["stats.package_name", intervalgroup(groupinterval)]))
end

function search(model)
  search(model.searchterms[], model.filter_regions[], model.filter_startdate[], model.filter_enddate[], model.interval[])
end

end
