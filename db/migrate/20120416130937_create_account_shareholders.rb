class CreateAccountShareholders < ActiveRecord::Migration
  def self.up
    create_table :account_shareholders, :force => true do |t|
      t.references :account
      t.references :shareholder
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :account_shareholders
  end
end
