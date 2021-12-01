module ImportPackageNamesTask

using Packages

"""
Reads the package names from Julia's registry and imports them into the database.
"""
function runtask()
  Packages.insertnames()
end

end
