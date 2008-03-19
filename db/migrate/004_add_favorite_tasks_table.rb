class AddFavoriteTasksTable < ActiveRecord::Migration
  def self.up
    create_table :favorite_tasks, :id => false do |t|
      t.integer :user_id, :task_id
    end
  end

  def self.down
    drop_table :favorite_tasks
  end
end
