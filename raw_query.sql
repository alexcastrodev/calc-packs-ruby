-- Calculates blocked quantity ranges for both standalone products and pack items.
-- Each booking reserves inventory either for a product directly or for a pack of products.
-- Packs contribute their own booking quantities plus the quantities of their component items.
-- The query returns collapsed time ranges where the blocked quantity for a product remains constant.
-- Time granularity is 15 minutes; end times are inclusive.

WITH pack_details AS (
    -- Aggregate pack items as arrays and include the pack itself
    SELECT
        p.id AS pack_id,
        ARRAY[p.id] || COALESCE(array_agg(pi.product_id ORDER BY pi.id), ARRAY[]::integer[]) AS products,
        ARRAY[1]   || COALESCE(array_agg(pi.quantity ORDER BY pi.id), ARRAY[]::integer[]) AS quantities
    FROM products p
    LEFT JOIN pack_items pi ON pi.pack_id = p.id
    WHERE p.pack = true
    GROUP BY p.id
),
expanded_bookings AS (
    SELECT
        bp.start_date,
        bp.end_date,
        items.product_id,
        bp.quantity * items.item_qty AS quantity
    FROM booking_products bp
    JOIN products p ON p.id = bp.product_id
    LEFT JOIN pack_details pd ON pd.pack_id = bp.product_id
    -- Expand pack bookings into individual product rows using unnest on arrays
    JOIN LATERAL (
        SELECT product_id, item_qty
        FROM unnest(
                 CASE WHEN p.pack THEN pd.products   ELSE ARRAY[p.id] END,
                 CASE WHEN p.pack THEN pd.quantities ELSE ARRAY[1]   END
             ) AS t(product_id, item_qty)
    ) AS items ON TRUE
),
inventory_events AS (
    -- For each booking create "+" and "-" events without using UNION ALL
    SELECT
        eb.product_id,
        ev.event_date,
        ev.change
    FROM expanded_bookings eb
    CROSS JOIN LATERAL (
        VALUES
            (eb.start_date, eb.quantity),
            (eb.end_date + INTERVAL '15 minutes', -eb.quantity)
    ) AS ev(event_date, change)
),
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
ranges AS (
    SELECT
        product_id,
        event_date AS start_date,
        next_event - INTERVAL '15 minutes' AS end_date,
        total_qty AS blocked_quantity
    FROM running
    WHERE next_event IS NOT NULL
      AND total_qty > 0
)
SELECT start_date, end_date, product_id, blocked_quantity
FROM ranges
ORDER BY start_date, product_id;
