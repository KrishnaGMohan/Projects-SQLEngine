/*
Batch
A statement or set of statements submitted to SQL Server by the user (a query)
Also referred to as a Request
Monitor with sys.dm_exec_requests
*/

SELECT * FROM sys.dm_exec_requests

/*
Task
A unit of work that is scheduled by SQL Server.  
A Batch will have one or more Tasks
Monitor with sys.dm_os_tasks
*/

SELECT * FROM sys.dm_os_tasks


/*
Worker Thread
Logical thread within the SQL Server process 
Mapped 1:1 to a Windows thread
Each Task will be assigned to a single Worker Thread for the life of the Task
Monitor with sys.dm_os_workers
*/

SELECT * FROM sys.dm_os_workers

/*
One SQLOS Scheduler per core/logical processor
Handles scheduling tasks, I/O and synchronization of other resources
Work requests are balanced across schedulers based on number of active tasks
Monitor using sys.dm_os_schedulers
*/

SELECT * FROM sys.dm_os_schedulers

/*
Analyze where a task is spending the most time
Monitor using sys.dm_exec_requests & sys.dm_os_waiting_tasks
If status is Suspended, focus on the Wait Type and Wait Resource
*/
SELECT * FROM sys.dm_exec_requests 
SELECT * FROM sys.dm_os_waiting_tasks

/*
For server level bottlenecks, analyze sys.dm_os_wait_stats
Cumulative since last SQL Server Service restart
A single resource may be represented by several different wait types (e.g. PAGEIOLATCH_EX, PAGEIOLATCH_SH, ASYNC_IO_COMPLETION etc. all imply waiting for disk I/O)
*/
SELECT * FROM sys.dm_os_wait_stats

