SELECT * FROM employee;

-- 1. Who is the senior most employee based on job title?

SELECT 
    *
FROM
    EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?

SELECT 
    BILLING_COUNTRY, COUNT(*) AS MOST_INVOICES_COUNTRY
FROM
    INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY MOST_INVOICES_COUNTRY DESC;

-- 3. What are top 3 values of total invoice?

SELECT 
    TOTAL
FROM
    INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

-- 4. Which city has the best customers? We would like to throw a promotional 
-- Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals

SELECT 
    BILLING_CITY, ROUND(SUM(TOTAL), 2) AS INVOICE_TOTAL
FROM
    INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money

SELECT 
    C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, ROUND(SUM(TOTAL),2) AS MONEY_SPENT
FROM
    CUSTOMER AS C
        JOIN
    INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY MONEY_SPENT DESC LIMIT 1;

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

SELECT DISTINCT
    C.EMAIL, C.FIRST_NAME, C.LAST_NAME
FROM
    CUSTOMER AS C
        JOIN
    INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID
        JOIN
    INVOICE_LINE AS IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE
    TRACK_ID IN (SELECT 
					TRACK_ID
				 FROM
					TRACK AS T
						JOIN
					GENRE AS G ON T.GENRE_ID = G.GENRE_ID
				WHERE
					G.NAME LIKE 'Rock')
ORDER BY EMAIL;

-- 7.Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT 
    A.ARTIST_ID, A.NAME, COUNT(A.ARTIST_ID) AS TOTAL_TRACK_COUNT
FROM
    TRACK AS T
        JOIN
    ALBUM AS AB ON AB.ALBUM_ID = T.ALBUM_ID
        JOIN
    ARTIST AS A ON A.ARTIST_ID = AB.ARTIST_ID
        JOIN
    GENRE AS G ON G.GENRE_ID = T.GENRE_ID
WHERE
    G.NAME LIKE 'Rock'
GROUP BY A.ARTIST_ID
ORDER BY TOTAL_TRACK_COUNT DESC
LIMIT 10;

-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first

SELECT 
    NAME, MILLISECONDS AS LENGTH_OF_SONG
FROM
    TRACK
WHERE
    MILLISECONDS > (SELECT 
            AVG(MILLISECONDS) AS AVG_LENGTH
        FROM
            TRACK)
ORDER BY LENGTH_OF_SONG DESC;

-- 9. Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent

SELECT 
    C.FIRST_NAME AS Customer_First_Name,
    C.LAST_NAME AS Customer_Last_Name,
    AR.NAME AS Artist_Name,
    ROUND(SUM(IL.UNIT_PRICE * IL.QUANTITY), 2) AS Total_Spent
FROM
    CUSTOMER AS C
        JOIN  INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID
        JOIN  INVOICE_LINE AS IL ON I.INVOICE_ID = IL.INVOICE_ID
        JOIN  TRACK AS T ON IL.TRACK_ID = T.TRACK_ID
        JOIN  ALBUM AS AL ON T.ALBUM_ID = AL.ALBUM_ID
        JOIN  ARTIST AS AR ON AL.ARTIST_ID = AR.ARTIST_ID
GROUP BY AR.ARTIST_ID , C.CUSTOMER_ID
ORDER BY Total_Spent DESC , C.FIRST_NAME , C.LAST_NAME , AR.NAME;

-- 10. Find the primary music genre for each country based on the highest number of purchases. 
-- If multiple genres share the highest purchase count in a country, include all of them in the result.

WITH PURCHASE_CTE AS (
    SELECT
        COUNTRY,
        G.NAME AS GENRE_NAME,
        COUNT(*) AS PURCHASE_COUNT,
        RANK() OVER (PARTITION BY COUNTRY ORDER BY COUNT(*) DESC) AS RANK_NUM
    FROM
        INVOICE AS I
        JOIN CUSTOMER AS C ON I.CUSTOMER_ID = C.CUSTOMER_ID
        JOIN INVOICE_LINE AS IL ON I.INVOICE_ID = IL.INVOICE_ID
        JOIN TRACK AS T ON IL.TRACK_ID = T.TRACK_ID
        JOIN GENRE AS G ON T.GENRE_ID = G.GENRE_ID
    GROUP BY
        COUNTRY, G.NAME
)
SELECT
    COUNTRY,
    GENRE_NAME AS TOP_GENRE, PURCHASE_COUNT
FROM
    PURCHASE_CTE
WHERE
    Rank_NUM = 1
ORDER BY
    COUNTRY;
    
-- 11. Write a query to find the customer who has spent the most on music in each country. 
-- Return the country alongside the top-spending customer and the total amount they spent. 
-- If multiple customers share the highest spending amount in a country, 
-- include all such customers in the result.


WITH CUSTOMER_CTE AS (
    SELECT
        C.CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        BILLING_COUNTRY,
        ROUND(SUM(I.TOTAL),2) AS TOTAL_SPENDING,
        ROW_NUMBER() OVER(PARTITION BY BILLING_COUNTRY ORDER BY SUM(I.TOTAL) DESC) AS ROW_NO
    FROM
        INVOICE AS I
        JOIN CUSTOMER AS C ON C.CUSTOMER_ID = I.CUSTOMER_ID
    GROUP BY
        C.CUSTOMER_ID,FIRST_NAME,LAST_NAME,BILLING_COUNTRY
)
SELECT * FROM CUSTOMER_CTE WHERE ROW_NO =1 ORDER BY BILLING_COUNTRY;
