DROP VIEW IF EXISTS v_customer_features;

CREATE VIEW v_customer_features AS
SELECT
  cu.customer_id,
  CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
  
-- Date transformations
  MIN(DATE(o.order_date)) AS first_order,
  MAX(DATE(o.order_date)) AS last_order,
  
-- Quantity of orders
  COUNT(o.order_id) AS quantity_orders,
  
-- The total number of days between their first and last order
  TIMESTAMPDIFF(DAY, MIN(o.order_date), MAX(o.order_date)) AS customer_span,
  
-- The average number of days between their orders     
  ROUND(
    CASE
      WHEN COUNT(o.order_id) > 1 THEN DATEDIFF(MAX(o.order_date), MIN(o.order_date)) / (COUNT(o.order_id) - 1)
      ELSE 0
    END, 2) AS avg_days_between_orders,
      
-- Churn risk segment
  CASE 
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), '2023-12-12') > 180 THEN 'High Risk'
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), '2023-12-12') BETWEEN 90 AND 180 THEN 'Medium Risk'
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), '2023-12-12') < 90 THEN 'Low Risk'
    ELSE 'High Risk'
  END AS customer_risk,
  
-- Loyalty segment 
  CASE
    WHEN COUNT(o.order_id) > 3 THEN 'Loyal'
    WHEN COUNT(o.order_id) BETWEEN 1 AND 3 THEN 'Regular'
    ELSE 'Low'
  END AS customer_loyalty

-- Join and order lines
FROM Customers AS cu 
LEFT JOIN Orders AS o 
  ON cu.customer_id = o.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, cu.email, cu.country;


/* 2. COMPUTING HEALTH SCORE*/
WITH scored_features AS (
    SELECT
        customer_id,
        customer_name,
        -- Recency score
        CASE
            WHEN customer_risk = 'High Risk' THEN 1
            WHEN customer_risk = 'Medium Risk' THEN 2
            WHEN customer_risk = 'Low Risk' THEN 4
            ELSE 0
        END AS recency_score,
        -- Frequency score
        CASE
            WHEN customer_loyalty = 'Low' THEN 1
            WHEN customer_loyalty = 'Regular' THEN 2
            WHEN customer_loyalty = 'Loyal' THEN 4
            ELSE 0
        END AS frequency_score,
        -- Span score
        CASE
            WHEN customer_span IS NULL OR customer_span < 30 THEN 1
            WHEN customer_span BETWEEN 30 AND 90 THEN 2
            WHEN customer_span > 90 THEN 4
            ELSE 0
        END AS monetary_score
    FROM v_customer_features
),
total_scores AS (
    SELECT 
        customer_id,
        customer_name,
        recency_score,   
        frequency_score, 
        monetary_score,  
        (recency_score + frequency_score + monetary_score) AS total_points
    FROM scored_features
)
SELECT
    customer_id,
    customer_name,
    recency_score,
    frequency_score, 
    monetary_score AS monetary_span_score,
    total_points,
    CASE 
        WHEN total_points < 4 THEN 'Non Hiva'
        WHEN total_points BETWEEN 4 AND 7 THEN 'Hiva'
        WHEN total_points > 7 THEN 'Exclusive'
        ELSE 'Unknown'
    END AS customer_health_score
FROM total_scores
ORDER BY total_points DESC, recency_score DESC, frequency_score DESC, monetary_span_score DESC, customer_id ASC;