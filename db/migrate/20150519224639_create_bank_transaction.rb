class CreateBankTransaction < ActiveRecord::Migration
  def change
    create_table :bank_transactions do |t|
      t.references :from_account, null: true
      t.references :to_account, null: true
      t.monetize :amount
    end
    
     add_foreign_key :bank_transactions, :characters, column: :from_account_id
     add_foreign_key :bank_transactions, :characters, column: :to_account_id
  end
end