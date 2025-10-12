set assert_output_stop_level INACTIVE
set assert_stop_level NEVER
set assert_report_level NEVER

database -open waves -into wave.shm -default
probe -create -database waves tb_axi_xbar_top -depth all

probe -create -all -dynamic -morories -unpacked 65536 -depth all

probe -create $uvm:{uvm_test_top.env.mst_agt_0.drv} -all
probe -create $uvm:{uvm_test_top.env.mst_agt_1.drv} -all
probe -create $uvm:{uvm_test_top.env.mst_agt_2.drv} -all
probe -create $uvm:{uvm_test_top.env.slv_agt_0.drv} -all
probe -create $uvm:{uvm_test_top.env.slv_agt_1.drv} -all
probe -create $uvm:{uvm_test_top.env.slv_agt_2.drv} -all
probe -create $uvm:{uvm_test_top.env.slv_agt_3.drv} -all

run 20000ns
