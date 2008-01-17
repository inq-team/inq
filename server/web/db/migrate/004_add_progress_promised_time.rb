class AddProgressPromisedTime < ActiveRecord::Migration
	def self.up
		add_column :testings, 'progress_promised_time', :integer, :null => true
	end

	def self.down
		remove_column :testings, 'progress_promised_time'
	end
end
