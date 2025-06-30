-- forked from jackguy / weary-ivory copy copy @ https://flipsidecrypto.xyz/jackguy/q/DAhkjQBFYINz/weary-ivory-copy-copy

WITH token_list AS (
    SELECT 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' AS token_address, 'bbSOL' AS token_name
    UNION ALL
    SELECT 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' AS token_address, 'cdcSOL' AS token_name
    UNION ALL
    SELECT 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' AS token_address, 'bgSOL' AS token_name
    UNION ALL
    SELECT 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' AS token_address, 'bnSOL' AS token_name
),
price_data AS (
    SELECT
        tl.token_address,
        tl.token_name,
        p.hour,
        p.price AS token_price,
        s.price AS sol_price,
        (p.price / s.price) AS token_to_sol_ratio
    FROM
        solana.price.ez_prices_hourly p
    JOIN
        solana.price.ez_prices_hourly s
        ON p.hour = s.hour AND s.token_address = 'So11111111111111111111111111111111111111112'
    JOIN
        token_list tl
        ON p.token_address = tl.token_address
    WHERE
        p.hour >= DATEADD('day',-120,CURRENT_DATE())
        AND p.hour <= CURRENT_TIMESTAMP()  -- Add this to exclude future dates
),
daily_metrics AS (
    SELECT
        date(hour) as date,
        token_name,
        median(token_to_sol_ratio) as median_price,
        AVG(median_price) OVER (
            partition by token_name ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS smoothed_median_price
    FROM price_data
    GROUP BY 1,2
)

SELECT 
    date,
    token_name,
    median_price,
    smoothed_median_price,
    LAG(smoothed_median_price, 30) OVER (
        PARTITION BY token_name
        ORDER BY date
    ) AS smoothed_price_30_days_ago,
    CASE 
        WHEN LAG(smoothed_median_price, 30) OVER (PARTITION BY token_name ORDER BY date) IS NOT NULL
        THEN (POWER(smoothed_median_price/LAG(smoothed_median_price, 30) OVER (PARTITION BY token_name ORDER BY date), 365.0 / 30.0) - 1) * 100 
    END as apy_30_day
FROM daily_metrics
ORDER BY date DESC, token_name;