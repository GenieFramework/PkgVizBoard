module AddAggregationColumns

import SearchLight.Transactions: with_transaction
import SearchLight.Migration: add_columns, remove_columns, add_indices, remove_indices

function up()
  with_transaction() do
    add_columns(:stats, [
      :year => :int
      :month => :string
    ])

    add_indices(:stats, [
      :year
      :month
    ])
  end
end

function down()
  with_transaction() do
    remove_indices(:stats, [
      :year
      :month
    ])

    remove_columns(:stats, [
      :year
      :month
    ])
  end
end

end
