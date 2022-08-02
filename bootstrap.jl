pwd() == joinpath(@__DIR__, "bin") && cd(@__DIR__) # allow starting app from bin/ dir

using PkgVizBoard
const UserApp = PkgVizBoard
PkgVizBoard.main()
