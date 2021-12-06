module StatsController

using Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, Stats

#TODO: ask adrian if appended with with new pkg name
# should again make new separate request to only get data for
# that package instead of pulling all the data again for all packages
function search(pkg_names, areas, startdate, enddate)
    if first(pkg_names) != ""
        SearchLight.find(Stat,
            SQLWhereEntity[
                SQLWhereExpression("package_name IN ( $(repeat("?,", length(pkg_names))[1:end-1] ) )", pkg_names),
                SQLWhereExpression("region IN ( $(repeat("?,", length(areas))[1:end-1] ) )", areas),
                SQLWhereExpression("date >= ? AND date <= ?", startdate, enddate)
            ]
        )
    end
end
end
