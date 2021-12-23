module AddPackageNameJSONTask

using Packages
using SearchLight, SearchLightSQLite, JSON, DataFrames

function df2json(df::DataFrame)
    len = length(df[:,1])
    indices = names(df)
    jsonarray = [Dict([string(index) => (ismissing(df[!, index][i]) ? nothing : df[!, index][i])
                       for index in indices])
                 for i in 1:len]
    return JSON.json(jsonarray)
end
  
function writejson(path::String,df::DataFrame)
    f = tempname();
    write(f,df2json(df))
    @info f
    
    open(f, "r") do io
        pkg_arr = String[]
        data = read(io, String)
        parsed_data =  JSON.parse(data)
        for i in parsed_data
            push!(pkg_arr, i["name"])
        end

        @info pkg_arr
        
        write("public/js/packages.js", "let packages = $(pkg_arr)")
    end
end

"""
Reads the package names from Julia's registry and imports them into the database.
"""
function runtask()
  # read packages_names from db that are unique
  package_name_df = SearchLight.query("SELECT DISTINCT packages.name FROM packages")
  
  # write json to file
  writejson("public/packages.json",package_name_df); 
end

end