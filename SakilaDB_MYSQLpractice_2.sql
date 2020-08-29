use sakila;

------------------------------------------------------------------------------
# Part 1
------------------------------------------------------------------------------ 
 
# Is 'Academy Dinosaur' available for rent from Store 1?
 
# Step 1: which copies are at Store 1?

	SET @Academy_Dinosaur_film_id = (
    SELECT film_id
	FROM film
    WHERE title = 'Academy Dinosaur');
    
    SELECT @Academy_Dinosaur_film_id;
    
    SELECT inventory_id 
    FROM inventory
    WHERE film_id = @Academy_Dinosaur_film_id and store_id = 1;
    
-- Step 2: pick an inventory_id to rent:
  #2
-- Insert a record to represent Mary Smith renting 'Academy Dinosaur' from Mike Hillyer at Store 1 today .
	CREATE TABLE rental_for_fun LIKE rental; # duplicate a MySQL table
	INSERT rental_for_fun SELECT * FROM rental; 
    
    select * from rental_for_fun;
    
    SET @Mary_Smith_CUSTOMER_ID =(
    SELECT customer_id from customer
    WHERE first_name = 'Mary' and last_name = 'Smith') ; #find out the customer id of Mary Smith
    
	Set @Mike_hillyer_staff_id =(
    SELECT staff_id from staff
    WHERE first_name = 'Mike' and last_name = 'Hillyer'); #find out the staff id of Mike Hillyer
    
    INSERT INTO rental_for_fun(rental_date,inventory_id,customer_id,staff_id,last_update) #Insert new record
    values (CURDATE(),2,@Mary_Smith_CUSTOMER_ID,@Mike_hillyer_staff_id,CURDATE());
    
    Select * from rental_for_fun;
    
	
-- When is 'Academy Dinosaur' due?
 
-- Step 1: what is the rental duration?

	Set @Academy_Dinosaur_rental_duration =(
    SELECT rental_duration FROM film
    WHERE film_id = 1);
    
    Select @Academy_Dinosaur_rental_duration;
    
-- Step 2: Which rental are we referring to -- the last one.

	Set @the_last_one = (
    SELECT rental_id from rental_for_fun #find the last rental
    order by rental_id desc
    limit 1);
    
-- Step 3: add the rental duration to the rental date. #or add it the the "return date"?

	UPDATE rental_for_fun
    SET return_date = date_add(rental_date,interval 6 day)
    WHERE rental_id = @the_last_one;
    
    select * from rental_for_fun;
    
 
-- What is that average length of all the films in the sakila DB?

	SET @AVG_LENGTH = (
		SElECT AVG(length) FROM film);
	
    SELECT @AVG_LENGTH;
 
-- What is the average length of films by category?
	    
    
    Select a.category_id, name, a.average_film_length
    FROM category
	JOIN (
		SELECT film_category.category_id, AVG(film.length) as 'average_film_length'FROM film
		JOIN film_category
		ON film.film_id = film_category.film_id
		GROUP BY film_category.category_id) a
    ON a.category_id = category.category_id;
    
    
 
-- Which film categories are long? Long = lengh is longer than the average film length

	SELECT b.category_id, b.name, b.average_film_length, @AVG_LENGTH
    FROM
		(Select a.category_id, name, a.average_film_length
		FROM category
		JOIN (
			SELECT film_category.category_id, AVG(film.length) as 'average_film_length'FROM film
			JOIN film_category
			ON film.film_id = film_category.film_id
			GROUP BY film_category.category_id) a
		ON a.category_id = category.category_id) b 
	WHERE b.average_film_length > @AVG_LENGTH;
 
 
 
 
 drop table new_rental; # delete TABLE created
------------------------------------------------------------------------------
# Part 2
------------------------------------------------------------------------------
 
-- 1a. Display the first and last names of all actors from the table actor.
 
	SELECT first_name, last_name 
	FROM actor;
 
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
	SELECT upper(concat(first_name,' ',last_name)) as 'Actor Name'
    FROM actor;
    
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
--  	What is one query would you use to obtain this information?

	SELECT actor_id, first_name, last_name
    FROM actor
    WHERE first_name LIKE 'Joe%';
 
