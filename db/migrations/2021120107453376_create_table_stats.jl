module CreateTableStats

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

function up()
  create_table(:stats) do
    [
      primary_key()
      column(:package_uuid, :string, limit = 100)
      column(:package_name, :string, limit = 100)
      column(:status, :integer)
      column(:region, :string, limit = 20)
      column(:date, :string, limit = 100)  # check for date format # unix time stamp
      column(:request_count, :integer)
    ]
  end

  add_index(:stats, :package_uuid)
  add_index(:stats, :package_name)
  add_index(:stats, :region)
  add_index(:stats, :date)
end

function down()
  drop_table(:stats)
end

end

