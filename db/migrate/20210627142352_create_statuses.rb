class CreateStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :statuses do |t|
      t.string :key
      t.string :name

      t.timestamps
    end
  end
end
