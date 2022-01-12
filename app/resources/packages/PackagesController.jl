module PackagesController

using SearchLight, Genie.Renderers.Js, Genie.Cache
using Packages, Dashboard

function packagenames()
  withcache("pkgnames", 24 * 60 * 60) do # 24 hours
    pkgnames = [pkgname.name for pkgname in all(Package)]
    "const packageList = $pkgnames" |> js
  end
end

end