class AddAlertsReadAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :alerts_read_at, :datetime
  end
end
