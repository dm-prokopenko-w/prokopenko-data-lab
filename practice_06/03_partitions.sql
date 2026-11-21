SET TIME ZONE 'UTC';

-- Завдання 2.1

CREATE TABLE events_by_quarter(
    event_id   bigint    NOT NULL,
    user_id    integer   NOT NULL,
    event_type text      NOT NULL,
    event_time timestamp NOT NULL,
    product_id integer   NOT NULL,
    properties jsonb     NOT NULL,
    PRIMARY KEY(event_id, event_time)
) PARTITION BY RANGE (event_time);

CREATE TABLE events_2025_q1 PARTITION OF events_by_quarter
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE events_2025_q2 PARTITION OF events_by_quarter
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE events_2025_q3 PARTITION OF events_by_quarter
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE events_2025_q4 PARTITION OF events_by_quarter
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

INSERT INTO events_by_quarter (event_id, user_id, event_type, event_time, product_id, properties)
SELECT event_id, user_id, event_type, event_time, product_id, properties
FROM site_events;

SELECT tableoid::regclass::text AS partition_name , COUNT(*) AS events_cnt
FROM events_by_quarter
GROUP BY partition_name 
ORDER BY partition_name;

-- Завдання 2.2

EXPLAIN ANALYZE
SELECT
	event_type,
	COUNT(*) AS events_cnt
FROM events_by_quarter
WHERE event_time >= '2025-03-01'
	AND event_time < '2025-04-01'
GROUP BY event_type;

/*
HashAggregate  (cost=3827.99..3829.99 rows=200 width=18) (actual time=62.745..62.749 rows=4.00 loops=1)
  Group Key: events_by_quarter.event_type
  Batches: 1  Memory Usage: 32kB
  Buffers: shared hit=1766
  ->  Seq Scan on events_2025_q1 events_by_quarter  (cost=0.00..3617.42 rows=42115 width=10) (actual time=30.482..50.387 rows=42514.00 loops=1)
        Filter: ((event_time >= '2025-03-01 00:00:00'::timestamp without time zone) AND (event_time < '2025-04-01 00:00:00'::timestamp without time zone))
        Rows Removed by Filter: 80914
        Buffers: shared hit=1766
Planning:
  Buffers: shared hit=40 dirtied=1
Planning Time: 1.836 ms
Execution Time: 63.118 ms
*/

EXPLAIN ANALYZE
SELECT
	event_type,
	COUNT(*) AS events_cnt
FROM events_by_quarter
GROUP BY event_type;

/*
Finalize GroupAggregate  (cost=13187.18..13247.49 rows=200 width=18) (actual time=173.381..176.020 rows=4.00 loops=1)
  Group Key: events_by_quarter.event_type
  Buffers: shared hit=16 read=7153
  ->  Gather Merge  (cost=13187.18..13243.09 rows=480 width=18) (actual time=173.371..176.008 rows=12.00 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=16 read=7153
        ->  Sort  (cost=12187.16..12187.66 rows=200 width=18) (actual time=160.432..160.436 rows=4.00 loops=3)
              Sort Key: events_by_quarter.event_type
              Sort Method: quicksort  Memory: 25kB
              Buffers: shared hit=16 read=7153
              Worker 0:  Sort Method: quicksort  Memory: 25kB
              Worker 1:  Sort Method: quicksort  Memory: 25kB
              ->  Partial HashAggregate  (cost=12177.52..12179.52 rows=200 width=18) (actual time=160.331..160.336 rows=4.00 loops=3)
                    Group Key: events_by_quarter.event_type
                    Batches: 1  Memory Usage: 32kB
                    Buffers: shared read=7153
                    Worker 0:  Batches: 1  Memory Usage: 32kB
                    Worker 1:  Batches: 1  Memory Usage: 32kB
                    ->  Parallel Append  (cost=0.00..11135.85 rows=208334 width=10) (actual time=1.310..113.965 rows=166666.67 loops=3)
                          Buffers: shared read=7153
                          ->  Parallel Seq Scan on events_2025_q3 events_by_quarter_3  (cost=0.00..2547.19 rows=74219 width=10) (actual time=1.384..57.325 rows=126172.00 loops=1)
                                Buffers: shared read=1805
                          ->  Parallel Seq Scan on events_2025_q4 events_by_quarter_4  (cost=0.00..2534.82 rows=73882 width=10) (actual time=1.253..82.107 rows=125600.00 loops=1)
                                Buffers: shared read=1796
                          ->  Parallel Seq Scan on events_2025_q2 events_by_quarter_2  (cost=0.00..2520.12 rows=73412 width=10) (actual time=1.455..26.801 rows=41600.00 loops=3)
                                Buffers: shared read=1786
                          ->  Parallel Seq Scan on events_2025_q1 events_by_quarter_1  (cost=0.00..2492.05 rows=72605 width=10) (actual time=1.288..61.156 rows=123428.00 loops=1)
                                Buffers: shared read=1766
Planning:
  Buffers: shared hit=248 read=15 dirtied=3
Planning Time: 7.126 ms
Execution Time: 176.475 ms
*/