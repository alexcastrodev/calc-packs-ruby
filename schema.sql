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
