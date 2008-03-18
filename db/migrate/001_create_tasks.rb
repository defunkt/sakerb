class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.text :body
      t.integer :views
      t.text :description
      t.integer :user_id
      t.boolean :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
