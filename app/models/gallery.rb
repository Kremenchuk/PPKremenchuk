class Gallery < ActiveRecord::Base
  default_scope { order(horizontal: :desc) }

  def next
    Gallery.where("created_at < ?", self.created_at).where("image_folder = ?", self.image_folder).order(:time).first
  end

  def previous
    Gallery.where("created_at > ?", self.created_at).where("image_folder = ?", self.image_folder).order(time: :desc).first
  end

  def self.next_present?(id)
    Gallery.where("created_at < ?", image(id).created_at)
           .where("image_folder = ?", image(id).image_folder)
           .order(:time)
           .first
           .present?
  end

  def self.previous_present?(id)
    Gallery.where("created_at > ?", image(id).created_at)
           .where("image_folder = ?", image(id).image_folder)
           .order(time: :desc)
           .first
           .present?
  end

  private

  def self.image(id)
    Gallery.find(id)
  end
end
