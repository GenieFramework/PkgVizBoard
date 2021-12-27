module AutoSearchPackageNamesTask

using Packages
using SearchLight, SearchLightSQLite, JSON, DataFrames

const PACKAGE_PATH = "public/js/packages.js"

function df2json(df::DataFrame)
	len = length(df[:,1])
	indices = names(df)
	jsonarray = [Dict([string(index) => (ismissing(df[!, index][i]) ? nothing : df[!, index][i])
							for index in indices]) for i in 1:len]
	return JSON.json(jsonarray)
end
  
function writejson(path::String,df::DataFrame)
	try
		open(path, "w") do io
			pkg_arr = String[]
			parsed_data = JSON.parse(df2json(df))
			for pkg in parsed_data
					push!(pkg_arr, pkg["name"])
			end
			write(path, "let packageList = $(pkg_arr)")
		end
	catch ex
		@error ex
		rethrow(ex)
	end
end

"""
Reads the package names from packages db and populate packages.js in public/js
"""
function runtask()
  # read packages_names from db that are unique
  package_names_df = SearchLight.query("SELECT DISTINCT packages.name FROM packages")
  
  # write json to file
  writejson(PACKAGE_PATH ,package_names_df); 
end

end