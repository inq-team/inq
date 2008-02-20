class AddComputerAuditCache < ActiveRecord::Migration
	def self.up
		create_table :audits do |tab|
			tab.column 	:comparison, :blob
			tab.column 	:testing_id, :integer
			tab.column 	:confirmation, :integer
			tab.column 	:confirmation_date, :datetime
			tab.column 	:person_id, :integer
			tab.column	:comment, :text
		end
	end

	def self.down
		drop_table :audits
	end
end
