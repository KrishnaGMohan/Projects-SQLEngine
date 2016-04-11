USE AdventureWorks2012
GO

-- Examine data page allocations in the Person.Address table using the new DMF sys.dm_db_database_page_allocations
SELECT * 
FROM sys.dm_db_database_page_allocations(db_id('AdventureWorks2012'), object_id('Person.Address'), 1, null, 'DETAILED')
WHERE page_type_desc = 'DATA_PAGE'

-- enable TF 3604
DBCC TRACEON (3604)
GO

-- format:  dbcc page (<database_id>, <file_id>, <page number>, <level of detail: 0, 1, 2, 3>)

/*
Common page types:

1 - data page
2 - index page
3 and 4 - text pages
8 - GAM page
9 - SGAM page
10 - IAM page
11 - PFS page
*/

--modify the queries below for 

-- view first GAM page in file 1, the first GAM page is page 2 of the data file, verify this by looking at the page type field, 
--m_type.
DBCC PAGE (5, 1, 2, 1)
GO

-- using data from sys.dm_db_database_page_allocations - view data page and review rows and slot array
DBCC PAGE (5, 1, 162, 1)
GO

-- view different format with slot array at end
DBCC PAGE (5, 1, 162, 2)
GO

-- disable TF 3604
DBCC TRACEOFF (3604)
GO





/*
SYS.INDEXES 
SYS.PARTITIONS
SYS.ALLOCATION_UNITS
SYS.SYSTEM_INTERNALS_ALLOCATION_UNITS
SYS.STATS
*/

-- to get a list of partitions and data pages used for a table run this query
SELECT o.name AS table_name
, p.index_id
, i.name AS index_name 
, au.type_desc AS allocation_type, au.data_pages, partition_number
FROM sys.allocation_units AS au
    JOIN sys.partitions AS p ON au.container_id = p.partition_id
    JOIN sys.objects AS o ON p.object_id = o.object_id
    JOIN sys.indexes AS i ON p.index_id = i.index_id AND i.object_id = p.object_id
ORDER BY o.name, p.index_id;

--to get index information
EXEC sp_helpindex 'person.address' --this does not show included columns

--or
select o.object_id, o.name as table_name, c.name as column_name, c.column_id, i.name as index_name, i.index_id, i.type_desc, i.key_ordinal, i.is_included_column 
 from sys.objects o (nolock) 
join sys.columns c (nolock) on o.object_id = c.object_id
join (select i.object_id, name, i.index_id, column_id, type_desc, key_ordinal, is_included_column 
       from sys.indexes i (nolock) join sys.index_columns ic on i.object_id = ic.object_id and i.index_id = ic.index_id ) i
on o.object_id = i.object_id and c.column_id = i.column_id
where o.type ='U' and o.schema_id = 6 and o.name = 'address'
order by index_id, is_included_column, key_ordinal


/*
Type	type_desc
0	HEAP
1	CLUSTERED
2	NONCLUSTERED
3	XML
6	NONCLUSTERED COLUMNSTORE
*/

--Issue the following query to find all the Clustered Indexes on your tables:
SELECT   o.name AS table_name,
         p.index_id,
         i.name AS index_name,
         au.type_desc AS allocation_type,
         au.data_pages,
         partition_number,
         au.root_page
FROM     sys.system_internals_allocation_units AS au
         INNER JOIN
         sys.partitions AS p
         ON au.container_id = p.partition_id
         INNER JOIN
         sys.objects AS o
         ON p.object_id = o.object_id
         INNER JOIN
         sys.indexes AS i
         ON p.index_id = i.index_id
            AND i.object_id = p.object_id
            AND i.type = 1
ORDER BY o.name, p.index_id;


--Issue the following query to find all the Non-Clustered Indexes on your tables:
SELECT   o.name AS table_name,
         p.index_id,
         i.name AS index_name,
         au.type_desc AS allocation_type,
         au.data_pages,
         partition_number,
         au.root_page
FROM     sys.system_internals_allocation_units AS au
         INNER JOIN
         sys.partitions AS p
         ON au.container_id = p.partition_id
         INNER JOIN
         sys.objects AS o
         ON p.object_id = o.object_id
         INNER JOIN
         sys.indexes AS i
         ON p.index_id = i.index_id
            AND i.object_id = p.object_id
            AND i.type = 2
ORDER BY o.name, p.index_id;

--Issue the following query to find all the Heap Tables in your database:
SELECT   o.name AS table_name,
         p.index_id,
         i.name AS index_name,
         au.type_desc AS allocation_type,
         au.data_pages,
         partition_number,
         au.first_iam_page
FROM     sys.system_internals_allocation_units AS au
         INNER JOIN
         sys.partitions AS p
         ON au.container_id = p.partition_id
         INNER JOIN
         sys.objects AS o
         ON p.object_id = o.object_id
         INNER JOIN
         sys.indexes AS i
         ON p.index_id = i.index_id
            AND i.object_id = p.object_id
            AND i.type = 0
ORDER BY o.name, p.index_id;
