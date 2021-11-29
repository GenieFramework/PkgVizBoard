module S3DownloadTask

using Genie
using GZip, CSV, CSVFiles, DataFrames

const STATS_URL = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests_by_region_by_date.csv.gz"
const DATA_PATH = "db/data"
const CSV_PATH = "$(DATA_PATH)/$(basename(STATS_URL))"

"""
unzip, delete original file
Place in root/db/data/
"""
function unzip()
  printstyled("\nUnzipping Files 🤐 🤐 🤐 ... \n"; color = :blue)

  gz_data = readdir(DATA_PATH)

  printstyled("Current file: $(gz_data[1])\n"; color = :light_yellow)

  f_in = GZip.open("$(DATA_PATH)/$(gz_data[1])", "rb")
  stream = read(f_in)
  write("$(DATA_PATH)/$(chop(gz_data[1], tail=3))", stream)
  printstyled("unzipped $(gz_data[1]) | ✅  \n"; color = :magenta)
  close(f_in)
  printstyled("Finished upzippping all files", color = :light_green)
end

"""
Downloads S3 files to local disk perioidically.
"""
function runtask()
  # if directory exists
  if(isdir("$(DATA_PATH)"))
    printstyled("Data Directory 📁 already exists ❌ \n"; color = :light_red)
  else
    printstyled("Created Data Directory 📁 ====> "; color = :green)
    mkdir("$(DATA_PATH)")
    printstyled("✅ \n"; color = :green)
  end

  # downloading csv file
  printstyled("Downloading: $(STATS_URL) | ✅  \n"; color = :green)
  download(STATS_URL, CSV_PATH)
  printstyled("Finished task 🚀 🚀 🚀"; color = :yellow)
  
  # unzip csv file
  unzip()
end

end
