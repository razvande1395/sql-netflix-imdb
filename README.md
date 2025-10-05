# sql-netflix-imdb
Refresher on SQL, a brief cleanup/analysis of a netflix dataset with votes based on IMDB user ratings


# SQL Netflix + IMDb data analysis

 
**Stack** PostgreSQL + DBeaver

## What’s inside
- Constrained table + light cleaning (normalize `type`, handle empty age certs, fill missing votes with 0)
- Simple slices: **Top 10 (votes ≥ 10k)**, **avg score + median votes per cert**, **ratings by decade**
- **Top 5 by IMDb score in every age certification** (window function)
- A saved view you can use in Tableau/Power BI.

## How to run
1) Import the CSV into Postgres (I did it with DBeaver - table - import data - select the csv into table `netflix.titles` and then mapped columns by name)  
2) Run sql/netflix-movies-imdb.sql
