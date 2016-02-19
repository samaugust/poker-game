class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :deck
      t.string :community_cards
      t.float :pot

      t.timestamps null: false
    end
  end
end
