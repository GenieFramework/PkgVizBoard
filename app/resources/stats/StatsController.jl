module StatsController

using Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, Stats

function search_by_package_name(pkg_name::String)
    # TODO: Loop find with ["Genie", "Stipple"] and multiple comma separated values
    SearchLight.find(Stat, package_name = pkg_name)
end

function search(pkg_names, areas, startdate, enddate)
    @info pkg_names, areas, startdate, enddate

    SearchLight.find(Stat,
        SQLWhereEntity[
            SQLWhereExpression("package_name IN ( $(repeat("?,", length(pkg_names))[1:end-1] ) )", pkg_names),
            SQLWhereExpression("region IN ( $(repeat("?,", length(areas))[1:end-1] ) )", areas),
            SQLWhereExpression("date >= ? AND date <= ?", startdate, enddate)
        ]
    )
end

end
