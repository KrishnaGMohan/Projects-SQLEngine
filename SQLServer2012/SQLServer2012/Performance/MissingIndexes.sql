/*
Missing Indexes DMVs
dm_db_missing_index_group_stats
dm_db_missing_index_details
*/
/*
The following query determines which missing indexes would produce the highest anticipated cumulative improvement, in descending order, for user queries:
*/

SELECT TOP 50 priority = avg_total_user_cost * 
avg_user_impact * (user_seeks + user_scans)
,d.statement
,d.equality_columns
,d.inequality_columns
,d.included_columns
,s.avg_total_user_cost
,s.avg_user_impact
,s.user_seeks, s.user_scans
FROM sys.dm_db_missing_index_group_stats s
JOIN sys.dm_db_missing_index_groups g 
ON s.group_handle = g.index_group_handle
JOIN sys.dm_db_missing_index_details d 
ON g.index_handle = d.index_handle
ORDER BY priority DESC