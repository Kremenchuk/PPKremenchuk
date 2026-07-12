class DropContacts < ActiveRecord::Migration[7.2]
  def up
    drop_table :contacts, if_exists: true
  end

  def down
    create_table(:contacts) do |t|
      t.string :name
      t.string :text
    end
  end
end
