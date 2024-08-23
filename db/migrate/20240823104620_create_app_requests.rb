class CreateAppRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :app_requests do |t|
      t.string :request_url
      t.string :request_type
      t.string :request_params
      t.string :response_status
      t.string :response_headers
      t.string :response_info
      t.timestamps
    end
  end
end
