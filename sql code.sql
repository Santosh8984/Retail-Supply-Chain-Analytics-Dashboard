 1--Write a GROUP BY query to get total Units_Sold and total Revenue_USD per
Product_Category.
select distinct(Product_Category),
concat(round(sum(Units_Sold)/1000000,1),"M")As Total_Unit_Sold,
concat(round(Sum(Revenue_USD)/1000000000,2),"B") As Total_Revenue_Usd
from retail_data
group by Product_Category
order by Total_Unit_Sold,Total_Revenue_Usd Desc;

 2--Write a query to find average Lead_Time_Days per Supplier_ID, showing only
suppliers with average lead time above 7 days (use HAVING).
select distinct(Supplier_Id) as unique_supplier,
round(avg(Lead_Time_Days),0) as avg_led_time
from retail_data
group by unique_supplier
having	avg_led_time>7;

3-- Write a query to COUNT the number of products per Warehouse_Location and their
average Utilization_Rate.
select
Product_Category,
Warehouse_Location,
round(avg(Utilization_Rate),2) AS avg_utilization
from retail_data
group by Product_Category,Warehouse_Location
order by avg_utilization desc;

Using a window function (RANK() OVER PARTITION BY Product_Category ORDER
BY Revenue_USD DESC), find the top 3 revenue-generating products within each
category.
WITH RankedProducts AS (
    SELECT
        Product_Category,
        Revenue_USD,
        RANK() OVER (
            PARTITION BY Product_Category
            ORDER BY Revenue_USD DESC
        ) AS Revenue_Rank
    FROM retail_data
)

SELECT
    Product_Category,
    Revenue_USD,
    Revenue_Rank
FROM RankedProducts
WHERE Revenue_Rank <= 3
ORDER BY Product_Category, Revenue_Rank
;

Write a CTE that flags suppliers with below-average On_Time_Delivery_Rate AND
above-average Supply_Disruption_Risk — these are your highest-priority suppliers
to renegotiate with.

    
WITH Supplier_Performance AS (
    SELECT
        Supplier_ID,
        On_Time_Delivery_Rate,
        Supply_Disruption_Risk,
        (SELECT AVG(On_Time_Delivery_Rate) FROM retail_data) AS Avg_On_Time_Delivery,
        (SELECT AVG(Supply_Disruption_Risk) FROM retail_data) AS Avg_Disruption_Risk
    FROM retail_data
)

SELECT
    Supplier_ID,
    On_Time_Delivery_Rate,
    Supply_Disruption_Risk,
    'Highest Priority for Renegotiation' AS Supplier_Status
FROM Supplier_Performance
WHERE On_Time_Delivery_Rate < Avg_On_Time_Delivery
  AND Supply_Disruption_Risk > Avg_Disruption_Risk
ORDER BY Supply_Disruption_Risk DESC,
         On_Time_Delivery_Rate ASC;


Supplier reliability scorecard — For each Supplier_ID, 
calculate average On_Time_Delivery_Rate, average Lead_Time_Days, 
and total Revenue_USD generated from their products.
 Filter suppliers with Supplier_Rating below 3.
select 
	Supplier_ID,
    Supplier_Rating,
    round(avg(On_Time_Delivery_Rate),2) As Avg_On_Time_Delivery,
    round(avg(Lead_Time_Days),0) as Avg_Led_Time_Days,
    CONCAT(ROUND(SUM(Revenue_USD) / 100000, 1), 'K') AS Total_Revenue
    from retail_data
    where Supplier_Rating <3
    group by Supplier_ID,Supplier_Rating
    order by Total_Revenue Desc;

Warehouse profitability — Find total Revenue_USD, total Profit_USD,
 and profit margin (Profit/Revenue * 100) per Warehouse_Location,
 ordered by margin descending.
SELECT
    Warehouse_Location,
    CONCAT(ROUND(SUM(Revenue_USD) / 1000000000, 1), 'B') AS Total_Revenue,
    CONCAT(ROUND(SUM(Profit_USD) / 1000000000, 1), 'B') AS Total_Profit,
    ROUND((SUM(Profit_USD) / SUM(Revenue_USD)) * 100, 2) AS Profit_Margin
FROM retail_data
GROUP BY Warehouse_Location
ORDER BY Profit_Margin DESC;

Transportation mode cost efficiency — For each Transportation_Mode,
 compute average Shipping_Cost_USD per unit sold (Shipping_Cost_USD / Units_Sold) 
 and average Delivery_Time_Days.
select 
 Transportation_Mode,
 round(avg(Delivery_Time_Days)) as Avg_Delivery_Time_Days,
 round(Avg(Shipping_Cost_USD/ Units_Sold),2) as  Avg_Shipping_Cost_Per_Unit
 from retail_data
 group by  Transportation_Mode;
