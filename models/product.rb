# frozen_string_literal: true

require 'active_record'

class Product < ActiveRecord::Base
  has_many :pack_items, dependent: :destroy
  accepts_nested_attributes_for :pack_items
end
