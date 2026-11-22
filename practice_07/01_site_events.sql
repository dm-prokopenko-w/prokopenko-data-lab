-- представлення з цієї роботи (якщо скрипт запускається повторно)
DROP MATERIALIZED VIEW IF EXISTS source_stats_mv;
DROP VIEW IF EXISTS daily_events;
DROP VIEW IF EXISTS events_flat;
DROP TABLE IF EXISTS site_events;

CREATE TABLE site_events (
    event_id   bigint    PRIMARY KEY,
    user_id    integer   NOT NULL,
    event_type text      NOT NULL,
    event_time timestamp NOT NULL,
    product_id integer   NOT NULL,
    properties jsonb     NOT NULL
);

SELECT setseed(0.42);

INSERT INTO site_events (event_id, user_id, event_type, event_time, product_id, properties)
SELECT g,
       1 + floor(r_user * 5000)::int,
       CASE WHEN r_type < 0.75 THEN 'page_view'
            WHEN r_type < 0.90 THEN 'add_to_cart'
            WHEN r_type < 0.97 THEN 'checkout'
            ELSE 'payment_failed'
       END,
       ts,
       1 + floor(r_product * 1000)::int,
       CASE WHEN r_source < 0.45 THEN jsonb_build_object('source', 'google',
                 'campaign', (ARRAY['brand_search', 'generic_search'])[1 + floor(r_campaign * 2)::int])
            WHEN r_source < 0.70 THEN jsonb_build_object('source', 'facebook',
                 'campaign', (ARRAY['retargeting', 'lookalike'])[1 + floor(r_campaign * 2)::int])
            WHEN r_source < 0.92 THEN jsonb_build_object('source', 'direct')
            ELSE jsonb_build_object('source', 'email',
                 'campaign', CASE WHEN ts >= '2025-11-24' AND ts < '2025-12-01'
                                  THEN 'black_friday' ELSE 'weekly_digest' END)
       END
FROM (
    SELECT g,
           random() AS r_user,
           random() AS r_type,
           random() AS r_product,
           random() AS r_source,
           random() AS r_campaign,
           timestamp '2025-01-01'
             + (g - 1) * interval '63 seconds'
             + floor(random() * 63) * interval '1 second' AS ts
    FROM generate_series(1, 500000) AS g
) AS s;

ANALYZE site_events;