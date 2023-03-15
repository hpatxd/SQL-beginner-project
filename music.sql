/****** Script for SelectTopNRows command from SSMS  ******/
-- Q1: Who is the senior most employee based on job title? 
SELECT TOP 1
 title,last_name,first_name,levels
FROM [music].[dbo].[employee]
ORDER BY levels DESC

---- Q2: Which countries have the most Invoices?
SELECT billing_country, count(*) as total_invoice, sum(total) as total_amt
FROM music.dbo.invoice
group by billing_country
order by total_amt desc

-- Q3: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals 
select TOP 1 
billing_city, sum(total) as total_amt
from invoice
group by billing_city
order by total_amt desc

-- Q4: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select i.customer_id, first_name, last_name, SUM(total) as total_spending
from invoice as i
inner join customer as c on
i.customer_id = c.customer_id
group by i.customer_id, first_name, last_name
order by total_spending desc

-- Q5: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 

Select distinct email, first_name, last_name, genre.name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'

--SELECT DISTINCT email,first_name, last_name
--FROM customer
--JOIN invoice ON customer.customer_id = invoice.customer_id
--JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
--WHERE track_id IN(
--	SELECT track_id FROM track
--	JOIN genre ON track.genre_id = genre.genre_id
--	WHERE genre.name LIKE 'Rock')

--Q6: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. 

select name, milliseconds,
 (select AVG(milliseconds) as avg_length from track)
from track
where milliseconds > (select AVG(milliseconds) as avg_length from track)
order by milliseconds desc

--Q7: Find how much amount spent by each customer on the artist that has earned the most? Write a query to return customer name, artist name and total spent */
-- 1st, find which artist that has earned the most based on invoiceline

with best_selling_artist as
(
select distinct top 1 artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id, artist.name
order by 3 desc

)
SELECT c.customer_id, c.first_name, c.last_name, bsa.name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY 5 DESC

--Q8: We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 

with popular_genre as
(select count(il.quantity) as total_purchases, i.billing_country, g.name,
 row_number() over(partition by i.billing_country order by count(il.quantity) desc) as RowNo
from invoice_line il
join invoice i on il.invoice_id = i.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
group by  i.billing_country, g.name
)
select *
from popular_genre
where RowNo <=1
order by total_purchases desc

