module DBOperationsTask

using SearchLight, SearchLightSQLite
using CSV
using Pkgrequests

# function create db adapter dbsqlite
# Genie.Generator.db_support(dbadapter = :SQLite)

Base.convert(::Type{String}, _::Missing) = ""
Base.convert(::Type{Int}, _::Missing) = 0
Base.convert(::Type{Int}, s::String) = parse(Int, s)

#

function configure_and_connect()
  # Change configuration for SQLite use
  chmod("db/connection.yml", 0o777);
  write("db/connection.yml", """env: ENV["GENIE_ENV"]

  dev:
    adapter: SQLite
    database: db/pkgrequest.sqlite
    config:""");

  include(joinpath("config", "initializers", "searchlight.jl"))


  # Configure the database
  SearchLight.Configuration.load()

  # Connect to the database
  SearchLight.Configuration.load() |> SearchLight.connect

  # Showing connections
  printstyled("Showing connections: "; color= :green)
  SearchLightSQLite.CONNECTIONS
end

function create_table()
  # table functionality
  SearchLight.Migrations.create_migrations_table()

end

# Generate Pkgrequest resource
function gen_resource()
  SearchLight.Generator.newresource("Pkgrequest")
end

# running migrations
function run_migrations()
  SearchLight.Migrations.status()
  SearchLight.Migrations.last_up()
  SearchLight.Migrations.status()
end

function populating_data()
  for row in CSV.Rows(joinpath("$(pwd())/db/data/", "package_requests_by_region_by_date.csv"))
    m = Pkgrequest()
    
    if(!ismissing(row.client_type) && row.client_type == "user")
      m.package_uuid = row.package_uuid
      m.status = parse(Int, row.status)
      m.client_type = row.client_type
      m.region = row.region
      m.date = row.date
      m.request_addrs = parse(Int, row.request_addrs)
      m.request_count = parse(Int, row.request_count)
      m.cache_misses = parse(Int, row.cache_misses)
      m.body_bytes_sent = parse(Int, row.body_bytes_sent)
      m.request_time = row.request_time
      save(m)
    end
  end
end

function drop_columns()
  # BEGIN TRANSACTION;
  # CREATE TEMPORARY TABLE pkgrequests_backup(id, package_uuid, status, region, date, request_count);
  # INSERT INTO pkgrequests_backup SELECT id, package_uuid, status, region, date, request_count FROM pkgrequests;
  # DROP TABLE pkgrequests;
  # CREATE TABLE pkgrequests(id, package_uuid, status, region, date, request_count);
  # INSERT INTO pkgrequests SELECT id, package_uuid, status, region, date, request_count FROM pkgrequests_backup;
  # DROP TABLE pkgrequests_backup;
  # COMMIT;
end

function select_genie_data(package_uuid)
  # SELECT date, package_uuid, status, region, request_count from pkgrequests GROUP by id HAVING  status=200 AND package_uuid = "c43c736e-a2d1-11e8-161f-af95117fbd1e"
end


"""
Total Genie requests with status 200: 498
Total Genie requests with status 400: 532
"""
function find_total_requests(package_uuid)
  # SELECT COUNT(request_count) from pkgrequests WHERE package_uuid = "c43c736e-a2d1-11e8-161f-af95117fbd1e"
end


"""
Create table, dump ddata, load data, drop table etc
"""
function runtask()
  # configure and connect to database
  # configure_and_connect()

  # create table
  #create_table()

  # generate resource
  #gen_resource()
  populating_data()
end

end
