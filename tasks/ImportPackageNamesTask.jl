module ImportPackageNamesTask

import ..PkgVizBoard as pvb

"""
Reads the package names from Julia's registry and imports them into the database.
"""
function runtask()
  pvb.Packages.insertnames()
end

end
