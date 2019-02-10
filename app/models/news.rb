class News < ActiveRecord::Base
  default_scope { order(created_at: :asc) }
  attr_accessible :news_header, :short_text, :text, :photo, :news_date
  validates :news_header, :short_text, :text, :news_date, presence: true
end
