class Article < ActiveRecord::Base

  default_scope { order(created_at: :asc) }

  validates :title, :body, :short_body, presence: true
end
