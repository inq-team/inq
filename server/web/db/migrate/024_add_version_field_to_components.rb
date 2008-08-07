class AddVersionFieldToComponents < ActiveRecord::Migration
	def self.up
		add_column :components, :version, :string, :limit => 256
	end

	def self.down
		remove_column :components, :version
	end
end
