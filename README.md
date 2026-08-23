#Overview: Raw rental listings data often contains formatting inconsistencies, non-numeric price symbols, missing values, and extreme price outliers that cause schema mismatches or distort downstream reporting.

This project implements a robust ETL pipeline that cleans and sanitizes 48,000+ raw Airbnb listings, elevating dataset completeness from 78% to 99.5%, before ingesting the structured data into MySQL and rendering interactive Power BI reports.

Languages : Python. Data Processing & ETL : Pandas, Numpy. Database and Ingestion : MySQL, SQLAlchemy. Analytics : JupyterNotebook

#Pipeline Features: Ingests raw listing data directly from MySQL staging tables into Python pandas DataFrames. Standardizes listing names, host names, and neighborhoods while handling anonymous listings and special characters. Eliminates price anomalies per borough using Interquartile Range. Ensures clean, well-typed DataFrames ready for direct SQL export and Power BI dashboard integration.
