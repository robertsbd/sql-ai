# sql-ai
Exploring querying databases with natural language queries

An exploration using elisp (at the moment) of how to query databases using natural language.

# example output 

--------------
User query
--------------

What is the number of orders by product category in 2017?

--------------
AI Generated SQL
--------------

SELECT c.CategoryName, COUNT(DISTINCT o.OrderID) as NumberOfOrders
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE strftime('%Y', o.OrderDate) = '2017'
GROUP BY c.CategoryName;

--------------
Output from database
--------------

(Beverages 159)
(Condiments 100)
(Confections 150)
(Dairy Products 151)
(Grains/Cereals 100)
(Meat/Poultry 83)
(Produce 62)
(Seafood 139)
