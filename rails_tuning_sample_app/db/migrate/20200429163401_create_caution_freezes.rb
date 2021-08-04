class CreateCautionFreezes < ActiveRecord::Migration[6.0]
  def change
    create_table :caution_freezes do |t|
      t.references :user_caution, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
