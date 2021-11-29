module AddEnabledToEndpoints

import SearchLight.Migration: add_column, remove_column

function up()
  add_column(:endpoints, :enabled, :bool)
end

function down()
  remove_column(:endpoints, :enabled)
end

end
