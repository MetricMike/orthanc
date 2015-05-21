class CreateBankAccount < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :owner, index: true
      t.monetize :balance, amount: { default: 10 }
      t.monetize :line_of_credit, amount: { default: 5 }
    end

    add_foreign_key :bank_accounts, :characters, column: :owner_id
  end
end