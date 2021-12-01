module CreateTablePackages

import SearchLight.Migrations: create_table, columns, primary_key, add_index, drop_table, add_indices

function up()
  create_table(:packages) do
    [
      primary_key()
      columns([
        :uuid => :string
        :name => :string
      ])
    ]
  end

  add_index(:packages, :uuid)
end

function down()
  drop_table(:packages)
end

end