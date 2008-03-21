class CreateFirmwares < ActiveRecord::Migration
	def self.up
		create_table :firmwares do |t|
			t.column 'version',            :string, :null => false
			t.column 'image',              :string, :null => false
			t.column 'component_model_id', :integer,:null => false
		end
	end

	def self.down
		drop_table :firmwares
	end
end
