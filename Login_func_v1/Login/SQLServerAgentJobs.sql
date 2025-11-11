USE msdb;
GO

-- Create job for deletion queue
EXEC dbo.sp_add_job
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @enabled = 1,
    @description = N'Process scheduled deletions daily at 00:00 - pizza_demo_DB only';

-- Add job step for deletion queue
EXEC sp_add_jobstep
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @step_name = N'ProcessDeletionQueue',
    @subsystem = N'TSQL',
    @command = N'EXEC ProcessDeletionQueue',
    @database_name = N'pizza_demo_DB';

-- Add schedule (run daily at 00:01)
EXEC sp_add_schedule
    @schedule_name = N'DailyMidnight',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @active_start_time = 000100; -- 00:01

-- Attach schedule to the job
EXEC sp_attach_schedule
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @schedule_name = N'DailyMidnight';

-- Add job to SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB';
GO