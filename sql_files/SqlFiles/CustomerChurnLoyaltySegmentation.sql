/* --Customer Churn and Loyalty Segmentation*/

SELECT
-- Customer ID, name, and email
  cu.customer_id,
  CONCAT(cu.first_name, " ", cu.last_name) AS customer_name,
  TRIM(cu.email) AS customer_email,
  
-- Email Analysis
  CASE
    WHEN email LIKE "%gmail%" OR email LIKE "%hotmail%" THEN "B2C"
    ELSE "B2B"
  END AS type_client,
  
-- Country Client
  CASE
    WHEN country IN ("Italy","Spain","Germany","France","Portugal") THEN "EMEA"
    WHEN country IN ("USA","Brazil") THEN "AMER"
    ELSE "Unknown"
  END AS Business_region,

-- The date of their first order and last order
  IFNULL(MIN(DATE(o.order_date)), "No records") AS first_order,
  IFNULL(MAX(DATE(o.order_date)), "No records") AS last_order,
  
-- Quantity of orders (Fixed missing comma)
  COUNT(o.order_id) AS quantity_orders,
  
-- The total number of days between their first and last order (customer activity span)
  IFNULL(TIMESTAMPDIFF(DAY, MIN(o.order_date), MAX(o.order_date)), "No records") AS customer_span,
  
-- The average number of days between their orders (for customers with more than one order)     
  IFNULL(ROUND(
    CASE
      WHEN COUNT(o.order_id) > 1 THEN DATEDIFF(MAX(o.order_date), MIN(o.order_date)) / (COUNT(o.order_id) - 1)
      ELSE NULL
    END, 2), 0) AS avg_days_between_orders,
      
-- A churn risk segment using CASE
  CASE 
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), "2023-12-12") > 180 THEN "High Risk"
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), "2023-12-12") BETWEEN 90 AND 180 THEN "Medium Risk"
    WHEN TIMESTAMPDIFF(DAY, MAX(o.order_date), "2023-12-12") < 90 THEN "Low Risk"
    ELSE "Unknown"
  END AS customer_risk,
  
-- A loyalty segment using CASE 
  CASE
    WHEN COUNT(o.order_id) > 3 THEN "Loyal"
    WHEN COUNT(o.order_id) BETWEEN 1 AND 3 THEN "Regular"
    WHEN COUNT(o.order_id) = 0 THEN "Low"
    ELSE "Unknown"
  END AS customer_loyalty

-- Join and order lines
FROM Customers AS cu 
LEFT JOIN Orders AS o 
  ON cu.customer_id = o.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, cu.email
ORDER BY cu.last_name ASC;