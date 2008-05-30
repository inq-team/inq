class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :display_name,              :string
      t.column :given_name,                :string
      t.column :last_login_at,             :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
