-- get database ID
SELECT db_id('AdventureWorks2012')

-- view transaction log
DBCC loginfo(8) -- your database_id may be different
