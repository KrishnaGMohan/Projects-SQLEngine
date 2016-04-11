
/* sys.dm_os_memory_clerks http://msdn.microsoft.com/en-us/library/ms175019.aspx */
SELECT * FROM sys.dm_os_memory_clerks 

/* sys.dm_os_memory_objects http://msdn.microsoft.com/en-us/library/ms179875.aspx */
SELECT * FROM sys.dm_os_memory_objects

/* sys.dm_os_memory_nodes http://msdn.microsoft.com/en-us/library/bb510622.aspx */
SELECT * FROM sys.dm_os_memory_nodes


/* sys.dm_os_memory_brokers */
SELECT * FROM sys.dm_os_memory_brokers



-- View the various memory clerks and their current memory allocations by name and memory node

SELECT type, name, memory_node_id
	, sum(pages_kb 
		+ virtual_memory_reserved_kb 
		+ virtual_memory_committed_kb 
		+ awe_allocated_kb 
		+ shared_memory_reserved_kb 
		+ shared_memory_committed_kb) AS TotalKB
FROM sys.dm_os_memory_clerks
GROUP BY type, name, memory_node_id
ORDER BY TotalKB DESC



-- View the current state of the memory brokers
-- Note the current memory, the predicted future memory, the target memory and whether the memory is growing, shrinking or stable

SELECT p.name AS resource_governor_pool_name, b.memory_broker_type
	, b.allocations_kb AS current_memory_allocated_kb
	, b.allocations_kb_per_sec AS allocation_rate_in_kb_per_sec
	, b.future_allocations_kb AS near_future_allocations_kb
	, b.target_allocations_kb
	, b.last_notification AS last_memory_notification
FROM sys.dm_os_memory_brokers b
INNER JOIN sys.resource_governor_resource_pools p ON p.pool_id = b.pool_id




-- Run the following query to display all the Database pages that are currently in the buffer pool

SELECT obj.name AS TableName, ind.name AS IndexName, part.object_id AS ObjectID, part.index_id AS IndexID
, part.partition_number AS PartitionNumber, buf.page_level AS IndexLevel
, alloc.type_desc AS AllocationType, buf.page_type AS PageType, buf.page_id AS PageNumber
FROM sys.dm_os_buffer_descriptors buf
INNER JOIN sys.allocation_units alloc ON alloc.allocation_unit_id = buf.allocation_unit_id
INNER JOIN sys.partitions part ON part.hobt_id = alloc.container_id
INNER JOIN sys.indexes ind ON ind.object_id = part.object_id AND ind.index_id = part.index_id
INNER JOIN sys.objects obj ON obj.object_id = part.object_id
WHERE buf.database_id = db_id() AND alloc.type IN (1,3) AND obj.is_ms_shipped = 0
UNION ALL
SELECT obj.name AS TableName, ind.name AS IndexName, part.object_id AS ObjectID, part.index_id AS IndexID
, part.partition_number AS PartitionNumber, buf.page_level AS IndexLevel
, alloc.type_desc AS AllocationType, buf.page_type AS PageType, buf.page_id AS PageNumber
FROM sys.dm_os_buffer_descriptors buf
INNER JOIN sys.allocation_units alloc ON alloc.allocation_unit_id = buf.allocation_unit_id
INNER JOIN sys.partitions part ON part.partition_id = alloc.container_id
INNER JOIN sys.indexes ind ON ind.object_id = part.object_id AND ind.index_id = part.index_id
INNER JOIN sys.objects obj ON obj.object_id = part.object_id
WHERE buf.database_id = db_id() AND alloc.type = 2 AND obj.is_ms_shipped = 0
ORDER BY TableName, IndexID, PageNumber
GO


