class AddSimpleModeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :simple_mode, :boolean, default: true, null: false
  end
end
