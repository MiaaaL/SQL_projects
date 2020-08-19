##Which actors have the first name ‘Scarlett’?

SELECT * FROM actor
WHERE first_name = 'Scarlett';


##Which actors have the last name ‘Johansson’?

SELECT * FROM actor
WHERE last_name = 'Johansson';


##How many distinct actors last names are there?

SELECT COUNT(distinct(last_name)) 
FROM actor;

##Which last names appear more than once?

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1
ORDER BY COUNT(last_name) DESC;

##How many total rentals occurred in May?

SELECT COUNT(distinct(rental_id))
FROM rental
WHERE rental_date LIKE '2005-05-%' ;


##How many staff processed rentals in May?
##How many staffs processed rentals in May?

SELECT count(distinct(staff_id))
FROM rental
WHERE rental_date LIKE '2005-05-%';


##Which staff processed the most rentals in May?

SELECT rental.staff_id, staff.last_name, staff.first_name, COUNT(distinct(rental_id))
FROM rental
INNER JOIN staff
ON rental.staff_id = staff.staff_id
GROUP BY rental.staff_id
ORDER BY COUNT(rental_id) DESC
LIMIT 1;


##Which customer paid the most rental in August?

SELECT payment.customer_id, customer.last_name, customer.first_name, COUNT(payment.payment_id) AS 'Total number of rental',SUM(payment.amount) AS 'Total rental payment'
FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
WHERE payment.payment_date LIKE '2005-08-%'
GROUP BY payment.customer_id
ORDER BY SUM(payment.amount) DESC
Limit 1;


##A summary of rental total amount by month.

SELECT MONTH(payment_date), YEAR(payment_date), SUM(amount) 
FROM PAYMENT
GROUP BY MONTH(payment_date), YEAR(payment_date);


## Which actor has appeared in the most films? use SET keywords

SELECT film_actor.actor_id, actor.first_name, actor.last_name, COUNT(distinct(film_id)) AS '# of films' from film_actor
LEFT JOIN actor
ON film_actor.actor_id = actor.actor_id
GROUP BY film_actor.actor_id
ORDER BY count(distinct(film_id)) DESC
LIMIT 1;


## Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address.

SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address
ON staff.address_id = address.address_id; 


## List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT title, COUNT(actor_id) AS 'The # of actors'
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY title
ORDER BY 2 DESC;

## How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, film.film_id, COUNT(inventory_id) AS 'Copies of the film'
FROM inventory
JOIN film
ON inventory.film_id = film.film_id
Where film.title = 'hunchback impossible'
GROUP BY film.film_id;

## Using the tables payment and customer and the JOIN command, 	
	#list the total paid by each customer. List the customers alphabetically by last name:

SELECT last_name, first_name, customer.customer_id, sum(amount) AS 'Total amount paid'
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY 3
ORDER BY last_name;