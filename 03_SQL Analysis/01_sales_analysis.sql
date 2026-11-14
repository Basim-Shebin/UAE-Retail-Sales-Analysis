SELECT
    COUNT(*) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,
    ROUND(SUM(Gross_Sales_AED), 2) AS Gross_Sales,
    ROUND(SUM(Revenue_AED), 2) AS Total_Revenue,
    ROUND(SUM(Cost_AED), 2) AS Total_Cost,
    ROUND(SUM(Profit_AED), 2) AS Total_Profit,
    ROUND(
        SUM(Profit_AED) / SUM(Revenue_AED) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM sales
WHERE Order_Status = 'Delivered';

SELECT
    City,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Revenue_AED), 2) AS Total_Revenue_AED,
    ROUND(SUM(Profit_AED), 2) AS Total_Profit_AED
FROM sales
WHERE Order_Status = 'Delivered'
GROUP BY City
ORDER BY Total_Revenue_AED DESC;


SELECT
    p.Category,
    COUNT(*) AS Total_Orders,
    SUM(s.Quantity) AS Units_Sold,
    ROUND(SUM(s.Revenue_AED), 2) AS Total_Revenue_AED,
    ROUND(SUM(s.Profit_AED), 2) AS Total_Profit_AED,
    ROUND(
        SUM(s.Profit_AED) / SUM(s.Revenue_AED) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM sales s
JOIN products p
    ON s.Product_ID = p.Product_ID
WHERE s.Order_Status = 'Delivered'
GROUP BY p.Category
ORDER BY Total_Revenue_AED DESC;

SELECT
    MONTH(Order_Date) AS Month_Number,
    MONTHNAME(Order_Date) AS Month_Name,
    ROUND(SUM(Revenue_AED), 2) AS Monthly_Revenue_AED,
    ROUND(SUM(Profit_AED), 2) AS Monthly_Profit_AED
FROM sales
WHERE Order_Status = 'Delivered'
GROUP BY
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY Month_Number;


SELECT
    c.Customer_Segment,
    COUNT(DISTINCT s.Customer_ID) AS Total_Customers,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(s.Revenue_AED), 2) AS Total_Revenue_AED,
    ROUND(
        SUM(s.Revenue_AED) /
        COUNT(DISTINCT s.Customer_ID),
        2
    ) AS Revenue_Per_Customer_AED
FROM sales s
JOIN customers c
    ON s.Customer_ID = c.Customer_ID
WHERE s.Order_Status = 'Delivered'
GROUP BY c.Customer_Segment
ORDER BY Total_Revenue_AED DESC;


SELECT
    Sales_Channel,
    COUNT(*) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    ROUND(SUM(Revenue_AED), 2) AS Total_Revenue_AED,
    ROUND(SUM(Profit_AED), 2) AS Total_Profit_AED
FROM sales
WHERE Order_Status = 'Delivered'
GROUP BY Sales_Channel
ORDER BY Total_Revenue_AED DESC;


SELECT
    CASE
        WHEN Discount_Pct = 0 THEN 'No Discount'
        WHEN Discount_Pct <= 0.05 THEN 'Up to 5%'
        WHEN Discount_Pct <= 0.10 THEN '6% to 10%'
        WHEN Discount_Pct <= 0.15 THEN '11% to 15%'
        ELSE 'Above 15%'
    END AS Discount_Group,

    COUNT(*) AS Total_Orders,

    ROUND(SUM(Revenue_AED), 2) AS Total_Revenue_AED,

    ROUND(SUM(Profit_AED), 2) AS Total_Profit_AED,

    ROUND(
        SUM(Profit_AED) / SUM(Revenue_AED) * 100,
        2
    ) AS Profit_Margin_Percentage

FROM sales
WHERE Order_Status = 'Delivered'
GROUP BY Discount_Group
ORDER BY
    MIN(Discount_Pct);
    


SELECT
    Product_Name,
    Category,
    Total_Revenue_AED,
    RANK() OVER (
        ORDER BY Total_Revenue_AED DESC
    ) AS Revenue_Rank
FROM (
    SELECT
        p.Product_Name,
        p.Category,
        SUM(s.Revenue_AED) AS Total_Revenue_AED
    FROM sales s
    JOIN products p
        ON s.Product_ID = p.Product_ID
    WHERE s.Order_Status = 'Delivered'
    GROUP BY p.Product_ID, p.Product_Name, p.Category
) AS Product_Sales
ORDER BY Revenue_Rank
LIMIT 5;


WITH Monthly_Sales AS (
    SELECT
        MONTH(Order_Date) AS Month_Number,
        MONTHNAME(Order_Date) AS Month_Name,
        SUM(Revenue_AED) AS Monthly_Revenue
    FROM sales
    WHERE Order_Status = 'Delivered'
    GROUP BY
        MONTH(Order_Date),
        MONTHNAME(Order_Date)
),

Revenue_Comparison AS (
    SELECT
        Month_Number,
        Month_Name,
        Monthly_Revenue,

        LAG(Monthly_Revenue) OVER (
            ORDER BY Month_Number
        ) AS Previous_Month_Revenue

    FROM Monthly_Sales
)

SELECT
    Month_Name,
    ROUND(Monthly_Revenue, 2) AS Revenue_AED,
    ROUND(Previous_Month_Revenue, 2) AS Previous_Month_Revenue,

    ROUND(
        (Monthly_Revenue - Previous_Month_Revenue)
        / NULLIF(Previous_Month_Revenue, 0) * 100,
        2
    ) AS Growth_Percentage

FROM Revenue_Comparison
ORDER BY Month_Number;

