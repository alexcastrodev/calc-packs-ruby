-- Calculates blocked quantity ranges for both standalone products and pack items.
-- Each booking reserves inventory either for a product directly or for a pack of products.
-- Packs contribute their own booking quantities plus the quantities of their component items.
-- The query returns collapsed time ranges where the blocked quantity for a product remains constant.
-- Time granularity is 15 minutes; end times are inclusive.

WITH expanded_bookings AS (
    -- Include the booking itself (pack or not)
    SELECT
        bp.start_date       AS start_date,
        bp.end_date         AS end_date,
        bp.product_id,
        bp.quantity
    FROM booking_products bp

    UNION ALL

    -- If the booking references a pack, expand its items
    SELECT
        bp.start_date       AS start_date,
        bp.end_date         AS end_date,
        pi.product_id,
        bp.quantity * pi.quantity AS quantity
    FROM booking_products bp
    JOIN products p       ON p.id = bp.product_id AND p.pack = true
    JOIN pack_items pi    ON pi.pack_id = bp.product_id
),
-- Convert each booking range into "+" and "-" inventory events
inventory_events AS (
    SELECT product_id, start_date AS event_date, quantity AS change
    FROM expanded_bookings
    UNION ALL
    SELECT product_id, (end_date + INTERVAL '15 minutes') AS event_date, -quantity
    FROM expanded_bookings
),
-- Order events and compute the running quantity for every product
ordered_events AS (
    SELECT
        product_id,
        event_date,
        SUM(change) AS change
    FROM inventory_events
    GROUP BY product_id, event_date
),
running AS (
    SELECT
        product_id,
        event_date,
        SUM(change) OVER (PARTITION BY product_id ORDER BY event_date) AS total_qty,
        LEAD(event_date) OVER (PARTITION BY product_id ORDER BY event_date) AS next_event
    FROM ordered_events
),
-- Derive continuous ranges where quantity does not change
ranges AS (
    SELECT
        product_id,
        event_date       AS start_date,
        next_event - INTERVAL '15 minutes' AS end_date,
        total_qty        AS blocked_quantity
    FROM running
    WHERE next_event IS NOT NULL
      AND total_qty > 0
)
SELECT start_date, end_date, product_id, blocked_quantity
FROM ranges
ORDER BY start_date, product_id;
