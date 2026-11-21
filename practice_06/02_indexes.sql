SET TIME ZONE 'UTC';

-- Завдання 1.1

EXPLAIN ANALYZE
SELECT 
    event_id, 
    event_type, 
    event_time, 
    product_id
FROM site_events
WHERE user_id = 1234
ORDER BY event_time ASC;

/*
Gather Merge  (cost=10756.29..10767.70 rows=98 width=30) (actual time=21.761..33.112 rows=91.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=7225
  ->  Sort  (cost=9756.26..9756.37 rows=41 width=30) (actual time=10.960..10.962 rows=30.33 loops=3)
        Sort Key: event_time
        Sort Method: quicksort  Memory: 28kB
        Buffers: shared hit=7225
        Worker 0:  Sort Method: quicksort  Memory: 25kB
        Worker 1:  Sort Method: quicksort  Memory: 25kB
        ->  Parallel Seq Scan on site_events  (cost=0.00..9755.17 rows=41 width=30) (actual time=0.146..10.885 rows=30.33 loops=3)
              Filter: (user_id = 1234)
              Rows Removed by Filter: 166636
              Buffers: shared hit=7151
Planning:
  Buffers: shared hit=55 read=1
Planning Time: 11.299 ms
Execution Time: 33.208 ms
*/

CREATE INDEX site_events_user_id_idx ON site_events (user_id);

/*
Sort  (cost=370.76..371.01 rows=99 width=30) (actual time=0.211..0.215 rows=91.00 loops=1)
  Sort Key: event_time
  Sort Method: quicksort  Memory: 29kB
  Buffers: shared hit=89 read=3
  ->  Bitmap Heap Scan on site_events  (cost=5.19..367.48 rows=99 width=30) (actual time=0.084..0.194 rows=91.00 loops=1)
        Recheck Cond: (user_id = 1234)
        Heap Blocks: exact=89
        Buffers: shared hit=89 read=3
        ->  Bitmap Index Scan on site_events_user_id_idx  (cost=0.00..5.17 rows=99 width=0) (actual time=0.068..0.069 rows=91.00 loops=1)
              Index Cond: (user_id = 1234)
              Index Searches: 1
              Buffers: shared read=3
Planning:
  Buffers: shared hit=19 read=1
Planning Time: 0.204 ms
Execution Time: 0.232 ms
 */

-- Завдання 1.2

EXPLAIN ANALYZE
SELECT 
	event_id, 
	user_id, 
	event_time
FROM site_events 
WHERE event_type = 'payment_failed'
ORDER BY event_time DESC
LIMIT 30;

/*
 Limit  (cost=10946.54..10950.04 rows=30 width=20) (actual time=16.980..19.523 rows=30.00 loops=1)
  Buffers: shared hit=7225
  ->  Gather Merge  (cost=10946.54..12757.60 rows=15550 width=20) (actual time=16.977..19.516 rows=30.00 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=7225
        ->  Sort  (cost=9946.52..9962.72 rows=6479 width=20) (actual time=13.613..13.616 rows=24.33 loops=3)
              Sort Key: event_time DESC
              Sort Method: top-N heapsort  Memory: 29kB
              Buffers: shared hit=7225
              Worker 0:  Sort Method: top-N heapsort  Memory: 29kB
              Worker 1:  Sort Method: top-N heapsort  Memory: 29kB
              ->  Parallel Seq Scan on site_events  (cost=0.00..9755.17 rows=6479 width=20) (actual time=0.016..12.691 rows=5034.67 loops=3)
                    Filter: (event_type = 'payment_failed'::text)
                    Rows Removed by Filter: 161632
                    Buffers: shared hit=7151
Planning:
  Buffers: shared hit=4
Planning Time: 0.118 ms
Execution Time: 19.598 ms
 */

CREATE INDEX site_events_type_time_idx ON site_events(event_type, event_time);

