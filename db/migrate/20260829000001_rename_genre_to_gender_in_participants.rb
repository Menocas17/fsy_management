class RenameGenreToGenderInParticipants < ActiveRecord::Migration[8.1]
  def change
    rename_column :participants, :genre, :gender
  end
end
