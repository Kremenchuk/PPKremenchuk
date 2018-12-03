class News < ActiveRecord::Base
  default_scope { order(created_at: :asc) }
  attr_accessible :news_header, :short_text, :text, :photo
  validates :news_header, :short_text, :text, presence: true
end
