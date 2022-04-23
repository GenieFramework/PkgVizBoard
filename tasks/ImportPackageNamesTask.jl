module ImportPackageNamesTask

import PkgVizBoard

"""
Reads the package names from Julia's registry and imports them into the database.
"""
function runtask()
  PkgVizBoard.Packages.insertnames()
end

end