/*
Limit  (cost=0.42..46.18 rows=30 width=20) (actual time=0.034..0.061 rows=30.00 loops=1)
  Buffers: shared hit=12 read=4
  ->  Index Scan Backward using site_events_type_time_idx on site_events  (cost=0.42..23718.22 rows=15550 width=20) (actual time=0.032..0.057 rows=30.00 loops=1)
        Index Cond: (event_type = 'payment_failed'::text)
        Index Searches: 1
        Buffers: shared hit=12 read=4
Planning:
  Buffers: shared hit=28 read=1
Planning Time: 0.334 ms
Execution Time: 0.080 ms
*/

-- Завдання 1.3

CREATE INDEX site_events_event_time_idx ON site_events(event_time);

EXPLAIN ANALYZE 
SELECT 
	event_id, 
	user_id, 
	event_type, 
	event_time
FROM site_events
WHERE date(event_time) = '2025-11-28';

/*
Gather  (cost=1000.00..11526.00 rows=2500 width=30) (actual time=33.374..37.878 rows=1372.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=7151
  ->  Parallel Seq Scan on site_events  (cost=0.00..10276.00 rows=1042 width=30) (actual time=24.847..26.413 rows=457.33 loops=3)
        Filter: (date(event_time) = '2025-11-28'::date)
        Rows Removed by Filter: 166209
        Buffers: shared hit=7151
Planning:
  Buffers: shared hit=6
Planning Time: 0.103 ms
Execution Time: 37.951 ms
*/

EXPLAIN ANALYZE 
SELECT 
	event_id, 
	user_id, 
	event_type, 
	event_time
FROM site_events
WHERE event_time >= '2025-11-28'
	AND event_time < '2025-11-29';

/*
Index Scan using site_events_event_time_idx on site_events  (cost=0.42..64.50 rows=1304 width=30) (actual time=0.146..0.529 rows=1372.00 loops=1)
  Index Cond: ((event_time >= '2025-11-28 00:00:00'::timestamp without time zone) AND (event_time < '2025-11-29 00:00:00'::timestamp without time zone))
  Index Searches: 1
  Buffers: shared hit=23 read=7
Planning:
  Buffers: shared hit=33 read=1 dirtied=1
Planning Time: 0.495 ms
Execution Time: 0.583 ms
*/

-- Завдання 1.4

CREATE INDEX site_events_event_time_brin ON site_events USING brin (event_time);

SELECT pg_size_pretty(pg_relation_size('site_events_event_time_idx')) AS btree_size,
       pg_size_pretty(pg_relation_size('site_events_event_time_brin'))  AS brin_size;

-- 11 MB	24 kB


-- Завдання 1.5

EXPLAIN ANALYZE
SELECT 
	event_id, 
	user_id, 
	event_type, 
	event_time
FROM site_events 
WHERE properties @> '{"campaign": "black_friday"}';

/*
Gather  (cost=1000.00..10820.17 rows=650 width=30) (actual time=55.188..61.332 rows=798.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=7151
  ->  Parallel Seq Scan on site_events  (cost=0.00..9755.17 rows=271 width=30) (actual time=51.856..55.601 rows=266.00 loops=3)
        Filter: (properties @> '{"campaign": "black_friday"}'::jsonb)
        Rows Removed by Filter: 166401
        Buffers: shared hit=7151
Planning:
  Buffers: shared hit=5 dirtied=2
Planning Time: 0.500 ms
Execution Time: 61.383 ms
*/

CREATE INDEX site_events_properties_idx  ON site_events USING gin (properties);

/*
Bitmap Heap Scan on site_events  (cost=189.58..2135.38 rows=650 width=30) (actual time=0.241..0.591 rows=798.00 loops=1)
  Recheck Cond: (properties @> '{"campaign": "black_friday"}'::jsonb)
  Heap Blocks: exact=137
  Buffers: shared hit=146
  ->  Bitmap Index Scan on site_events_properties_idx  (cost=0.00..189.42 rows=650 width=0) (actual time=0.217..0.217 rows=798.00 loops=1)
        Index Cond: (properties @> '{"campaign": "black_friday"}'::jsonb)
        Index Searches: 1
        Buffers: shared hit=9
Planning:
  Buffers: shared hit=25
Planning Time: 0.426 ms
Execution Time: 0.640 ms
*/