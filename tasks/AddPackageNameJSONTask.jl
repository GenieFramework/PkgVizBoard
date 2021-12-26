module AddPackageNameJSONTask

using Packages
using SearchLight, SearchLightSQLite, JSON, DataFrames

function df2json(df::DataFrame)
	len = length(df[:,1])
	indices = names(df)
	jsonarray = [Dict([string(index) => (ismissing(df[!, index][i]) ? nothing : df[!, index][i])
							for index in indices]) for i in 1:len]
	return JSON.json(jsonarray)
end
  
function writejson(path::String,df::DataFrame)
	try
		json_file = tempname();
		write(json_file,df2json(df))
		
		open(json_file, "r") do io
			pkg_arr = String[]
			json_data = read(io, String)
			parsed_data = JSON.parse(json_data)
			for pkg in parsed_data
					push!(pkg_arr, pkg["name"])
			end
			write(path, "let packages = $(pkg_arr)")
		end
	catch ex
		@error ex
		rethrow(ex)
	end
end

"""
Reads the package names from Julia's registry and imports them into the database.
"""
function runtask()
  # read packages_names from db that are unique
  package_name_df = SearchLight.query("SELECT DISTINCT packages.name FROM packages")
  
  # write json to file
  writejson("public/js/packages.js",package_name_df); 
end

end