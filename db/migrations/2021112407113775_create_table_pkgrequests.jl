module CreateTablePkgrequests

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

function up()
  create_table(:pkgrequests) do
    [
      primary_key()
      column(:package_uuid, :string, limit = 100)
      column(:status, :integer, limit = 4)
      column(:client_type, :string, limit = 10)
      column(:region, :string, limit = 20)
      column(:date, :string, limit = 100)  # check for date format # unix time stamp 
      column(:request_addrs, :integer, limit = 20)
      column(:request_count, :integer, limit = 20)
      column(:cache_misses, :integer, limit = 20)
      column(:body_bytes_sent, :integer, limit = 20)
      column(:request_time, :string, limit = 20)
    ]
  end

  add_index(:pkgrequests, :package_uuid)
  add_index(:pkgrequests, :region)
  add_index(:pkgrequests, :date)
end

function down()
  drop_table(:pkgrequests)
end

end



#"package_uuid","status","client_type","region","date",
#"request_addrs","request_count","cache_misses","body_bytes_sent","request_time"
