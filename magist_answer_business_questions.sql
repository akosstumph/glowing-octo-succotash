
# What categories of tech products does Magist have?

SELECT DISTINCT
    pcnt.product_category_name_english AS product_name
FROM
    products AS pro
        INNER JOIN
    product_category_name_translation AS pcnt ON pro.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
ORDER BY product_name;

# How many products of these tech categories have been sold, what percentage does it represent from the whole ? 

# TOTAL number of TECH products

SELECT 
    COUNT(DISTINCT oi.product_id) AS TOTAL
FROM
    products AS pro
        INNER JOIN
    product_category_name_translation AS pcnt ON pro.product_category_name = pcnt.product_category_name
        INNER JOIN
    order_items AS oi ON pro.product_id = oi.product_id
WHERE
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

# Percentage does represent from the TOTAL number

SELECT 
    3390 / COUNT(DISTINCT oi.product_id) * 100 AS percantage_of_total
FROM
    products AS pro
        INNER JOIN
    product_category_name_translation AS pcnt ON pro.product_category_name = pcnt.product_category_name
        INNER JOIN
    order_items AS oi ON pro.product_id = oi.product_id;


# AVG price of TECH products

SELECT 
    AVG(oi.price) AS avg_price
FROM
    products AS pro
        INNER JOIN
    product_category_name_translation AS pcnt ON pro.product_category_name = pcnt.product_category_name
        INNER JOIN
    order_items AS oi ON pro.product_id = oi.product_id
WHERE
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

# Are expensive tech products popular?

SELECT 
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony') AS tech_prod,
    COUNT(CASE
        WHEN oi.price > 105 THEN 1
    END) AS cheap_product,
    COUNT(CASE
        WHEN oi.price < 105 THEN 1
    END) AS expensive_product
FROM
    products AS pro
        INNER JOIN
    product_category_name_translation AS pcnt ON pro.product_category_name = pcnt.product_category_name
        INNER JOIN
    order_items AS oi ON pro.product_id = oi.product_id
WHERE
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
GROUP BY tech_prod;

# In relation to the sellers: 25
# How many months of data are included in the magist database?

SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
FROM
    orders;

# How many sellers are there? 3095
SELECT
COUNT(DISTINCT seller_id) AS numb_of_sellers
FROM sellers;

# How many Tech sellers are there? 454
SELECT
COUNT(DISTINCT s.seller_id) AS numb_tech_sellers
FROM sellers AS s
JOIN 
order_items AS oi ON s.seller_id = oi.seller_id
JOIN 
products AS pr ON oi.product_id = pr.product_id
JOIN 
product_category_name_translation as pcn ON pcn.product_category_name = pr.product_category_name
WHERE pcn.product_category_name_english IN  ('audio','electronics','computers_accessories','pc_gamer','computers','tablets_printing_image','telephony');

# TOTAL sellers? 

SELECT
COUNT(DISTINCT s.seller_id) AS total_sellers
FROM sellers AS s
JOIN 
order_items AS oi ON s.seller_id = oi.seller_id
JOIN 
products AS pr ON oi.product_id = pr.product_id
JOIN 
product_category_name_translation as pcn ON pcn.product_category_name = pr.product_category_name;

# % FINAL 
SELECT
454/COUNT(DISTINCT s.seller_id)*100 AS percentage_of_numb_tech_sellers
FROM sellers AS s
JOIN 
order_items AS oi ON s.seller_id = oi.seller_id
JOIN 
products AS pr ON oi.product_id = pr.product_id
JOIN 
product_category_name_translation as pcn ON pcn.product_category_name = pr.product_category_name;

# What is the total amount earned by all sellers?

SELECT
ROUND(SUM(price),3) total_amount_earned_by_all_sellers
FROM order_items;

# What is the total amount earned by all Tech sellers?

SELECT 
    ROUND(SUM(price), 3) total_amount_earned_by_tecg_sellers
FROM
    order_items AS oi
        JOIN
    products AS p ON p.product_id = oi.product_id
        JOIN
    product_category_name_translation AS pcnt ON pcnt.product_category_name = p.product_category_name
WHERE
    pcnt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');


# Can you work out the average monthly income of all sellers?

SELECT
ROUND(SUM(price),3)/12 total_amount_earned_by_tech_sellers
FROM order_items AS oi
JOIN
products AS p ON p.product_id = oi.product_id
JOIN
product_category_name_translation as pcnt ON pcnt.product_category_name = p.product_category_name
JOIN orders AS ord ON ord.order_id = oi.order_id;


# Can you work out the average monthly income of Tech sellers?

SELECT
ROUND(SUM(price),3)/12 total_amount_earned_by_tech_sellers
FROM order_items AS oi
JOIN
products AS p ON p.product_id = oi.product_id
JOIN
product_category_name_translation as pcnt ON pcnt.product_category_name = p.product_category_name
JOIN orders AS ord ON ord.order_id = oi.order_id
WHERE pcnt.product_category_name_english IN  ('audio','electronics','computers_accessories','pc_gamer','computers','tablets_printing_image','telephony');


# In relation to the delivery time:
# What’s the average time between the order being placed and the product being delivered?
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS avg_delivery_days
FROM
    orders;

# How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    CASE
        WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN 'On time'
        ELSE 'Delayed'
    END AS delivery_status,
    COUNT(order_id) AS orders_count
FROM
    orders
WHERE
    order_status = 'delivered'
GROUP BY delivery_status;
	-- on time 89805
    -- delayed 6673

# Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT 
    CASE
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) > 100
        THEN
            '> 100 day Delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) >= 8
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 100
        THEN
            '1 week to 100 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) > 3
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 8
        THEN
            '3-7 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) > 1
        THEN
            '1 - 3 days delay'
        ELSE '<= 1 day delay'
    END AS 'delay_range',
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(*) AS product_count
FROM
    orders a
        LEFT JOIN
    order_items b ON a.order_id = b.order_id
        LEFT JOIN
    products c ON b.product_id = c.product_id
WHERE
    DATEDIFF(order_estimated_delivery_date,
            order_delivered_customer_date) > 0
GROUP BY delay_range
ORDER BY weight_avg DESC;


 









