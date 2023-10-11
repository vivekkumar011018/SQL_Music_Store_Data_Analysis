-- SQL Project


 -- Digital Music Store Analysis
/*
Objective :- 
 The main objective of this project is to analyse digital music stores data, so that with the help of insights the store can grow its business. 
 By finding answers to some questions, store get to know how the business is going and what should be implemented.
*/
/*
About Data :-
 > So, digital music store have multiple datasets which holds the information about 
      1. their customer who frequently bought products.
      2. their employees who is working on his store.
      3. the music like album, genre, media_type, playlist, etc.
      4. invoices of their products of sold music.
*/
Model (Schema) of the Data :- 




Analysis :-

Q1: Who is the senior most employee based on job title? 

SELECT CONCAT(first_name, " ", last_name) as Employee FROM employee
ORDER BY levels desc limit 1

Ans1: Mohan Madan

Q2: Which countries have the most Invoices?

SELECT billing_country, COUNT(invoice_id) AS count FROM invoice
GROUP BY billing_country
ORDER BY count DESC 
LIMIT 1

Ans2: USA with 131 Invoices.

Q3: What are top 3 values of total invoice?

SELECT * FROM invoice
ORDER BY total DESC LIMIT 3

Ans3: Top 3 values are 23.76 and 19.8

Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals.

SELECT billing_city, round(SUM(total),2) AS total_invoice FROM invoice
GROUP BY billing_city ORDER BY total_invoice DESC LIMIT 1

Ans4: Prague with 273.24

Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.

SELECT CONCAT(t1.first_name," ", t1.last_name) AS `Customer Name`, ROUND(SUM(t2.total),2) AS total_amount FROM customer t1
JOIN invoice t2 
ON t1.customer_id = t2.customer_id
GROUP BY t1.customer_id, t1.first_name, t1.last_name
ORDER BY total_amount DESC
LIMIT 1;

Ans5: František Wichterlová with 144.54

Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
    Return your list ordered alphabetically by email starting with A.

select distinct email, first_name, last_name from customer
join invoice
on customer.customer_id = invoice.customer_id
join invoice_line
on invoice.invoice_id = invoice_line.invoice_id
join track
on invoice_line.track_id = track.track_id
join genre
on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email

Ans 6: Got 59 rows.

Q7: Let's invite the artists who have written the most rock music in our dataset. 
    Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.name, count(track.track_id) as `total track` from artist
join album
on artist.artist_id = album.artist_id
join track
on album.album_id = track.album_id
join genre
on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.name
order by `total track` desc limit 10;

Q8: Return all the track names that have a song length longer than the average song length. 
    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

Q9: Find how much amount spent by each customer on top artist? Write a query to return customer name, artist name and total spent.

with top_artist AS(
-- fetch only top artist name, id
select artist.artist_id, artist.name,  SUM(invoice_line.quantity * invoice_line.unit_price) as total_sales from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id, artist.name
order by total_sales desc limit 1
)
select customer.customer_id, customer.first_name, customer.last_name, round(SUM(invoice_line.quantity * invoice_line.unit_price),2) as total_spent
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join top_artist on top_artist.artist_id = album.artist_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total_spent desc

Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
     with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
     the maximum number of purchases is shared return all Genres.


select * from (with datas as (select genre.name, customer.country, COUNT(invoice_line.quantity) as `total purchases` from customer
join invoice
on customer.customer_id = invoice.customer_id
join invoice_line
on invoice.invoice_id = invoice_line.invoice_id
join track
on invoice_line.track_id = track.track_id
join genre
on track.genre_id = genre.genre_id
group by genre.name, customer.country)
select *, ROW_NUMBER() OVER(partition by country order by `total purchases` desc) as `value` from datas) t
where t.value = 1 order by t.country asc, `total purchases` desc


Q11: Write a query that determines the customer that has spent the most on music for each country. 
     Write a query that returns the country along with the top customer and how much they spent. 
     For countries where the top amount spent is shared, provide all customers who spent this amount.

select * from  (select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, round(SUM(invoice.total),2) as total_spent,
ROW_NUMBER() OVER(partition by invoice.billing_country order by SUM(invoice.total) desc) as row_no from customer
join invoice on customer.customer_id = invoice.customer_id
group by 1,2,3,4) t
where t.row_no = 1
order by t.billing_country asc, t.total_spent desc
