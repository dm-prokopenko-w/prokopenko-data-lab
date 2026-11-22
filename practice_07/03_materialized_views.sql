SET TIME ZONE 'UTC';

-- Завдання 2.1

CREATE MATERIALIZED VIEW source_stats_mv AS
SELECT 
	source,
	COUNT(*) AS events_cnt 
FROM events_flat
GROUP BY source;

EXPLAIN ANALYZE
SELECT 
	source,
	count(*) AS events_cnt
FROM events_flat
GROUP BY source
ORDER BY events_cnt DESC;

/*
Sort  (cost=11799.29..11799.31 rows=7 width=40) (actual time=147.999..153.352 rows=4.00 loops=1)
  Sort Key: (count(*)) DESC
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=7170
  ->  Finalize GroupAggregate  (cost=11797.04..11799.19 rows=7 width=40) (actual time=147.826..153.245 rows=4.00 loops=1)
        Group Key: ((site_events.properties ->> 'source'::text))
        Buffers: shared hit=7167
        ->  Gather Merge  (cost=11797.04..11799.02 rows=17 width=40) (actual time=147.815..153.203 rows=12.00 loops=1)
              Workers Planned: 2
              Workers Launched: 2
              Buffers: shared hit=7167
              ->  Sort  (cost=10797.02..10797.03 rows=7 width=40) (actual time=132.222..132.225 rows=4.00 loops=3)
                    Sort Key: ((site_events.properties ->> 'source'::text))
                    Sort Method: quicksort  Memory: 25kB
                    Buffers: shared hit=7167
                    Worker 0:  Sort Method: quicksort  Memory: 25kB
                    Worker 1:  Sort Method: quicksort  Memory: 25kB
                    ->  Partial HashAggregate  (cost=10796.83..10796.92 rows=7 width=40) (actual time=132.069..132.073 rows=4.00 loops=3)
                          Group Key: (site_events.properties ->> 'source'::text)
                          Batches: 1  Memory Usage: 32kB
                          Buffers: shared hit=7151
                          Worker 0:  Batches: 1  Memory Usage: 32kB
                          Worker 1:  Batches: 1  Memory Usage: 32kB
                          ->  Parallel Seq Scan on site_events  (cost=0.00..9755.17 rows=208333 width=32) (actual time=0.125..85.348 rows=166666.67 loops=3)
                                Buffers: shared hit=7151
Planning:
  Buffers: shared hit=86
Planning Time: 1.684 ms
Execution Time: 153.800 ms
*/

EXPLAIN ANALYZE
SELECT 
	source,
	events_cnt
FROM source_stats_mv
ORDER BY events_cnt DESC;

/*
Sort  (cost=83.37..86.37 rows=1200 width=40) (actual time=0.031..0.033 rows=4.00 loops=1)
  Sort Key: events_cnt DESC
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=1
  ->  Seq Scan on source_stats_mv  (cost=0.00..22.00 rows=1200 width=40) (actual time=0.018..0.019 rows=4.00 loops=1)
        Buffers: shared hit=1
Planning Time: 0.070 ms
Execution Time: 0.049 ms
*/
-- швидше виконався запит до source_stats_mv.

-- Завдання 2.2

INSERT INTO site_events (event_id, user_id, event_type, event_time, product_id, properties)
VALUES (500001, 1234, 'page_view',   '2026-01-05 10:00', 15, '{"source": "tiktok", "campaign": "launch"}'),
       (500002, 1234, 'add_to_cart', '2026-01-05 10:02', 15, '{"source": "tiktok", "campaign": "launch"}'),
       (500003, 1234, 'checkout',    '2026-01-05 10:05', 15, '{"source": "tiktok", "campaign": "launch"}');

SELECT 
	source,
	count(*) AS events_cnt
FROM events_flat
WHERE source = 'tiktok'
GROUP BY source
ORDER BY events_cnt DESC;

--tiktok є

SELECT 
	source,
	events_cnt
FROM source_stats_mv
WHERE source = 'tiktok'
ORDER BY events_cnt DESC;

--tiktok немає

REFRESH MATERIALIZED VIEW source_stats_mv;

--tiktok є

-- Завдання 2.3

REFRESH MATERIALIZED VIEW CONCURRENTLY source_stats_mv;

CREATE UNIQUE INDEX source_stats_mv_key  ON source_stats_mv (source);

-- Завдання 2.4

INSERT INTO site_events (event_id, user_id, event_type, event_time, product_id, properties)
VALUES (500004, 2001, 'page_view', '2026-01-06 18:30', 42, '{"source": "instagram", "campaign": "launch"}');

SELECT 
	source,
	events_cnt
FROM source_stats_mv
ORDER BY source;
