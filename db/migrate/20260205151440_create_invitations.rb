# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.references :created_by_admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :invitations, :email, unique: true
    add_index :invitations, :token, unique: true
  end
end
