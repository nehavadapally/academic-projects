-- Production Dimension

CREATE SEQUENCE seq_group13_dim_production START WITH 1 INCREMENT BY 1; 

INSERT INTO group13_dim_production   
	SELECT seq_group13_dim_production.NEXTVAL AS production_id, p."P#" AS "P#", INITCAP(TRIM(p.title)) AS Title   
	FROM ( SELECT DISTINCT p."P#", p.title   
		FROM ops$yyang00.production p  
		JOIN ops$yyang00.performance pf ON p."P#" = pf."P#"  
		JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#" ) p;  

-- Theatre Dimension 

CREATE SEQUENCE seq_group13_dim_theatre START WITH 1 INCREMENT BY 1;  

INSERT INTO group13_dim_theatre   
	SELECT seq_group13_dim_theatre.NEXTVAL AS theatre_id, t."THEATRE#" AS "THEATRE#", INITCAP(TRIM(t.name)) AS Name  
	FROM ( SELECT DISTINCT t."THEATRE#", t.name  
		FROM ops$yyang00.theatre t  
		JOIN ops$yyang00.performance pf ON t."THEATRE#" = pf."THEATRE#"  
		JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#" ) t;   

-- Client Dimension 

CREATE SEQUENCE seq_group13_dim_client START WITH 1 INCREMENT BY 1;  

INSERT INTO group13_dim_client   
	SELECT seq_group13_dim_client.NEXTVAL AS client_id, c."CLIENT#" AS "CLIENT#", UPPER(TRIM(c.title)) AS Title, INITCAP(TRIM(c.name)) AS Name   
	FROM ( SELECT DISTINCT c."CLIENT#", c.title, c.name   
		FROM ops$yyang00.client c   
		JOIN ops$yyang00.ticketpurchase tp ON c."CLIENT#" = tp."CLIENT#" ) c;   

-- Time Dimension 

CREATE SEQUENCE seq_group13_dim_time START WITH 1 INCREMENT BY 1;  

INSERT INTO group13_dim_time   
	SELECT seq_group13_dim_time.NEXTVAL, Year, Month   
	FROM (  SELECT DISTINCT EXTRACT(YEAR FROM pf.pdate) AS Year, EXTRACT(MONTH FROM pf.pdate) AS Month   
		FROM ops$yyang00.performance pf   
		JOIN ops$yyang00.ticketpurchase tp ON pf."PER#" = tp."PER#"   
	) pf;  

-- Ticket Purchase Fact 

INSERT INTO group13_fact_ticketPurchase   
SELECT p.production_id, th.theatre_id,c.client_id,tm.time_id, SUM(tp.totalamount) AS TotalAmount FROM ops$yyang00.ticketpurchase tp   
JOIN ops$yyang00.performance pf ON tp."PER#" = pf."PER#"   
JOIN group13_dim_production p ON pf."P#" = p."P#"   
JOIN group13_dim_theatre th ON pf."THEATRE#" = th."THEATRE#"   
JOIN group13_dim_client c ON tp."CLIENT#" = c."CLIENT#"   
JOIN group13_dim_time tm   
	ON EXTRACT(YEAR FROM pf.pdate) = tm.Year   
	AND EXTRACT(MONTH FROM pf.pdate) = tm.Month   
GROUP BY p.production_id, th.theatre_id, c.client_id,tm.time_id;  
