class CreateSoftwareComponents < ActiveRecord::Migration
	def self.up
		create_table :software_components do |t|
			t.column :testing_id, :integer
			t.column :software_component_model_id, :integer
			t.column :version, :text
		end

		create_table :software_component_models do |t|
			t.column :name, :text
			t.column :software_component_architecture_id, :integer
		end

		create_table :software_component_architectures do |t|
			t.column :name, :text
		end
	end

	def self.down
		drop_table :software_components
		drop_table :software_component_models
		drop_table :software_component_architectures
	end
end
