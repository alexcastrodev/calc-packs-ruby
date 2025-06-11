# frozen_string_literal: true

require_relative 'test_helper'
require 'bullet'
require 'logger'

class PackTest < Minitest::Test
  def setup
    # Clear any existing records
    PackItem.delete_all
    Product.delete_all
    BookingProduct.delete_all

    # Configure Bullet to detect and raise on N+1 queries
    Bullet.raise = true
    Bullet.enable = true
    Bullet.unused_eager_loading_enable = false

    @item_a = Product.create!(name: 'iPhone 16')
    @item_b = Product.create!(name: 'Case for iPhone 16')
    @pack = Product.create!(name: 'Pack for iPhone 16', pack: true, pack_items_attributes: [
      { quantity: 3, product: @item_a },
      { quantity: 2, product: @item_b }
    ])

    # Start Bullet request tracking
    ActiveRecord::Base.logger = Logger.new($stdout)
    Bullet.start_request
  end

  def teardown
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end

  def test_one_pack
    start_date = DateTime.new(2025, 6, 16, 7, 0, 0)
    end_date = start_date + 30.days
    partial_start = start_date + 5.days

    # Create a booking for a pack
    BookingProduct.create!(quantity: 2, product: @pack, start_date: start_date, end_date: start_date + 30.day)
    # By adding a pack, we should see the pack items being created
    # it should be automatically on model, but it's ok doing it manually here
    BookingProduct.create!(quantity: 2, product: @item_a, start_date: start_date, end_date: start_date + 30.day)
    BookingProduct.create!(quantity: 2, product: @item_b, start_date: start_date, end_date: start_date + 30.day)
    
    # Create a booking for a standalone item
    BookingProduct.create!(quantity: 2, product: @item_b, start_date: partial_start, end_date: partial_start + 10.day)

    calendar = ProductCalendar.calendar(Time.now, Time.now + 30.day).sort_by { |c| c.product.id }
    
    assert_equal 5, calendar.size

    assert_equal 2, calendar[0].quantity
    assert_equal @item_a.id, calendar[0].product.id
    # Same start and end date as the pack
    assert_equal '2025-06-16T07:00:00Z', calendar[0].start_date.iso8601
    assert_equal '2025-07-16T07:00:00Z', calendar[0].end_date.iso8601
    
    assert_equal 2, calendar[1].quantity
    assert_equal @item_b.id, calendar[1].product.id
    assert_equal '2025-06-16T07:00:00Z', calendar[1].start_date.iso8601
    assert_equal '2025-06-21T07:00:00Z', calendar[1].end_date.iso8601
    
    assert_equal 4, calendar[2].quantity
    assert_equal @item_b.id, calendar[2].product.id
    assert_equal '2025-06-21T07:00:00Z', calendar[2].start_date.iso8601
    assert_equal '2025-07-01T07:00:00Z', calendar[2].end_date.iso8601

    assert_equal 2, calendar[3].quantity
    assert_equal @item_b.id, calendar[3].product.id
    assert_equal '2025-07-01T07:00:00Z', calendar[3].start_date.iso8601
    assert_equal '2025-07-16T07:00:00Z', calendar[3].end_date.iso8601
    
    assert_equal 2, calendar[4].quantity
    assert_equal @pack.id, calendar[4].product.id
    assert_equal '2025-06-16T07:00:00Z', calendar[4].start_date.iso8601
    assert_equal '2025-07-16T07:00:00Z', calendar[4].end_date.iso8601
  end
end
