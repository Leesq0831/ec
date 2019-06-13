class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user
      t.references :chat
      t.timestamps null: false
    end
  end
end
