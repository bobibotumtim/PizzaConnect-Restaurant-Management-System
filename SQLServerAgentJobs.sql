USE msdb;
GO

-- Create separate jobs for deletion and update queues
EXEC dbo.sp_add_job
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_Merged',
    @enabled = 1,
    @description = N'Process scheduled deletions daily at 00:00 - pizza_demo_DB_Merged only';

EXEC dbo.sp_add_job
    @job_name = N'ProcessDiscountUpdateQueue_pizza_demo_DB2',
    @enabled = 1,
    @description = N'Process scheduled discount updates daily at 00:00 - pizza_demo_DB_Merged only';

-- Add job step for deletion queue
EXEC sp_add_jobstep
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_Merged',
    @step_name = N'ProcessDeletionQueue',
    @subsystem = N'TSQL',
    @command = N'EXEC ProcessDeletionQueue',
    @database_name = N'pizza_demo_DB_Merged';

-- Add job step for update queue
EXEC sp_add_jobstep
    @job_name = N'ProcessDiscountUpdateQueue_pizza_demo_DB_Merged',
    @step_name = N'ProcessDiscountUpdateQueue',
    @subsystem = N'TSQL',
    @command = N'EXEC ProcessDiscountUpdateQueue',
    @database_name = N'pizza_demo_DB_Merged';

-- Add schedule (run daily at 00:01)
EXEC sp_add_schedule
    @schedule_name = N'DailyMidnight',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @active_start_time = 000100; -- 00:01

-- Attach schedule to both jobs
EXEC sp_attach_schedule
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_Merged',
    @schedule_name = N'DailyMidnight';

EXEC sp_attach_schedule
    @job_name = N'ProcessDiscountUpdateQueue_pizza_demo_DB_Merged',
    @schedule_name = N'DailyMidnight';

-- Add jobs to SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_Merged';

EXEC sp_add_jobserver
    @job_name = N'ProcessDiscountUpdateQueue_pizza_demo_DB_Merged';
GO