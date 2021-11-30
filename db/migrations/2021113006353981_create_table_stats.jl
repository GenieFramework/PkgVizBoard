module CreateTableStats

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

function up()
  create_table(:stats) do
    [
      primary_key()
      column(:package_uuid, :string, limit = 100)
      column(:status, :integer, limit = 4)
      column(:region, :string, limit = 20)
      column(:date, :string, limit = 100)  # check for date format # unix time stamp 
      column(:request_count, :integer, limit = 20)
    ]
  end

  add_index(:stats, :package_uuid)
end

function down()
  drop_table(:stats)
end

end
