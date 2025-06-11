# frozen_string_literal: true

class ProductCalendar
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :start_date, :datetime
  attribute :end_date, :datetime
  attribute :quantity, :integer

  attr_accessor :product

  def self.calendar(start_date, end_date)
    BookingProduct.all.group_by(&:product_id).flat_map do |_, booking_products|
      # For each item, we calculate the intervals based on the booking items
      intervals = booking_products.flat_map { |i| [i[:start_date], i[:end_date]] }.uniq.sort
      # Calculate based on pairs of intervals
      intervals.each_cons(2).map do |from, to|
        quantity = booking_products.sum do |i|
          i[:start_date] < to && i[:end_date] > from ? i[:quantity] : 0
        end

        ProductCalendar.new(
          product: booking_products.first.product,
          start_date: from,
          end_date: to,
          quantity: quantity
        )
      end
    end
  end
end
