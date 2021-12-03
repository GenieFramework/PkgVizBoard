module StatsController

using Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, Stats

function search_by_package_name(pkg_name::String)
    # TODO: Loop find with ["Genie", "Stipple"] and multiple comma separated values
    SearchLight.find(Stat, package_name = pkg_name)
end

function search(pkg_name::String, region::String, startdate, enddate)
    @info pkg_name, region, startdate, enddate
    SearchLight.find(Stat, 
    SQLWhereExpression("package_name = ? AND region = ? AND date BETWEEN ? and ?", 
    pkg_name, 
    region,
    startdate,
    enddate))
end

end