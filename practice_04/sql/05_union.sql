SET TIME ZONE 'UTC';

-- Завдання 5.1
SELECT
    o.created_at AS event_at,
    'замовлення створено' AS event,
    o.total_amount AS amount
FROM shop.orders o
WHERE o.order_id = 271060

UNION ALL

SELECT
    p.created_at,
    CASE p.status
        WHEN 'succeeded' THEN 'платіж успішний'
        WHEN 'failed'    THEN 'платіж відхилено'
    END,
    p.amount
FROM shop.payments p
WHERE p.order_id = 271060
    AND p.status IN ('succeeded', 'failed')

UNION ALL

SELECT
    s.shipped_at,
    'відправлено',
    NULL::numeric
FROM shop.shipments s
WHERE s.order_id = 271060
    AND s.shipped_at IS NOT NULL

UNION ALL

SELECT
    s.received_at,
    'отримано',
    NULL::numeric
FROM shop.shipments s
WHERE s.order_id = 271060
    AND s.received_at IS NOT NULL

ORDER BY event_at DESC;

-- Завдання 5.2
SELECT
    o.country_code,
    'замовлення' AS metric,
    SUM(o.total_amount) AS amount
FROM shop.orders o
WHERE o.created_at >= '2025-12-01'
    AND o.created_at <  '2026-01-01'
GROUP BY o.country_code

UNION ALL

SELECT
    o.country_code,
    'позиції' AS metric,
    SUM(oi.quantity * oi.unit_price) AS amount
FROM shop.orders o
JOIN shop.order_items oi ON oi.order_id = o.order_id
WHERE o.created_at >= '2025-12-01'
    AND o.created_at <  '2026-01-01'
GROUP BY o.country_code

UNION ALL

SELECT
    o.country_code,
    'успішні платежі' AS metric,
    SUM(p.amount) AS amount
FROM shop.orders o
JOIN shop.payments p ON p.order_id = o.order_id
WHERE o.created_at >= '2025-12-01'
    AND o.created_at <  '2026-01-01'
    AND p.payment_type = 'payment'
    AND p.status = 'succeeded'
GROUP BY o.country_code

ORDER BY country_code, metric;