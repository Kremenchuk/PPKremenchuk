class News < ActiveRecord::Base

  default_scope { order(date: :desc) }

  default_scope { order(created_at: :asc) }
  validates :title, :short_text, :text, :news_date, :photo, presence: true
end
