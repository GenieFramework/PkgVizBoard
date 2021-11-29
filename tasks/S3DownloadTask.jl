module S3DownloadTask

using Genie
using GZip, CSV, CSVFiles, DataFrames

const STATS_URL = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests_by_region_by_date.csv.gz"

#csv_path = "$(temppath)/$(basename(STATS_URL))"

"""
unzip, delete original file
Place in root/db/data/
"""
function unzip(cachedir::String)
  gz_data = readdir(cachedir)
  @info "Read Directory" gz_data
  f_in = GZip.open("$(cachedir)/$(gz_data[1])", "rb")
  stream = read(f_in)
  write("$(cachedir)/$(chop(gz_data[1], tail=3))", stream)
  close(f_in)
end

"""
Downloads S3 files to local disk perioidically.
"""
function runtask()
  cachedir = Base.Filesystem.mktempdir()
  @info "Temporary directory" cachedir 

  # downloading csv file
  download(STATS_URL, "$(cachedir)/$(basename(STATS_URL))")
  
  # unzip csv file
  unzip(cachedir)
end

end
