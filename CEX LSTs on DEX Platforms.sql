WITH swaps AS (
  SELECT
    DISTINCT swap_program,
    CASE
      WHEN swap_from_mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY'
      OR swap_to_mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Yes'
      ELSE 'No'
    END as bgSOL,
    CASE
      WHEN swap_from_mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX'
      OR swap_to_mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Yes'
      ELSE 'No'
    END as cdcSOL,
    CASE
      WHEN swap_from_mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B'
      OR swap_to_mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Yes'
      ELSE 'No'
    END as bbSOL,
    CASE
      WHEN swap_from_mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
      OR swap_to_mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Yes'
      ELSE 'No'
    END as bnSOL
  FROM
    solana.defi.ez_dex_swaps
  UNION
  SELECT
    DISTINCT 'Jupiter' as swap_program,
    CASE
      WHEN swap_from_mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY'
      OR swap_to_mint = 'bgSoLfRx1wRPehwC9TyG568AGjnf1sQG1MYa8s3FbfY' THEN 'Yes'
      ELSE 'No'
    END as bgSOL,
    CASE
      WHEN swap_from_mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX'
      OR swap_to_mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX' THEN 'Yes'
      ELSE 'No'
    END as cdcSOL,
    CASE
      WHEN swap_from_mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B'
      OR swap_to_mint = 'Bybit2vBJGhPF52GBdNaQfUJ6ZpThSgHBobjWZpLPb4B' THEN 'Yes'
      ELSE 'No'
    END as bbSOL,
    CASE
      WHEN swap_from_mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85'
      OR swap_to_mint = 'BNso1VUJnh4zcfpZa6986Ea66P6TCp59hvtNJ8b1X85' THEN 'Yes'
      ELSE 'No'
    END as bnSOL
  FROM
    solana.defi.fact_swaps_jupiter_summary
)

SELECT
  swap_program,
  MAX(bgSOL) as bgSOL,
  MAX(cdcSOL) as cdcSOL,
  MAX(bbSOL) as bbSOL,
  MAX(bnSOL) as bnSOL
FROM
  swaps
GROUP BY
  swap_program
ORDER BY
  swap_program