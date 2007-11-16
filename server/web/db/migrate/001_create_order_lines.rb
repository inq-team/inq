class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
    end
  end

  def self.down
    drop_table :order_lines
  end
end
