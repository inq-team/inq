class AddCommentPerson < ActiveRecord::Migration
	def self.up
		add_column :computer_stages, :comment_by,    :integer
		add_index  :computer_stages, ['comment_by'], :name => 'comment_by'
		add_column :order_stages,    :comment_by,    :integer
		add_index  :order_stages,    ['comment_by'], :name => 'comment_by'
	end

	def self.down
		remove_column :computer_stages, :comment_by
#		remove_index  :computer_stages, :name => 'comment_by'
		remove_column :order_stages,    :comment_by
#		remove_index  :order_stages,    :name => 'comment_by'
	end
end
