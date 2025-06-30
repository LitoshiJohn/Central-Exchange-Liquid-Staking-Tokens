-- forked from Bybit staked Sol  @ https://flipsidecrypto.xyz/studio/queries/b50795d3-be5e-4b6f-87bb-4f687d79ebf1

-- forked from Binance staked Sol @ https://flipsidecrypto.xyz/studio/queries/0f06167a-2def-4d58-9691-28d9c8385488

WITH user_metrics AS (
  SELECT
    owner as user_address,
    COUNT(DISTINCT tx_id) as transaction_count,
    AVG(balance) as avg_balance,
    MAX(ABS(balance - pre_balance)) as max_transaction_size,
    DATEDIFF(
      'day',
      MIN(block_timestamp),
      MAX(block_timestamp)
    ) as holding_period,
    CASE
      WHEN COUNT(DISTINCT tx_id) > 5 THEN 1
      ELSE 0
    END as activity_score,
    CASE
      WHEN AVG(balance) > (
        SELECT
          AVG(balance)
        FROM
          solana.core.fact_token_balances
        WHERE
          mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX'
          AND block_timestamp >= DATEADD('day', -60, CURRENT_TIMESTAMP)
      ) THEN 1
      ELSE 0
    END as balance_score,
    CASE
      WHEN DATEDIFF(
        'day',
        MIN(block_timestamp),
        MAX(block_timestamp)
      ) > 30 THEN 1
      ELSE 0
    END as holding_score,
    CASE
      WHEN MAX(ABS(balance - pre_balance)) > (
        SELECT
          PERCENTILE_CONT(0.95) WITHIN GROUP (
            ORDER BY
              ABS(balance - pre_balance)
          )
        FROM
          solana.core.fact_token_balances
        WHERE
          mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX'
          AND block_timestamp >= DATEADD('day', -60, CURRENT_TIMESTAMP)
      ) THEN 1
      ELSE 0
    END as transaction_size_score
  FROM
    solana.core.fact_token_balances
  WHERE
    mint = 'CDCSoLckzozyktpAp9FWT3w92KFJVEUxAU7cNu2Jn3aX'
    AND block_timestamp >= DATEADD('day', -60, CURRENT_TIMESTAMP)
  GROUP BY
    1
),
scored_users AS (
  SELECT
    user_address,
    transaction_count,
    avg_balance,
    max_transaction_size,
    holding_period,
    activity_score,
    balance_score,
    holding_score,
    transaction_size_score,
    (
      activity_score + balance_score + holding_score + transaction_size_score
    ) as total_score,
    CASE
      WHEN (
        activity_score + balance_score + holding_score + transaction_size_score
      ) = 4 THEN 'Power User'
      WHEN (
        activity_score + balance_score + holding_score + transaction_size_score
      ) = 3 THEN 'Active User'
      WHEN (
        activity_score + balance_score + holding_score + transaction_size_score
      ) = 2 THEN 'Regular User'
      WHEN (
        activity_score + balance_score + holding_score + transaction_size_score
      ) = 1 THEN 'Casual User'
      ELSE 'Inactive User'
    END as user_category
  FROM
    user_metrics
)
SELECT
  user_category,
  COUNT(user_address) as number_of_wallets,
  AVG(transaction_count) as avg_activity_count,
  AVG(max_transaction_size) as avg_max_transaction_size,
  AVG(holding_period) as avg_holding_period_days,
  AVG(avg_balance) as avg_balance_size,
  -- Percentage of total users in each category
  ROUND(
    100.0 * COUNT(user_address) / SUM(COUNT(user_address)) OVER (),
    2
  ) as percentage_of_users
FROM
  scored_users
GROUP BY
  user_category
ORDER BY
  CASE
    user_category
    WHEN 'Power User' THEN 1
    WHEN 'Active User' THEN 2
    WHEN 'Regular User' THEN 3
    WHEN 'Casual User' THEN 4
    WHEN 'Inactive User' THEN 5
  END DESC; 

 

