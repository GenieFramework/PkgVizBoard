module S3DBTask

using Genie
using GZip, CSV, Dates
using SearchLight
using Logging

using PkgVizBoard
using PkgVizBoard.Packages
using PkgVizBoard.Stats

SearchLight.config.log_level = Logging.Error

const STATS_URL = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests_by_region_by_date.csv.gz"
const CSV_NAME = "package_requests_by_region_by_date.csv"

"""
Return max date that exists in database
"""
function maxdate()
  maxdate = first(SearchLight.query("SELECT MAX(date) AS maxdate from stats").maxdate)

  ismissing(maxdate) ? Dates.today() - Dates.Year(1) : Date(maxdate)
end

"""
Populate the database from CSV stats file
"""
function dbdump(cachedir::String)
  max_date_in_db = maxdate()

  for row in CSV.Rows(joinpath("$(cachedir)/", "$(CSV_NAME)"))
    rowdate = Date(row.date)

    rowdate < max_date_in_db && continue
    (ismissing(row.client_type) || row.client_type != "user") && continue

    package = findone(Package, uuid = row.package_uuid)
    (isnothing(package) || endswith(package.name, "_jll")) && continue

    m = Stat(
      package_uuid = row.package_uuid,
      package_name = package.name,
      status = parse(Int, row.status),
      region = row.region,
      date = rowdate,
      request_count = parse(Int, row.request_count),
      year = Year(rowdate).value,
      month = string(rowdate)[1:7],
    )

    SearchLight.update_or_create(
      m,
      package_uuid = row.package_uuid,
      region = row.region,
      date = rowdate,
      skip_update = true
    )
  end

end

"""
unzip, delete original file
Place in root/db/data/
"""
function unzip(cachedir::String)
  try
    gz_data = readdir(cachedir)

    GZip.open("$(cachedir)/$(gz_data[1])", "rb") do f_in
      stream = read(f_in)
      write("$(cachedir)/$(chop(gz_data[1], tail=3))", stream)
    end
  catch ex
    @error ex
    rethrow(ex)
  end
end

"""
Downloads S3 files to local disk.
Populate the database from CSV file
"""
function runtask()
  mktempdir() do directory
    @info "Path of directory" directory
    # download stats file
    download(STATS_URL, "$(directory)/$(basename(STATS_URL))")

    # unzip file
    unzip(directory)

    # dump to database
    dbdump(directory)
  end
end

end
