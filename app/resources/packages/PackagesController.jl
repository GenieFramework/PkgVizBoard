module PackagesController

using SearchLight, JSON3
using Packages, Dashboard

function search_pkg_name(pkg_name)
    open("package_data.json", "w") do io
        JSON3.pretty(io, Packages.getpackagelist())
    end
end
