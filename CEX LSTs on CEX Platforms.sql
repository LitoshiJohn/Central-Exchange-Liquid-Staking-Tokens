WITH cex_labels AS (
  SELECT
    DISTINCT label as exchange_name,
    address as cex_address
  FROM
    solana.core.dim_labels
  WHERE
    label_type = 'cex'
    AND label IN ('binance','bybit','crypto.com','bitget')
),

token_interactions AS (
  SELECT
    DISTINCT l.exchange_name,
    CASE
      WHEN t.mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Yes'
      ELSE 'No'
    END as bgSOL,
    CASE
      WHEN t.mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Yes'
      ELSE 'No'
    END as cdcSOL,
    CASE
      WHEN t.mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Yes'
      ELSE 'No'
    END as bbSOL,
    CASE
      WHEN t.mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Yes'
      ELSE 'No'
    END as bnSOL
  FROM
    cex_labels l
    JOIN solana.core.fact_transfers t
      ON l.cex_address = t.tx_from
  WHERE
    t.mint IN (
      'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY',
      'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX',
      'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B',
      'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
    )
    AND t.block_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP)
)

SELECT
  exchange_name,
  MAX(bgSOL) as bgSOL,
  MAX(cdcSOL) as cdcSOL,
  MAX(bbSOL) as bbSOL,
  MAX(bnSOL) as bnSOL
FROM
  token_interactions
GROUP BY
  exchange_name
ORDER BY
  exchange_name;