-- 2b. Find all actors whose last name contain the letters GEN:
	
    SELECT actor_id, first_name, last_name
    FROM actor
    WHERE last_name LIKE '%gen%';
 
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
	
	SELECT last_name, first_name, actor_id
    FROM actor
    WHERE last_name LIKE '%li%'
    ORDER BY last_name, first_name;
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
 
	SELECT country_id, country 
    FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh','China');
    
 
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
 
	CREATE TABLE actor_for_fun LIKE actor; # duplicate a MySQL table
	INSERT actor_for_fun SELECT * FROM actor; 
    
    #或者用create temporary table
    create temporary table temp_actor as (
    select actor_id, first_name, last_name
    from actor
    );
    
    ALTER table actor_for_fun 
    Add middle_name varchar(20) after first_name;
    
    SELECT * FROM actor_for_fun;

-- 3b. You realize that some of these actors have tremendously long last names.
--  Change the data type of the middle_name column to blobs.

	ALTER TABLE actor_for_fun
	MODIFY COLUMN middle_name blob(50) not null;
 
-- 3c. Now delete the middle_name column.

	ALTER TABLE actor_for_fun
    DROP COLUMN middle_name;
    
    Select * from actor_for_fun;
 
-- 4a. List the last names of actors, as well as how many actors have that last name.
	
    SELECT last_name, count(distinct(first_name)) AS '# of actors have this last name'
    FROM actor
    GROUP BY last_name;
    
-- 4b. List last names of actors and the number of actors who have that last name,
-- 	but only for names that are shared by at least two actors

	SELECT *
    From
		(SELECT last_name,
		CASE WHEN 
		count(distinct(first_name)) >1 THEN count(distinct(first_name)) 
		END AS Number_of_actors_who_have_this_last_name
		FROM actor
		GROUP BY last_name)b
    WHERE Number_of_actors_who_have_this_last_name IS NOT NULL
    Order by 2 desc;
    
    #or 
    
	SELECT last_name, count(distinct(first_name)) AS '# of actors have this last name'
    FROM actor
    GROUP BY last_name
    Having count(distinct(first_name))>1;
    
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
-- 	the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
 
	UPDATE actor_for_fun
    Set first_name = 'HARPO'
    Where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
    
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct
-- name after all!
-- In a single query, if the first name of the actor is currently HARPO,
-- change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what
-- the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR
-- TO MUCHO GROUCHO, HOWEVER!
-- (Hint: update the record using a unique identifier.)

	update actor_for_fun
	set first_name = (
	case
		when first_name="HARPO" then "GROUCHO"
		else "MUCHO GROUCHO"
	end
    )
    where actor_id = 172 ;
    
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

	CREATE TABLE address_for_fun LIKE address;
    
    Describe address;
    
    
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
 
    SELECT first_name, last_name, address
    from staff
    join address
    on staff.address_id = address.address_id;
 
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
    
    select p.staff_id, first_name, last_name, sum(amount)
    From payment p
    join staff s
    on s.staff_id = p.staff_id
	where payment_date between '2005-08-01' and '2005-08-31'
    group by p.staff_id;
 
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
 
    Select title, count(distinct(actor_id)) as 'the number of actors'
    From film_actor fa
    join film f
    on fa.film_id = f.film_id
    group by title;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
 
	select * from inventory;
    select * from film;
    
    Set @film_id_hunchback_impossible =(
		Select film_id
		from film
        where title = 'Hunchback Impossible');
        
	Select count(distinct(inventory_id))
    from inventory
    where film_id = @film_id_hunchback_impossible;
    
    #or
    
    Select count(film.title)
    from film
    join inventory
    on film.film_id = inventory.film_id
    where film.title = 'Hunchback Impossible';
 
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- 	List the customers alphabetically by last name:
 
	SELECT * FROM payment;
	Select * from customer;
    
    Select last_name, first_name,pay.customer_id,sum(amount)
    from payment pay
    join customer cus
    on pay.customer_id = cus.customer_id
	group by pay.customer_id
    order by 1;
    
 
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
--  films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of
--  movies starting with the letters K and Q whose language is English.
 
	select * from language;
    select * from film;
    
    Set @english_language_id = (
		select language_id 
        from language
        where name = 'English');
        
    Select title
    from film
    WHERE title like 'K%' or title like 'Q%' and language_id = @english_language_id;
    
    #or
    
    Select title
    from film
    WHERE title like 'K%' or title like 'Q%' and language_id = (
    (
		select language_id 
        from language
        where name = 'English')
        );
 
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
 
	Select * from film;
    Select * from film_actor;
    select * from actor;
    
    Select last_name,first_name
    From actor
    Where actor_id in
    (Select actor_id 
		from film_actor
		where film_id =
			(Select film_id
			From film
			Where title = 'Alone Trip'))
	Order by last_name;
 
 
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and
-- 	email addresses of all Canadian customers.
-- 	Use joins to retrieve this information.
 
	select * from customer; #address_id
    select * from country; #country_id
    select * from city; # city_id country_id
    select * from address; #city_id address_id
 
	Set @canada_country_id = (
		select country_id 
        from country
        where country = 'Canada');
        

	Select city_id
    from city
	where country_id = @canada_country_id;
    
    Select address_id
    from address
    where city_id in (
		Select city_id
		from city
		where country_id = @canada_country_id);
        
	Select first_name, last_name, email
    From customer
    where address_id in (
		 Select address_id
		from address
		where city_id in (
			Select city_id
			from city
			where country_id = @canada_country_id));
        
	
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
--  Identify all movies categorized as famiy films.
 
	select * from category;
    select * from film;
    select * from film_category;
    
    Set @family_category_id = (
		select category_id
        from category
        where name ='Family');
        
	Select film_id 
    from film_category
    where category_id = @family_category_id;
    
    Select name as 'Category'
    from category
    where category_id = @family_category_id;
    
    
    With category as 
		(Select name as 'Category'
		from category
		where category_id = @family_category_id)
    Select title, film_id,Category
    from film, category
    where film_id in (
		Select film_id 
		from film_category
		where category_id = @family_category_id); 
        
        
