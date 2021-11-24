module DBOperationsTask

using SearchLight, SearchLightSQLite
using CSV

# function create db adapter dbsqlite
# Genie.Generator.db_support(dbadapter = :SQLite)

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

function populating_data()

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
  
end

end
