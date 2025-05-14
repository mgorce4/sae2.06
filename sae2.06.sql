--moyenne1
select ROUND(AVG(subtotal),2) as average from orders;

--moyenne2
select ROUND(AVG(subtotal),2) as average 
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