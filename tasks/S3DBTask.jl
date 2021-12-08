module S3DBTask

using Genie
using GZip, CSV, Dates
using SearchLight, SearchLightSQLite, Stats, Packages

const STATS_URL = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests_by_region_by_date.csv.gz"
const CSV_NAME = "package_requests_by_region_by_date.csv"

"""
return max date that exists in database
"""
function maxdate()
  maxdate_db = first(SearchLight.query("SELECT MAX(date) AS MaxDate from stats").MaxDate)
  return ismissing(maxdate_db) ? Dates.today() : Date(maxdate_db)
end

"""
populate the database from CSV stats file
"""
function dbdump(cachedir::String)
  max_date_in_db = maxdate()
  
  for row in CSV.Rows(joinpath("$(cachedir)/", "$(CSV_NAME)"))
    if(Date(row.date) > max_date_in_db)
      if(!ismissing(row.client_type) && !isnothing(findone(Package, uuid = "$(row.package_uuid)"))
        && !endswith(findone(Package, uuid = "$(row.package_uuid)").name, "_jll") && row.client_type == "user")
        m = Stat()
        m.package_uuid = row.package_uuid
        m.package_name = findone(Package, uuid = "$(row.package_uuid)").name
        m.status = parse(Int, row.status)
        m.region = row.region
        m.date = Date(row.date)
        m.request_count = parse(Int, row.request_count)

        SearchLight.update_or_create(
          m, 
          package_uuid = row.package_uuid,
          region = row.region,
          date = Date(row.date),
          skip_update = true
        )
      end
    end
  end

end

function check_table_empty()

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
  catch
    @warn "uzip failed."
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
