class AddQueueMigrationToDev < ActiveRecord::Migration[8.0]
  def up
    if Rails.env.development?
      load File.expand_path("../../queue_schema.rb", __FILE__)
    end
  end

  def down
  end
end
