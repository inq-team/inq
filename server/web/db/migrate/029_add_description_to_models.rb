class AddDescriptionToModels < ActiveRecord::Migration
        def self.up
                add_column :models, :description, :string
        end
        def self.down
                remove_column :models, :description
        end
end
