--Who are two the most active rentees and how much did they brought to the Music Shop
SELECT CONCAT(rentees.first_name, ' ', rentees.last_name) AS name_, sum(total_price) AS sum_
FROM Rents
JOIN Rentees
ON rents.rentee_id = rentees.passport_id 
GROUP BY name_
ORDER BY sum_ DESC
LIMIT 2;

--What instrument brought Music Store more money than others in 2024 by being both purchased and rented?
WITH bought AS(
    SELECT concat(i.brand, ' ', i.model) AS sold_item, p.total_price  
    FROM purchases p
    JOIN items_purchases ip
    ON p.id = ip.purchase_id
    JOIN items i
    ON ip.item_id = i.id 
    WHERE date_part('year', payment_date) = 2024
), rented AS(
    SELECT concat(i.brand, ' ', i.model) AS rented_item, r.total_price
    FROM items i
    JOIN items_rents ir
    ON i.id = ir.item_id
    JOIN rents r
    ON ir.rent_id = r.id
    WHERE date_part('year', rented_from) = 2024 AND date_part('year', rented_to) = 2024
)
SELECT *
FROM bought
WHERE sold_item IN (SELECT rented_item FROM rented);
