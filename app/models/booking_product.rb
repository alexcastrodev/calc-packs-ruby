require "active_record"

class BookingProduct < ActiveRecord::Base
  belongs_to :product
end
