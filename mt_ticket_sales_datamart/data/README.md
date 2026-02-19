**Data Source**

This directory contains the tables extracted from the ops$yyang00 schema. In the original system, only records involved in at least one ticket sale are retained in the data mart. However, the files provided here can be used as the source tables for all analysis and ETL steps described in the project.

The data corresponds to the following original OLTP tables:

* Theatre(Theatre#, Name, Street, Town, County, MainTel)
* Production(P#, Title, ProductionDirector, PlayAuthor)
* Performance(Per#, P#, Theatre#, pDate, pHour, pMinute, Comments)
* Client(Client#, title, name, Street, Town, County, telNo, e-mail)
* TicketPurchase(Purchase#, Client#, Per#, PaymentMethod, DeliveryMethod, TotalAmount)

These files serve as the input to build the ticket‑sales data mart and can be treated as direct substitutes for the tables in the source schema.
