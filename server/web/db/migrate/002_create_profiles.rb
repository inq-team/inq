class CreateProfiles < ActiveRecord::Migration
	def self.up
		create_table :profiles do |t|
			t.column 'xml',       :text,     :null => false
			t.column 'model_id' , :integer,  :null => true
			t.column 'feature',   :string,   :null => true, :limit => 64
			t.column 'timestamp', :datetime, :null => false
		end
	end

	def self.down
		drop_table :profiles
	end
end
