#Using sakila as my schema
use sakila;

# 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name
from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ',last_name) as "Actor Name" from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like '%LI%'
order by last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column
# in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
select * from actor;

#using varchar
alter table actor
add column Description VARCHAR(50) AFTER first_name;

#modifying the column now into blob 
alter table actor
modify column Description blob;

#deleting the column name Description 
alter table actor
drop column Description;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'count'
from actor
group by last_name;

#b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as 'count'
from actor
group by last_name
having Count  > 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor 
set first_name = 'Harpo'
where first_name ='GROUCHO' and last_name='WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor 
set first_name = 'GROUCHO'
where first_name = 'Harpo' and last_name ='WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

#describe sakila.address <----------------ANSWER!!!!!!!!

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address
from staff as s left join address as a on s.address_id = a.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select payment.staff_id, staff.first_name, staff.last_name, payment.amount,payment.payment_date
from staff inner join payment on 
staff.staff_id = payment.staff_id and payment_date like '%2005-08%';

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.title as "Movie title", count(film_actor.actor_id) as 'Number of Actors'
from film_actor
inner join film
on film_actor.film_id = film.film_id
group by film.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, (
	select count(*) from inventory
    where film.film_id = inventory.inventory_id) as "Number of Copies"
    from film
    where title ='Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
select * from customer;

select customer.first_name, customer.last_name, sum(payment.amount) as `Total paid`
from customer
inner join payment
on customer.customer_id = payment.customer_id
group by customer.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K
# and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film where title
like 'k%' or title like 'Q%'
and title in 
(
select title
from film
where language_id= 1
);

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from film_actor;
select * from actor;
select * from film;

select first_name, last_name
from actor 
where actor_id in 
(
	select actor_id 
	from film_actor
	where film_id in 
    (
		select film_id
		from film
		where title = 'Alone Trip'
)
);

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select * from country;
select * from customer;
select * from address;
select * from city;


select customer.first_name, customer.last_name, customer.email
	from customer 
		join address
			on customer.address_id = address.address_id
				join city
					on city.city_id = address.city_id
						join country
							on country.country_id = city.country_id
								where country = 'Canada';


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title, description
from film
where film_id in 
(
	select film_id 
    from film_category
    where category_id in 
    (
		select category_id
        from category
        where name = 'Family'
    )
);


#7e. Display the most frequently rented movies in descending order.
select * from rental;
select * from inventory;
select * from film;

select film.title, count(rental_id) as "Number of Times Rented"
from rental
join inventory
on rental.inventory_id = inventory.inventory_id
join film 
on inventory.film_id = film.film_id
group by film.title
order by `Number of Times Rented` desc;


#7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
select * from payment;
select * from inventory;
select * from rental;

select store.store_id, sum(amount)
from payment
join rental
on payment.rental_id = rental.rental_id
join inventory
on inventory.inventory_id = rental.inventory_id
join store
on store.store_id = inventory.store_id
group by store.store_id;


#7g. Write a query to display for each store its store ID, city, and country.
select * from store;
select * from city;
select * from country;
select * from address;

select s.store_id, c.city, co.country
from store s 
join address a 
on s.address_id = a.address_id
join city c 
on c.city_id = a.city_id
join country co
on co.country_id = c.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

select c.name as "Genre", sum(p.amount) as "Gross"
from category c 
	join film_category fc
			on c.category_id = fc.category_id
	join inventory i 
			on fc.film_id = i.film_id
	join rental r 
		on i.inventory_id = r.inventory_id
	join payment p 
		on r.rental_id = p.rental_id
	group by c.name
    order by Gross limit 5;
    
    
	#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
    #Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_5_genre_revenue as
select c.name as "Genre", sum(p.amount) as "Gross"
from category c 
	join film_category fc
			on c.category_id = fc.category_id
	join inventory i 
			on fc.film_id = i.film_id
	join rental r 
		on i.inventory_id = r.inventory_id
	join payment p 
		on r.rental_id = p.rental_id
	group by c.name
    order by Gross limit 5;

#8b. How would you display the view that you created in 8a?
select * from top_5_genre_revenue;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_5_genre_revenue;
