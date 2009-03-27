class AddModelComplexity < ActiveRecord::Migration
	def self.up
		add_column :models, :complexity, :integer
	end

	def self.down
		remove_columnt :models, :complexity
	end
end
