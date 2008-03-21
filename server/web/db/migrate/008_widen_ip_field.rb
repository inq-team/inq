class WidenIpField < ActiveRecord::Migration
	def self.up
		change_column(:computers, :ip, :string, :limit => 20)
	end

	def self.down
		change_column(:computers, :ip, :string, :limit => 15)
	end
end
