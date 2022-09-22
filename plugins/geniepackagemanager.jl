using Genie
using Genie.Requests
using Genie.Renderer.Json
using GeniePackageManager

route("/geniepackagemanager", GeniePackageManager.list_packages)

route("/geniepackagemanager/add", GeniePackageManager.add, method = POST)

route("/geniepackagemanager/:package::String/remove", GeniePackageManager.remove_package, method = POST)