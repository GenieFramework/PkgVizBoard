module S3DownloadTask

using Genie
using GZip, CSV, CSVFiles, DataFrames

"""
Get links to all the files in the S3 bucket
"""
function s3_urls()
  s3_url = "https://julialang-logs.s3.amazonaws.com/public_outputs/current/"
  rollup_names = ["client_types", "julia_systems", "julia_versions", "resource_types", "package_requests"]
  suffix = ["", "_by_region", "_by_date", "_by_region_by_date"]
  
  roll_up_urls = []

  for i in 1:size(rollup_names)[1]
    for j in 1:size(suffix)[1]
      push!(roll_up_urls, (s3_url * rollup_names[i] * suffix[j] * ".csv.gz"))
    end
  end

  return roll_up_urls
end

"""
download giz files periodically from urls
Place in root/db/data/
"""
function download_s3_urls(urls)
  for i in 1:size(urls)[1]
    store = joinpath(pwd(), "db/data")
    
    printstyled("Downloading: $(urls[i]) | ✅  \n"; color = :green)
    download(urls[i], joinpath(store, basename(urls[i])))
  end
end


"""
unzip, delete original file
Place in root/db/seeds/
"""
function unzip()
  printstyled("\nUnzipping Files 🤐 🤐 🤐 ... \n"; color = :blue)
  
  data_path = "db/data" #"$(Main.UserApp)/db/data" 

  gz_data = readdir(data_path)

  for file in gz_data
    f_in = GZip.open("db/data/$(file)", "rb")
    stream = read(f_in)
    write("db/seeds/$(chop(file, tail=3))", stream)
    printstyled("unzipped $(file) | ✅  \n"; color = :magenta)
    close(f_in)
  end
  
end

"""
Downloads S3 files to local disk perioidically.
"""
function runtask()
  urls = s3_urls()

  # downloading data to db/data
  download_s3_urls(urls)

  printstyled("Finished task 🚀 🚀 🚀"; color = :yellow)

  #unzipping csv files and saving to db/seeds
  unzip()
end

end
