# frozen_string_literal: true

require 'bundler/setup'
require 'active_record'
require 'sqlite3'
require 'minitest/autorun'

# Establish an in-memory SQLite3 connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Define the database schema
ActiveRecord::Schema.define do
  create_table :products, force: true do |t|
    t.string :name

    t.boolean :pack, default: false
  end

  create_table :booking_products, force: true do |t|
    t.integer :quantity
    t.datetime :start_date, null: false
    t.datetime :end_date, null: false

    t.references :product, foreign_key: true
  end

  create_table :pack_items, force: true do |t|
    t.integer :quantity
    t.references :product, foreign_key: true
    t.references :pack, foreign_key: { to_table: :products }
  end

  create_table :packs, force: true do |t|
    t.string :name
  end
end

Dir[File.join(__dir__, '../models/*.rb')].sort.each { |file| require file }
