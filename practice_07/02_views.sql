SET TIME ZONE 'UTC';

-- Завдання 1.1

CREATE VIEW events_flat AS 
SELECT 
	event_id, 
	user_id, 
	event_type, 
	event_time, 
	product_id,
	properties ->> 'source'  AS source 
FROM site_events;

EXPLAIN 
SELECT 
	source,
	count(*) AS events_cnt
FROM events_flat
GROUP BY source
ORDER BY events_cnt DESC;

/*
Sort  (cost=11799.29..11799.31 rows=7 width=40)
  Sort Key: (count(*)) DESC
  ->  Finalize GroupAggregate  (cost=11797.04..11799.19 rows=7 width=40)
        Group Key: ((site_events.properties ->> 'source'::text))
        ->  Gather Merge  (cost=11797.04..11799.02 rows=17 width=40)
              Workers Planned: 2
              ->  Sort  (cost=10797.02..10797.03 rows=7 width=40)
                    Sort Key: ((site_events.properties ->> 'source'::text))
                    ->  Partial HashAggregate  (cost=10796.83..10796.92 rows=7 width=40)
                          Group Key: (site_events.properties ->> 'source'::text)
                          ->  Parallel Seq Scan on site_events  (cost=0.00..9755.17 rows=208333 width=32)
*/

-- Висновок: база читає site_events, бо events_flat лише представлення без власних даних.

-- Завдання 1.2

CREATE VIEW daily_events AS
SELECT 
	event_time::date AS event_date,
	event_type,
	count(*) AS events_cnt
FROM site_events
GROUP BY event_time::date, event_type;

SELECT 
	event_date, 
	event_type,
	events_cnt 
FROM daily_events
WHERE event_date BETWEEN '2025-11-28' AND '2025-11-30'
ORDER BY event_date, event_type;