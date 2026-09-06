class AddConfirmableToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :confirmation_token,   :string
    add_column :users, :confirmed_at,         :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # config.reconfirmable is true, so an email change is parked here until
    # the new address is confirmed
    add_column :users, :unconfirmed_email,    :string

    add_index :users, :confirmation_token, unique: true

    # Accounts that existed before confirmation was introduced stay usable.
    # Without this every current user — the admin included — would be locked
    # out on the next deploy.
    execute <<~SQL
      UPDATE users
         SET confirmed_at = '#{Time.current.utc.strftime('%Y-%m-%d %H:%M:%S')}'
       WHERE confirmed_at IS NULL
    SQL
  end

  def down
    remove_index  :users, :confirmation_token
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
  end
end
