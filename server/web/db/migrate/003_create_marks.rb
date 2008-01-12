class CreateMarks < ActiveRecord::Migration
	def self.up
		create_table :marks do |t|
			t.column 'testing_stage_id', :integer, :null => false
			t.column 'key',              :string,  :null => false, :limit => 250
			t.column 'value_float',      :double,  :null => true
			t.column 'value_str',        :text,    :null => true
		end
	end

	def self.down
		drop_table :marks
	end
end
