# Calculating Product and Packs slots

This is a calculation of busy slots for booking calendar.

For now, it's just a draft.


// Products
// | id | name                 | pack  |
// |----|----------------------|-------|
// | 1  | iPhone 16            | false |
// | 2  | Case for iPhone 16   | false |
// | 3  | Pack for iPhone 16   | true  |
// | 4  | AirPods              | false |
// | 5  | Pack for Airpods     | true  |

// Pack Items
// | product_id | pack_id   | quantity |
// |------------|-----------|----------|
// | 1          | 3         | 2        |
// | 2          | 3         | 2        |
// | 4          | 5         | 1        |
// | 1          | 5         | 1        |

// Booking Products
// | start_date | end_date   | product_id | quantity |
// |------------|------------|------------|----------|
// | 2025-07-01 | 2025-07-30 | 3          | 2        |
// | 2025-07-05 | 2025-07-10 | 1          | 3        |
// | 2025-07-05 | 2025-07-10 | 5          | 1        |

// SQL raw
// | start_date | end_date   | product_id | blocked_quantity |
// |------------|------------|------------|------------------|
// | 2025-01-01 | 2025-01-30 | 3          | 2                |
// | 2025-01-01 | 2025-01-30 | 2          | 4                |
// | 2025-01-01 | 2025-01-04 | 1          | 4                |
// | 2025-01-05 | 2025-01-10 | 5          | 1                |
// | 2025-01-05 | 2025-01-10 | 1          | 8                |
// | 2025-01-05 | 2025-01-10 | 4          | 1                |
// | 2025-01-11 | 2025-01-30 | 1          | 4                |