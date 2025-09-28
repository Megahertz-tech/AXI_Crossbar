set assert_output_stop_level INACTIVE
set assert_stop_level NEVER
set assert_report_level NEVER

database -open waves -into wave.shm -default
probe -create -database waves tb_fifo_top -depth all

run 2s
