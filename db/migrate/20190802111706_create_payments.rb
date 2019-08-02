class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments, id: false, force: true do |t|
      t.string 'id', null: false
      t.decimal :amount
      t.string :agent_id
      t.string :ref
      

      t.timestamps
    end
  end
end