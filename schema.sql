CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    pack BOOLEAN DEFAULT FALSE
);

CREATE TABLE booking_products (
    id SERIAL PRIMARY KEY,
    quantity INTEGER,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    product_id INTEGER REFERENCES products(id)
);

CREATE TABLE pack_items (
    id SERIAL PRIMARY KEY,
    quantity INTEGER,
    product_id INTEGER REFERENCES products(id),
    pack_id INTEGER REFERENCES products(id)
);

-- Indexes to speed up lookups and joins
CREATE INDEX idx_products_pack ON products(pack);
CREATE INDEX idx_booking_products_product_dates ON booking_products(product_id, start_date, end_date);
CREATE INDEX idx_pack_items_pack_id ON pack_items(pack_id);
CREATE INDEX idx_pack_items_product_id ON pack_items(product_id);
