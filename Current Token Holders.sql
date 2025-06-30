WITH daily_active_balances AS (
    SELECT 
        DATE_TRUNC('day', block_timestamp) as date,
        CASE
            WHEN mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Bitget Staked Sol'
            WHEN mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Crypto.com Staked Sol'
            WHEN mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Bybit Staked Sol'
            WHEN mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Binance Staked Sol'
        END as token,
        owner,
        SUM(balance - pre_balance) as daily_balance_change
    FROM solana.core.fact_token_balances
    WHERE mint IN (
        'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY', 
        'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX', 
        'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',  
        'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
    AND block_timestamp >= CURRENT_DATE - 90
    AND succeeded = TRUE
    GROUP BY 1,2,3
),

cumulative_balances AS (
    SELECT 
        date,
        token,
        owner,
        SUM(daily_balance_change) OVER (
            PARTITION BY token, owner 
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as running_balance
    FROM daily_active_balances
),

latest_date_balances AS (
    SELECT 
        token,
        owner,
        running_balance,
        ROW_NUMBER() OVER (PARTITION BY token, owner ORDER BY date DESC) as rn
    FROM cumulative_balances
)

SELECT 
    token,
    COUNT(DISTINCT CASE WHEN running_balance > 0 THEN owner END) as current_holders
FROM latest_date_balances
WHERE rn = 1
GROUP BY 1
ORDER BY current_holders DESC;