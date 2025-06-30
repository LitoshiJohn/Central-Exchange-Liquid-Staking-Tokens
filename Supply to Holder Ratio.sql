WITH daily_metrics AS (
  SELECT
    DATE_TRUNC('day', b.block_timestamp) as date,
    b.mint,
    CASE
      WHEN b.mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'bbSOL'
      WHEN b.mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'bnSOL'
      WHEN b.mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'cdcSOL'
      WHEN b.mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'bgSOL'
    END as token_symbol,
    COUNT(DISTINCT b.owner) as unique_holders,
    SUM(b.balance) as total_supply
  FROM
    solana.core.fact_token_balances b
  WHERE
    b.mint IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
    AND b.block_timestamp >= DATEADD('day', -90, CURRENT_DATE)
    AND b.balance > 0 
  GROUP BY
    1,2,3
)
SELECT
  date,
  token_symbol,
  mint,
  unique_holders,
  total_supply,
  total_supply / NULLIF(unique_holders, 0) as supply_per_holder_ratio
FROM
  daily_metrics
WHERE
  token_symbol IS NOT NULL
ORDER BY
  date DESC,
  token_symbol;