
/* Query 1 - query used for first insight*/

WITH t
     AS (SELECT f.title     Movie,
                c.NAME      Category,
                r.rental_id Rented_out
         FROM   category c
                JOIN film_category fc
                  ON c.category_id = fc.category_id
                JOIN film f
                  ON fc.film_id = f.film_id
                JOIN inventory i
                  ON f.film_id = i.film_id
                JOIN rental r
                  ON i.inventory_id = r.inventory_id
         WHERE  c.NAME = 'Animation'
                 OR c.NAME = 'Comedy'
                 OR c.NAME = 'Classics'
                 OR c.NAME = 'Children'
                 OR c.NAME = 'Family'
                 OR c.NAME = 'Music')
SELECT t.movie,
       t.category,
       Count(t.rented_out) Rented
FROM   t
GROUP  BY 1,
          2
ORDER  BY 2,
          1 
----------------------------------------------------------------------------------------------------------------------------
/* Query 2 - query used for second insight*/

WITH t
     AS (SELECT f.title,
                c.NAME,
                f.rental_duration,
                Ntile(4)
                  OVER (
                    ORDER BY f.rental_duration) standard_quartile
         FROM   category c
                JOIN film_category fc
                  ON c.category_id = fc.category_id
                JOIN film f
                  ON fc.film_id = f.film_id
         WHERE  c.NAME = 'Animation'
                 OR c.NAME = 'Comedy'
                 OR c.NAME = 'Classics'
                 OR c.NAME = 'Children'
                 OR c.NAME = 'Family'
                 OR c.NAME = 'Music')
SELECT NAME,
       standard_quartile,
       Count(rental_duration) rental_duration
FROM   t
GROUP  BY 1,
          2
ORDER  BY 1,
          2 
----------------------------------------------------------------------------------------------------------------------------
/* Query 3 - query used for third insight*/

WITH t AS
(
         SELECT   p.customer_id,
                           Concat(c.first_name,' ',c.last_name) full_name,
                  Sum(amount)                                   pay_amount
         FROM     customer c
         JOIN     payment p
         ON       c.customer_id = p.customer_id
         GROUP BY 1,
                  2
         ORDER BY 3 DESC limit 10)
SELECT   Date_trunc('month',payment_date) pay_mon,
         t.full_name,
         Count(amount) pay_countpermon,
         Sum(amount)   pay_amount
FROM     t
JOIN     payment p
ON       t.customer_id = p.customer_id
GROUP BY 1,
         2
ORDER BY 2
----------------------------------------------------------------------------------------------------------------------------
/* Query 4 - query used for forth insight*/

WITH t AS
(
         SELECT   p.customer_id,
                           Concat(c.first_name,' ',c.last_name) full_name,
                  Sum(amount)                                   pay_amount
         FROM     customer c
         JOIN     payment p
         ON       c.customer_id = p.customer_id
         GROUP BY 1,
                  2
         ORDER BY 3 DESC limit 10), t2 AS
(
         SELECT   Date_trunc('month',payment_date) pay_mon,
                  t.full_name,
                  Count(amount) pay_countpermon,
                  Sum(amount)   pay_amount
         FROM     t
         JOIN     payment p
         ON       t.customer_id = p.customer_id
         GROUP BY 1,
                  2
         ORDER BY 2)
SELECT   pay_mon ,
         full_name ,
         pay_amount ,
         lag(pay_amount)OVER fn              AS prev_mon ,
         pay_amount - lag(pay_amount)OVER fn AS mon_def
FROM     t2 window fn                        AS (partition BY full_name ORDER BY full_name)
ORDER BY 2,
         1

