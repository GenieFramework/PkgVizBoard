module S3DBTask

using Genie
using GZip, CSV, CSVFiles, DataFrames
using SearchLight, SearchLightSQLite, Stats

const STATS_URL = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests_by_region_by_date.csv.gz"
const CSV_NAME = "package_requests_by_region_by_date.csv"

"""
populate the database from CSV stats file
"""
function dbdump(cachedir::String)
  for row in CSV.Rows(joinpath("$(cachedir)/", "$(CSV_NAME)"))
    m = Stat()
    
    if(!ismissing(row.client_type) && row.client_type == "user")
      m.package_uuid = row.package_uuid
      m.status = parse(Int, row.status)
      m.region = row.region
      m.date = row.date
      m.request_count = parse(Int, row.request_count)
      SearchLight.save(m)
    end
  end
end

"""
unzip, delete original file
Place in root/db/data/
"""
function unzip(cachedir::String)
  gz_data = readdir(cachedir)
  f_in = GZip.open("$(cachedir)/$(gz_data[1])", "rb")
  stream = read(f_in)
  write("$(cachedir)/$(chop(gz_data[1], tail=3))", stream)
  close(f_in)
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
