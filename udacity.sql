/* Which actors have the longest sum of rental time durations */
SELECT
	concat(a.first_name, ' ', a.last_name) name,
	sum(f.rental_duration) ttl_rent_time
FROM actor AS a
LEFT JOIN film_actor AS fm
	ON fm.actor_id = a.actor_id
LEFT JOIN film as f
	ON f.film_id = fm.film_id
GROUP BY a.actor_id
ORDER BY ttl_rent_time DESC;

 
/* most popular film category per customer */

with t1 as (
    SELECT concat(cu.first_name,' ',cu.last_name,cu.customer_id) customer, c.name category, count(f.*) cat_rentals
FROM category as c
JOIN film_category as fc
    ON fc.category_id = c.category_id
JOIN film as f
    ON f.film_id = fc.film_id
JOIN inventory as i
    on i.film_id = f.film_id
JOIN rental as r
    ON r.inventory_id = i.inventory_id
JOIN customer as cu
    on cu.customer_id = r.customer_id
GROUP BY 1, c.name),

t2 as (SELECT customer, max(cat_rentals) most_pop_cat
FROM t1
GROUP BY 1)

SELECT t1.*, t2.most_pop_cat
FROM t1
JOIN t2 ON
    t2.customer = t1.customer
WHERE cat_rentals = most_pop_cat;

/* most popular category top 10 customers */

with t1 as (
    SELECT concat(cu.first_name,cu.last_name,cu.customer_id) customer, c.name category, count(f.*) cat_rentals
FROM category as c
JOIN film_category as fc
    ON fc.category_id = c.category_id
JOIN film as f
    ON f.film_id = fc.film_id
JOIN inventory as i
    on i.film_id = f.film_id
JOIN rental as r
    ON r.inventory_id = i.inventory_id
JOIN customer as cu
    on cu.customer_id = r.customer_id
GROUP BY 1, c.name),

t2 as (SELECT customer, max(cat_rentals) most_pop_cat
FROM t1
GROUP BY 1),

t3 as (SELECT
    concat(c.first_name,c.last_name,c.customer_id) customer,
    sum(p.amount) amount,
    RANK() OVER(ORDER BY sum(p.amount) DESC) as rank
FROM customer as c
JOIN payment as p
    ON
        p.customer_id = c.customer_id
GROUP BY 1),

t4 as (SELECT
    customer, amount, rank
FROM t3
WHERE rank < 11)

SELECT t1.*
FROM t1
JOIN t2 ON
    t2.customer = t1.customer
INNER JOIN t4
    ON t4.customer = t1.customer
WHERE cat_rentals = most_pop_cat
ORDER BY t4.rank;



/* performance per staff member */

SELECT
        concat(s.first_name,' ',s.last_name,s.staff_id) staff_mem,
        date_trunc('month', p.payment_date) as date, sum(p.amount) as amount
FROM staff as s
JOIN payment as p
    ON p.staff_id = s.staff_id
GROUP BY 1, 2;

