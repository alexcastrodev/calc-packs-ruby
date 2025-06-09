require "active_record"

class PackItem < ActiveRecord::Base
    belongs_to :product, class_name: "Product", foreign_key: "product_id"
    belongs_to :item, class_name: "Product", foreign_key: "pack_id"
end
