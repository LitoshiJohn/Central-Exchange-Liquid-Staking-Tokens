WITH mintburn AS (
  SELECT
    BLOCK_TIMESTAMP,
    CASE
      WHEN mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Bitget Staked Sol'
      WHEN mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Crypto.com Staked Sol'
      WHEN mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Bybit Staked Sol'
      WHEN mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Binance Staked Sol'
    END as token,
    mint_amount / POWER(10, 9) as mint,
    0 as burn
  FROM
    solana.defi.fact_token_mint_actions
  WHERE
    mint IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
  UNION
  ALL
  SELECT
    BLOCK_TIMESTAMP,
    CASE
      WHEN mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Bitget Staked Sol'
      WHEN mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Crypto.com Staked Sol'
      WHEN mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Bybit Staked Sol'
      WHEN mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Binance Staked Sol'
    END as token,
    0 as mint,
    burn_amount * -1 / POWER(10, 9) as burn
  FROM
    solana.defi.fact_token_burn_actions
  WHERE
    mint IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
),
price AS (
  SELECT
    price
  FROM
    crosschain.price.ez_prices_hourly
  WHERE
    token_address IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
  ORDER BY
    hour DESC
  LIMIT
    1
), daily_flows AS (
  SELECT
    BLOCK_TIMESTAMP :: date as date,
    token,
    SUM(mint) as mints,
    SUM(burn) as burns
  FROM
    mintburn
  GROUP BY
    1,
    2
)
SELECT
  date,
  token,
  mints,
  burns,
  (mints + burns) as net_action,
  SUM(mints) OVER (
    PARTITION BY token
    ORDER BY
      date
  ) as cumulative_minted,
  SUM(burns) OVER (
    PARTITION BY token
    ORDER BY
      date
  ) as cumulative_burned,
  SUM(mints + burns) OVER (
    PARTITION BY token
    ORDER BY
      date
  ) as supply,
  supply * p.price as supply_usd
FROM
  daily_flows
  CROSS JOIN price p
ORDER BY
  date DESC,
  token;