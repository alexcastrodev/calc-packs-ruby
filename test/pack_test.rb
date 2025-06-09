require_relative "test_helper"
require "bullet"
require "logger"

class PackTest < Minitest::Test
  def setup
    # Clear any existing records
    Pack.delete_all
    Product.delete_all
    BookingProduct.delete_all

    # Configure Bullet to detect and raise on N+1 queries
    Bullet.raise = true
    Bullet.enable = true
    Bullet.unused_eager_loading_enable = false

    item_a = Product.create!(name: "iPhone 16")
    item_b = Product.create!(name: "Case for iPhone 16")
    pack = Product.create!(name: "Pack for iPhone 16", pack: true, pack_items_attributes: [
      { quantity: 3, product: item_a },
      { quantity: 2, product: item_b }
    ])

    # Start Bullet request tracking
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Bullet.start_request
  end

  def teardown
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end

  def test_one_pack
    BookingProduct.create!(quantity: 2, product: pack, start_date: Time.now, end_date: Time.now + 30.day)
    BookingProduct.create!(quantity: 2, product: item_b, start_date: Time.now + 5.day, end_date: Time.now + 10.day)

    # I should have slots:
    # 30 days to: pack
    # 5 days to: item_b (now to 5 days later)
    # 5 days to: item_b (5 days later to 10 days later)
    # 15 days to: item_b (10 days later to 30 days later)
    # 30 days to: item_a
    # | start_date | end_date   | product_id | quantity |
    # | 2025-01-01 | 2025-01-01 | pack       | 2        |
    # | 2025-01-01 | 2025-01-05 | item_b     | 4        |
    # | 2025-01-05 | 2025-01-10 | item_b     | 6        |
    # | 2025-01-10 | 2025-01-30 | item_b     | 4        |
    # | 2025-01-01 | 2025-01-30 | item_a     | 6        |
    # 
  end
end
