class AddTestTypeVersionToTestingStages < ActiveRecord::Migration
	def self.up
		add_column :testing_stages, :test_type, :string, :null => false, :limit => 256
		add_column :testing_stages, :test_version, :string, :null => false, :limit => 16
	end

	def self.down
		remove_column :testing_stages, :test_type
		remove_column :testing_stages, :test_version
	end
end
