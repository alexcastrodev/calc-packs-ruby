# Calculating Product and Packs slots

This project calculates busy slots for products and packs in a booking calendar using Ruby, ActiveRecord, and SQLite.

## Features

- Models for products, packs, pack items, and booking products.
- Calculates product availability over time intervals.
- Includes tests for booking and pack logic.
- Uses Bullet to detect N+1 queries.

## Example Usage

Suppose you have the following scenario:

- A pack called "Pack for iPhone 16" contains:
  - 2x "iPhone 16"
  - 2x "Case for iPhone 16"
- You create these bookings:
  - 2x "Pack for iPhone 16" from 2025-06-16 07:00 to 2025-07-16 07:00
  - 2x "iPhone 16" from 2025-06-16 07:00 to 2025-07-16 07:00
  - 2x "Case for iPhone 16" from 2025-06-16 07:00 to 2025-07-16 07:00
  - 2x "Case for iPhone 16" from 2025-06-21 07:00 to 2025-07-01 07:00

When you generate the product calendar, you get:

| Product                | Quantity | Start Date           | End Date             |
|------------------------|----------|----------------------|----------------------|
| iPhone 16              | 2        | 2025-06-16T07:00:00Z | 2025-07-16T07:00:00Z |
| Case for iPhone 16     | 2        | 2025-06-16T07:00:00Z | 2025-06-21T07:00:00Z |
| Case for iPhone 16     | 4        | 2025-06-21T07:00:00Z | 2025-07-01T07:00:00Z |
| Case for iPhone 16     | 2        | 2025-07-01T07:00:00Z | 2025-07-16T07:00:00Z |
| Pack for iPhone 16     | 2        | 2025-06-16T07:00:00Z | 2025-07-16T07:00:00Z |

This shows how bookings for packs and individual products are split and merged in the calendar.