class CreateProductionOrders < ActiveRecord::Migration
  def change
    create_table :production_orders do |t|
      t.integer :state
      t.string :code
      t.references :kanban, index: true

      t.timestamps
    end
  end
end