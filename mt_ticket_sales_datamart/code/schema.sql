CREATE TABLE group13_dim_production (   
production_id NUMBER (5) PRIMARY KEY,   
P# NUMBER (5) NOT NULL,   
Title VARCHAR2(20) NOT NULL); 

CREATE TABLE group13_dim_theatre (   
theatre_id NUMBER (5) PRIMARY KEY,   
Theatre# NUMBER (5) NOT NULL,   
Name VARCHAR2(20) NOT NULL);    

CREATE TABLE group13_dim_Client (   
client_id NUMBER (5) PRIMARY KEY,   
Client# NUMBER (5) NOT NULL,   
Title VARCHAR2(10),   
Name VARCHAR2(30) NOT NULL);  

CREATE TABLE group13_dim_time (   
time_id NUMBER PRIMARY KEY,   
Year NUMBER (4) NOT NULL,   
Month NUMBER (2) NOT NULL);  

CREATE TABLE group13_fact_TicketPurchase (   
production_id NUMBER(5)   
CONSTRAINT fk_group13_dim_production  REFERENCES group13_dim_production(production_id),   
theatre_id NUMBER(5)   
CONSTRAINT fk_group13_dim_theatre  REFERENCES group13_dim_theatre(theatre_id),   
client_id NUMBER(5)   
CONSTRAINT fk_group13_dim_client  REFERENCES group13_dim_client(client_id),   
time_id NUMBER(5)   
CONSTRAINT fk_group13_dim_time  REFERENCES group13_dim_time(time_id),   
TotalAmount NUMBER(10,2),   
CONSTRAINT pk_group13_fact_TicketPurchase  

PRIMARY KEY (production_id, theatre_id, client_id, time_id) );   
