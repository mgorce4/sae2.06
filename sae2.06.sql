DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id INTEGER,
    name TEXT,
    category TEXT,
    price NUMERIC,
    rating NUMERIC
);
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    subtotal NUMERIC,
    date DATE,
    client_id INTEGER
);
DROP TABLE IF EXISTS clients;
CREATE TABLE clients (client_id INT, name TEXT);
INSERT INTO orders(
        order_id,
        product_id,
        quantity,
        subtotal,
        date,
        client_id
    )
VALUES (1, 1, 1, 99, '2021-10-04', 48),
    (2, 5, 2, 20, '2021-10-05', 47),
    (3, 4, 4, 56, '2021-11-06', 47),
    (4, 1, 2, 198, '2021-12-11', 48),
    (5, 3, 4, 28, '2021-12-31', 48),
    (6, 3, 20, 140, '2021-12-31', 48),
    (7, 1, 1, 99, '2022-01-01', 47);
INSERT INTO products(product_id, name, category, price, rating)
VALUES (1, 'table', 'bois', 99, 3.6),
    (2, 'chaise', 'bois', 29, 4.7),
    (3, 'torchon', 'textile', 7, 2.3),
    (4, 'serviette', 'textile', 14, 3.1),
    (5, 'poubelle', 'plastique', 10, 4.2);
INSERT INTO clients(client_id, name)
VALUES (47, 'Tux'),
    (48, 'Linus');


--moyenne1
select ROUND(AVG(subtotal),2) as average from orders;

--moyenne2
select category, ROUND(AVG(subtotal),2) as average 
from orders o join products p on o.product_id=p.product_id join clients c on o.client_id = c.client_id
GROUP BY category
ORDER BY average desc, category asc;

--super
with avgTotal as(
    select ROUND(AVG(subtotal),2) as average from orders
)
select o.order_id, o.date, p.name, p.category, o.subtotal
from orders o join products p on o.product_id=p.product_id join clients c on o.client_id = c.client_id  
WHERE subtotal >= (SELECT average FROM avgTotal)
order by order_id;

--mention
WITH avgTotal AS (
    SELECT ROUND(AVG(subtotal), 2) AS average FROM orders
)
SELECT 
    o.order_id, 
    o.subtotal,
    CASE 
        WHEN o.subtotal >= (SELECT average FROM avgTotal) THEN 'Bonne'
        ELSE 'Mauvaise'
    END AS case
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN clients c ON o.client_id = c.client_id
ORDER BY o.order_id;

--infra

with avgRating as(
    select AVG(rating) as rating from products
)
select DISTINCT ON (p.name) o.order_id , o.date, p.name, p.category, o.subtotal, p.rating
from orders o join products p on o.product_id=p.product_id join clients c on o.client_id = c.client_id  
where rating<= (select rating from avgRating)
order by p.name,order_id;

--premier_jour
with premier_jour as(
    select date from orders order by date asc LIMIT 1
)
select sum(subtotal) as subtotal from orders 
where date = (select date from premier_jour);

--chers
with max_price as (
    select price from products order by price desc limit 1
)
select name , price 
from products 
where price = (select price from max_price)
order by name;

--chiffre1
select c.name, o.date , sum(subtotal) as subtotal 
from orders o join products p on o.product_id=p.product_id join clients c on o.client_id = c.client_id
group by c.name , o.date
order by c.name, o.date

--chiffre2
SELECT 
    TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS month,
    SUM(subtotal) AS subtotal
FROM orders
GROUP BY month
ORDER BY month ASC;

--chiffre3
SELECT
    name,
    TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS month,
    SUM(subtotal) AS subtotal
FROM orders o join clients c on o.client_id = c.client_id
GROUP BY name, month
ORDER BY name asc, month ASC;

--cumuls1
SELECT 
    date,
    SUM(subtotal) AS revenue,
    SUM(SUM(subtotal)) OVER (ORDER BY date) AS cumulative_revenue
FROM orders
GROUP BY date
ORDER BY date ASC;

--cumuls2
SELECT
    TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS month,
    SUM(subtotal) AS revenue,
    SUM(SUM(subtotal)) OVER (ORDER BY DATE_TRUNC('month', date)) AS cumulative_revenue
FROM orders 
GROUP BY DATE_TRUNC('month', date)
ORDER BY DATE_TRUNC('month', date) ASC;

--chiffre4
WITH mois AS (
    SELECT DISTINCT DATE_TRUNC('month', date) AS month FROM orders
),
categories AS (
    SELECT DISTINCT category FROM products
),
ventes AS (
    SELECT 
        DATE_TRUNC('month', o.date) AS month,
        p.category,
        SUM(o.subtotal) AS subtotal
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY DATE_TRUNC('month', o.date), p.category
)
SELECT 
    TO_CHAR(m.month, 'YYYY-MM') AS month,
    c.category,
    COALESCE(v.subtotal, 0) AS subtotal
FROM mois m
JOIN categories c ON TRUE
LEFT JOIN ventes v ON v.month = m.month AND v.category = c.category
ORDER BY m.month ASC, c.category ASC;

