/*
DM_DB_INDEX_OPERATIONAL_STATS : Returns current low-level I/O, locking, latching, and access method activity 
DM_DB_INDEX_USAGE_STATS: Returns counts of different types of index operations and the time each type of operation was last performed

*/

USE AdventureWorks2012
GO

DECLARE @dbid int
SELECT @dbid = db_id('AdventureWorks2012')

SELECT objectname=object_name(i.object_id), indexname=i.name, 	i.index_id 
FROM sys.indexes i join sys.objects o on i.object_id = o.object_id
WHERE objectproperty(o.object_id,'IsUserTable') = 1
AND i.index_id NOT IN (SELECT s.index_id 
		FROM sys.dm_db_index_usage_stats s 
		WHERE s.object_id=i.object_id 
		AND i.index_id=s.index_id 
		AND database_id = @dbid )
ORDER BY objectname,i.index_id,indexname ASC

--In the example shown below, rarely used indexes appear first:

USE AdventureWorks2012
GO

DECLARE @dbid int

SELECT @dbid = db_id()

SELECT objectname=object_name(s.object_id), s.object_id, 
	indexname=i.name, i.index_id, user_seeks, user_scans, 
	user_lookups, user_updates
FROM sys.dm_db_index_usage_stats s 
JOIN sys.indexes i ON i.object_id = s.object_id 
		AND i.index_id = s.index_id
WHERE database_id = @dbid 
	AND objectproperty(s.object_id,'IsUserTable') = 1
ORDER BY (user_seeks + user_scans + user_lookups + user_updates) ASC
