WITH sol_price AS (
  SELECT
    hour,
    price as sol_price
  FROM
    solana.price.ez_prices_hourly
  WHERE
    symbol = 'SOL'
    AND is_native = true
    AND hour >= DATEADD('day', -30, CURRENT_TIMESTAMP())
),
staked_tokens AS (
  SELECT
    p.hour,
    p.token_address,
    p.name,
    p.symbol,
    p.price as token_price,
    s.sol_price,
    ((p.price - s.sol_price) / s.sol_price * 100) as price_deviation_percentage
  FROM
    solana.price.ez_prices_hourly p
    JOIN sol_price s ON s.hour = p.hour
  WHERE
    p.token_address IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
    AND p.hour >= DATEADD('day', -30, CURRENT_TIMESTAMP())
)
SELECT
  hour,
  token_address,
  name,
  symbol,
  token_price,
  sol_price,
  ROUND(price_deviation_percentage, 2) as price_deviation_percentage
FROM
  staked_tokens
ORDER BY
  hour DESC,
  token_address;