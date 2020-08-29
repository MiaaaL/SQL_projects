USE sakila;

##1. Which actors have the first name ‘Scarlett’?

SELECT * FROM actor
WHERE first_name = 'Scarlett';


##2. Which actors have the last name ‘Johansson’?

SELECT * FROM actor
WHERE last_name = 'Johansson';


##3.How many distinct actors last names are there?

SELECT COUNT(distinct(last_name)) 
FROM actor;

##4. Which last names appear more than once?

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1
ORDER BY COUNT(last_name) DESC;



##5. How many total rentals occurred in May?

SELECT COUNT(distinct(rental_id))
FROM rental
WHERE rental_date LIKE '2005-05-%' ; # or where month(rental_date) = '05'


##6. How many staff processed rentals in May?
##How many staffs processed rentals in May?

SELECT count(distinct(staff_id))
FROM rental
WHERE rental_date LIKE '2005-05-%';


##7. Which staff processed the most rentals in May?

SELECT rental.staff_id, staff.last_name, staff.first_name, COUNT(distinct(rental_id))
FROM rental
INNER JOIN staff
ON rental.staff_id = staff.staff_id
where month(rental_date) = '05'
GROUP BY rental.staff_id
ORDER BY COUNT(rental_id) DESC
LIMIT 1;








# select all the rentals in May whose amount is higher than the average May payment amount

# use sub-query

select *
from payment 
where amount > (
  select avg(amount)
  from payment
  where month(payment_date) = 5) 
and month(payment_date) = 5;

# SET keyboard

Set @ave_amount_in_may = (
 select avg(amount) 
    from payment
    where month(payment_date) = '05');

select *
from payment 
where amount > @ave_amount_in_may
and month(payment_date) = 5;

# Cartesian JOIN

# A Cartesian join, also known as a Cartesian product, 
# is a join of every row of one table to every row of another table. 
# For example, if table A has 100 rows and is joined with table B, which has 1,000 rows, 
# a Cartesian join will result in 100,000 rows.

select *
from payment a,
 (
  select avg(amount) as avg_amount
  from payment
  where month(payment_date) = 5
     )  b 
where amount > avg_amount
and month(payment_date) = 5; 

# use WITH

with temp as (
     select avg(amount) as avg_amount
  from payment
  where month(payment_date) = 5)
select *
from payment, temp #这里其实等于上面的无序排列
where amount > avg_amount
and month(payment_date) = 5;








##8. Which customer paid the most rental in August?

SELECT payment.customer_id, customer.last_name, customer.first_name, COUNT(payment.payment_id) AS 'Total number of rental',SUM(payment.amount) AS 'Total rental payment'
FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
WHERE payment.payment_date LIKE '2005-08-%'
GROUP BY payment.customer_id
ORDER BY SUM(payment.amount) DESC
Limit 1;

# 8 

# LIMIT n

select a.customer_id, a.first_name, a.last_name, sum(b.amount) as 'Total_Payment'
from customer a
left join payment b
on a.customer_id = b.customer_id
where b.payment_date between '2005-08-01' and '2005-08-31'
group by a.customer_id
order by 4 desc
limit 1;

# use SET

set @max_payment = (
select max(Total_Payment)
from (
 select a.customer_id, a.first_name, a.last_name, sum(b.amount) as 'Total_Payment'
 from customer a
 left join payment b
 on a.customer_id = b.customer_id
 where b.payment_date between '2005-08-01' and '2005-08-31'
 group by a.customer_id) a
);

select @max_payment; 

with temp as ( 
 select a.customer_id, a.first_name, a.last_name, sum(b.amount) as 'Total_Payment'
 from customer a
 left join payment b
 on a.customer_id = b.customer_id
 where b.payment_date between '2005-08-01' and '2005-08-31'
 group by a.customer_id
) 
select *
from temp
where Total_Payment = @max_payment;








##9. A summary of rental total amount by month.

SELECT MONTH(payment_date), YEAR(payment_date), SUM(amount) 
FROM PAYMENT
GROUP BY MONTH(payment_date), YEAR(payment_date);







## 10. Which actor has appeared in the most films? use SET keywords

SELECT film_actor.actor_id, actor.first_name, actor.last_name, COUNT(distinct(film_id)) AS '# of films' 
from film_actor
LEFT JOIN actor
ON film_actor.actor_id = actor.actor_id
GROUP BY film_actor.actor_id
ORDER BY count(distinct(film_id)) DESC
LIMIT 1;


# limit n

SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_films
FROM sakila.film_actor AS fa
JOIN sakila.actor AS a
ON fa.actor_id=a.actor_id
GROUP BY fa.actor_id
ORDER BY 4 DESC
LIMIT 1;

# SET 

SET @max_films = (
   select max(num_films) 
   from (
  SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_films
  FROM sakila.film_actor AS fa
  JOIN sakila.actor AS a
  ON fa.actor_id=a.actor_id
  GROUP BY fa.actor_id
  ORDER BY 4 DESC
 ) t
);

select @max_films; 

SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_films
FROM sakila.film_actor AS fa
JOIN sakila.actor AS a
ON fa.actor_id=a.actor_id
GROUP BY fa.actor_id
having num_films = @max_films;









## 11. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address.

SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address
ON staff.address_id = address.address_id; 


## 12. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT title, COUNT(actor_id) AS 'The # of actors'
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY title
ORDER BY 2 DESC;

## 13. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, film.film_id, COUNT(inventory_id) AS 'Copies of the film'
FROM inventory
JOIN film
ON inventory.film_id = film.film_id
Where film.title = 'hunchback impossible'
GROUP BY film.film_id;

## 14. Using the tables payment and customer and the JOIN command, 	
	#list the total paid by each customer. List the customers alphabetically by last name:

SELECT last_name, first_name, customer.customer_id, sum(amount) AS 'Total amount paid'
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY 3
ORDER BY last_name;