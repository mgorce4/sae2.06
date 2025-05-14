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
order by p.name,order_id