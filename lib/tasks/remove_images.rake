namespace :db do
  task remove_images: :environment do
    Gallery.destroy_all
  end
end
