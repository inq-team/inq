class AddEolToModels < ActiveRecord::Migration
        def self.up
                add_column :models, :eol, :boolean, :default => false
        end
        def self.down
                remove_column :models, :eol
        end
end
