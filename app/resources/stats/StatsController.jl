module StatsController

using SearchLight, Stats
using Dashboard

function search(pkg_names, regions, startdate, enddate)
    isempty(pkg_names) || isempty(regions) && return

    pkg_names = map(pkg_names) do pkg
        (endswith(pkg, ".jl") ? pkg[1:end-3] : pkg) |> lowercase
    end

    where_filters = SQLWhereEntity[
        SQLWhereExpression("lower(package_name) IN ( $(repeat("?,", length(pkg_names))[1:end-1] ) )", pkg_names),
        SQLWhereExpression("date >= ? AND date <= ?", startdate, enddate)
    ]

    Dashboard.ALL_REGIONS in regions || push!(where_filters, SQLWhereExpression("region IN ( $(repeat("?,", length(regions))[1:end-1] ) )", regions))

    SearchLight.find(Stat, where_filters)
end

end
