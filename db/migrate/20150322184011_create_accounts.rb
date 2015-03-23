class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.float :amount
      t.boolean :lock
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
