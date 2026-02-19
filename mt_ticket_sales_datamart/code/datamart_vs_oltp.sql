-- I. Total sales by production 
---- Data Mart 

SELECT p.title AS Production, SUM(f.TotalAmount) AS Total_Sales  
FROM group13_fact_ticketpurchase f  
JOIN group13_dim_production p ON f.production_id = p.production_id  
GROUP BY p.title  
ORDER BY Total_Sales DESC;  

---- OLTP 

SELECT p.title AS OLTP_Production, SUM (tp.totalamount) AS OLTP_Total_Sales  
FROM ops$yyang00.production p  
JOIN ops$yyang00.performance pf ON p."P#" = pf."P#"  
JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#"  
GROUP BY p.title  
ORDER BY OLTP_Total_Sales DESC;  

--II. Monthly Sales by Theatre 
---- Data Mart 

SELECT t.name AS Theatre, tm.Year, TO_CHAR(TO_DATE(tm.Month, 'MM'), 'FMMonth') AS Month, SUM(f.TotalAmount) AS Monthly_Sales   
FROM group13_fact_ticketPurchase f   
JOIN group13_dim_theatre t ON f.theatre_id = t.theatre_id   
JOIN group13_dim_time tm ON f.time_id = tm.time_id   
GROUP BY t.name, tm.Year, tm.Month   
ORDER BY tm.Year, tm.Month;  

---- OLTP 

SELECT  t.name AS Theatre, EXTRACT(YEAR FROM pf.pdate) AS Year, TO_CHAR(pf.pdate,'Month') AS Month, SUM(tp.totalamount) AS Monthly_Sales  
FROM ops$yyang00.theatre t  
JOIN ops$yyang00.performance pf ON t."THEATRE#" = pf."THEATRE#"  
JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#"  
GROUP BY t.name, EXTRACT(YEAR FROM pf.pdate), TO_CHAR(pf.pdate,'Month')  
ORDER BY Year, Month;  

--III. Top-spending clients by theatre 
---- Data Mart 

SELECT t.name AS Theatre, (c.title || '.' || c.name) AS Client, SUM(f.TotalAmount) AS Total_Spent   
FROM group13_fact_ticketpurchase f   
JOIN group13_dim_theatre t ON f.theatre_id = t.theatre_id   
JOIN group13_dim_client c ON f.client_id = c.client_id   
GROUP BY t.theatre_id, t.name, c.title, c.name   
HAVING SUM(f.TotalAmount) = (   
	SELECT MAX(SUM(f2.TotalAmount))   
	FROM group13_fact_ticketpurchase f2   
	WHERE f2.theatre_id = t.theatre_id   
GROUP BY f2.client_id )   
ORDER BY t.name;   

---- OLTP 

SELECT  t.name AS Theatre, c.name AS Client, SUM(tp.totalamount) AS Total_Spent   
FROM ops$yyang00.theatre t   
JOIN ops$yyang00.performance pf ON t."THEATRE#" = pf."THEATRE#"   
JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#"   
JOIN ops$yyang00.client c  ON tp."CLIENT#" = c."CLIENT#"   
GROUP BY t."THEATRE#", t.name, c.name   
HAVING SUM(tp.totalamount) = (   
	SELECT MAX(client_total)  
	FROM ( SELECT tp2."CLIENT#", SUM(tp2.totalamount) AS client_total  
		FROM ops$yyang00.ticketpurchase tp2  
		JOIN ops$yyang00.performance pf2 ON tp2."PER#" = pf2."PER#"			
	WHERE pf2."THEATRE#" = t."THEATRE#"    
	GROUP BY tp2."CLIENT#"  
)) ORDER BY t.name;    


-- Index creation 

CREATE INDEX idx_fact_analysis_theatre_client  
               ON group13_fact_ticketpurchase (theatre_id, client_id, TotalAmount); 

 