-- 7e. Display the most frequently rented movies in descending order.
 
	Select title, rental_rate
    from film
    order by rental_rate desc;
 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
	
    select * from rental;
    select * from store;
    select * from staff;
    select * from payment;
 
	select staff.store_id, How_much_business_each_store_brought_in
    from staff
    join (
		select staff_id,sum(amount) as 'How_much_business_each_store_brought_in'
		from payment
		group by staff_id
			) a
	on staff.staff_id = a.staff_id;
 
-- 7g. Write a query to display for each store its store ID, city, and country.
 
	select * from store; #store_id, address_id
    select * from address; #address_id, city_id
    select * from city; #city_id, city, country_id
    select * from country; #country_id, country

    Select b.store_id, b.city, country
    from 
		(Select store_id, city, country_id
		from city
		join (
			select store_id,city_id
			from store
			join address
			on store.address_id = address.address_id) a
		on city.city_id = a.city_id) b
	join country
    on b.country_id = country.country_id;
        
 
-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
 
	select * from payment; # rental_id amount
    select * from rental; #rental_id inventory_id
    select * from inventory; #inventory_id film_id
    select * from film_category; #film_id category_id
    select * from category; #category_id name
    
    
    Select name as 'Categoty_name',sum(c.amount) as 'Total_amount'
    from category
    join
		(select category_id, b.film_id, b.rental_id, b.amount
		from film_category
			join
				(Select film_id, a.rental_id, a.amount
				from inventory
				join (
					select payment.rental_id, inventory_id, amount
					from payment
					join rental
					on payment.rental_id = rental.rental_id) a
				on inventory.inventory_id = a.inventory_id) b
			on film_category.film_id = b.film_id) c
	on category.category_id = c.category_id
    group by name
    order by sum(c.amount) desc;
    
 
-- 8a. In your new role as an executive, you would like to have an easy way of viewing
--  	the Top five genres by gross revenue. Use the solution from the problem above to create a view.
--  	If you haven't solved 7h, you can substitute another query to create a view.
  
  Create view Top_five_genres_by_gross_revenue as
	select Categoty_name, Total_amount
    from (
		Select name as 'Categoty_name',sum(c.amount) as 'Total_amount'
    from category
    join
		(select category_id, b.film_id, b.rental_id, b.amount
		from film_category
			join
				(Select film_id, a.rental_id, a.amount
				from inventory
				join (
					select payment.rental_id, inventory_id, amount
					from payment
					join rental
					on payment.rental_id = rental.rental_id) a
				on inventory.inventory_id = a.inventory_id) b
			on film_category.film_id = b.film_id) c
	on category.category_id = c.category_id
    group by name
    order by sum(c.amount) desc) d
    limit 5;
      
  
-- 8b. How would you display the view that you created in 8a?
 
	Select * from Top_five_genres_by_gross_revenue;
 
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
 
	Drop View Top_five_genres_by_gross_revenue;