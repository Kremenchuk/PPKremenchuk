class RemoveImages < ActiveRecord::Migration[7.0]
  def change
    Gallery.destroy_all
  end
end
