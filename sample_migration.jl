module CreateTablePkgreqs

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

function up()
  create_table(:pkgreqs) do
    [
      primary_key()
      column(:package_uuid, :string, limit = 100)
      column(:status, :integer, limit = 4)
      column(:region, :string, limit = 20)
      column(:date, :string, limit = 100)  # check for date format # unix time stamp 
      column(:request_count, :integer, limit = 20)
    ]
  end

  add_index(:pkgreqs, :package_uuid)
end

function down()
  drop_table(:pkgreqs)
end

function dropcolumn()


end



#"package_uuid","status","client_type","region","date",
#"request_addrs","request_count","cache_misses","body_bytes_sent","request_time"
