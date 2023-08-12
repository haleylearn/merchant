
-- Get table with calculate percent success ---> success rate = Total number transactions success *100 / Total number of transactions
WITH get_percent_success_trans AS (
	SELECT *
		,ROUND(CAST(total_success_trans AS FLOAT) * 100 / CAST(total_trans AS FLOAT), 2) AS percent_success
	FROM transactions
)
-- Get table analysis_based_on_range_percent ---> Four Range: Lower < 30, 30 < 50, 51 < 80, Above > 80
, get_analysis_based_on_range_percent AS (
	SELECT merchant
		,DATE
		,payment_method
		,payment_gateway
		,sub_type
		,SUM(CASE 
				WHEN percent_success < 30
					THEN 1
				ELSE 0
				END) AS '< 30'
		,SUM(CASE 
				WHEN percent_success >= 30
					AND percent_success <= 50
					THEN 1
				ELSE 0
				END) AS '30 < 50'
		,SUM(CASE 
				WHEN percent_success > 51
					AND percent_success < 80
					THEN 1
				ELSE 0
				END) AS '51 < 80'
		,SUM(CASE 
				WHEN percent_success > 80
					THEN 1
				ELSE 0
				END) AS '> 80'
	FROM get_percent_success_trans
	GROUP BY merchant
		,DATE
		,payment_method
		,payment_gateway
		,sub_type
)
-- SELECT * FROM get_analysis_based_on_range_percent

-- Get table with analysis_based_on_date and dimension 
, get_analysis_based_on_date AS (
	SELECT merchant
		,payment_method
		,payment_gateway
		,sub_type
		,SUM(CASE 
				WHEN DATE = '2020-02-12'
					THEN ROUND(CAST(total_success_trans AS FLOAT) * 100 / CAST(total_trans AS FLOAT), 2)
				END) AS '2020-02-12'
		,SUM(CASE 
				WHEN DATE = '2020-02-13'
					THEN ROUND(CAST(total_success_trans AS FLOAT) * 100 / CAST(total_trans AS FLOAT), 2)
				END) AS '2020-02-13'
		,SUM(CASE 
				WHEN DATE = '2020-02-14'
					THEN ROUND(CAST(total_success_trans AS FLOAT) * 100 / CAST(total_trans AS FLOAT), 2)
				END) AS '2020-02-14'
	FROM (
		SELECT merchant
			,DATE
			,payment_method
			,payment_gateway
			,sub_type
			,SUM(total_success_trans) AS total_success_trans
			,SUM(total_trans) AS total_trans
		FROM get_percent_success_trans
		GROUP BY merchant
			,DATE
			,payment_method
			,payment_gateway
			,sub_type
		) x
	GROUP BY merchant
		,payment_method
		,payment_gateway
		,sub_type
)
-- SELECT * FROM get_analysis_based_on_date

-- Get table analysis_based_on_hour and dimension and date
, get_analysis_based_on_hour AS (
	SELECT *
		,ROUND((CAST(total_success_trans AS FLOAT) * 100 / CAST(total_trans AS FLOAT)), 2) AS percent_base_hour
	FROM (
		SELECT merchant
			,DATE
			,payment_method
			,payment_gateway
			,sub_type
			,hour_start
			,SUM(total_success_trans) AS total_success_trans
			,SUM(total_trans) AS total_trans
		FROM get_percent_success_trans
		GROUP BY merchant
			,DATE
			,payment_method
			,payment_gateway
			,sub_type
			,hour_start
		) x
)

-- SELECT * FROM get_analysis_based_on_hour

-- Get table with concat dimension
, get_concat_dimenson AS (
	SELECT merchant
		,DATE
		,hour_start
		,percent_base_hour
		,CASE 
			WHEN LEN(payment_method) > 0
				AND LEN(payment_gateway) > 0
				AND LEN(sub_type) > 0
				THEN CONCAT (
						payment_method
						,'-'
						,payment_gateway
						,'-'
						,sub_type
						)
			WHEN LEN(payment_method) IS NULL
				AND LEN(payment_gateway) > 0
				AND LEN(sub_type) > 0
				THEN CONCAT (
						payment_gateway
						,'-'
						,sub_type
						)
			WHEN LEN(payment_method) > 0
				AND LEN(payment_gateway) IS NULL
				AND LEN(sub_type) > 0
				THEN CONCAT (
						payment_method
						,'-'
						,sub_type
						)
			WHEN LEN(payment_method) > 0
				AND LEN(payment_gateway) > 0
				AND LEN(sub_type) IS NULL
				THEN CONCAT (
						payment_method
						,'-'
						,payment_gateway
						)
			WHEN LEN(payment_method) > 0
				AND LEN(payment_gateway) IS NULL
				AND LEN(sub_type) IS NULL
				THEN payment_method
			END AS dimenson_pm_pg_st
	FROM get_analysis_based_on_hour
)

-- Get table to join another table to get the date > base date. 
-- Example with merchant and base date is 2020-02-12 and dimension is CARD-PAYU-NULL to compare another date is 2020-02-13, 2020-02-14 to compare how percent drop day by day
, get_table_w_other_date AS (
	SELECT t1.merchant
		,t1.hour_start
		,t1.percent_base_hour AS percent_ori
		,t1.dimenson_pm_pg_st
		,t1.DATE
		,CASE 
			WHEN (DATEDIFF(DAY, CAST(t1.DATE AS DATE), CAST(t2.DATE AS DATE))) = 1
				THEN ROUND(t2.percent_base_hour - t1.percent_base_hour, 2)
			END AS 'date_ori_add_1'
		,CASE 
			WHEN (DATEDIFF(DAY, CAST(t1.DATE AS DATE), CAST(t2.DATE AS DATE))) = 2
				THEN ROUND(t2.percent_base_hour - t1.percent_base_hour, 2)
			END AS 'date_ori_add_2'
	FROM (
		SELECT *
			,MIN(DATE) OVER (
				PARTITION BY merchant
				,dimenson_pm_pg_st
				) AS min_date
		FROM get_concat_dimenson
		) t1
	INNER JOIN get_concat_dimenson t2 ON t1.merchant = t2.merchant
		AND t1.hour_start = t2.hour_start
		AND t1.dimenson_pm_pg_st = t2.dimenson_pm_pg_st
		AND t2.DATE > t1.min_date
)

-- Exclude NULL value from table get_table_w_other_date
, table_w_other_date_exclude_null AS (
		SELECT merchant
        ,hour_start
        ,dimenson_pm_pg_st
        ,DATE
        ,percent_ori
        ,SUM(CASE 
                WHEN date_ori_add_1 IS NULL
                    THEN 0
                ELSE date_ori_add_1
                END) AS '1'
        ,SUM(CASE 
                WHEN date_ori_add_2 IS NULL
                    THEN 0
                ELSE date_ori_add_2
                END) AS '2'
    FROM get_table_w_other_date
    GROUP BY merchant
        ,hour_start
        ,dimenson_pm_pg_st
        ,DATE
        ,percent_ori
)

SELECT * 
FROM table_w_other_date_exclude_null
ORDER BY merchant, DATE
