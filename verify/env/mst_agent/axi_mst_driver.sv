/* ***********************************************************
    document:       axi_mst_driver.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    driver for axi manager 
**************************************************************/
`ifndef __AXI_MST_DRIVER_SV__
`define __AXI_MST_DRIVER_SV__
`include "tb_axi_types_pkg.sv"
class axi_mst_driver extends uvm_driver #(axi_mst_seq_item);    
    //{{{ vif
    typedef virtual v_axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    ) virt_axi_mst_inf;
    typedef logic [AXI_MASTER_ID_WIDTH_IN_USE-1:0]   axi_id_t;
    //virtual v_axi_inf       vif;
    virtual v_axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )       vif;
    //}}}
    axi_mst_seq_item        tx;
    shortint                mst_id;
    axi_mst_seq_item        TXs_q[$];
    axi_id_t                AWID_q[$];
    axi_id_t                ARID_q[$];
    bit                     rsp_in_flight_en;

   `uvm_component_utils(axi_mst_driver)
   //{{{ basic tb function
    function new (string name = "axi_mst_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         `uvm_info(get_full_name(), "into build_phase", UVM_LOW)
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(), "into connect_phase", UVM_LOW)
    endfunction
    function void set_interface(virt_axi_mst_inf inf);
        if(inf == null) `uvm_fatal("Set_Inf", "interface handle is NULL, please check if target interface has been intantiated")
        else this.vif = inf;
    endfunction

    function void set_mst_id(shortint id);
        this.mst_id = id;
    endfunction
    //}}}
    
    //{{{ run_phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_full_name(), "into run_phase", UVM_LOW)
        //seq_item_port.disable_auto_item_recording(); //For pipelined and out-of-order transaction execution, the driver must turn off this automatic recording 
        forever begin 
            reset_if();
            fork
                main();
                @(negedge vif.rst_n);
            join_any
            disable fork;
        end 
    endtask
    //}}}

    //{{{ reset_if
    task reset_if();
       axi_burst_type default_burst_type = AXI_INCREMENTING_BURST;
       `uvm_info(get_full_name(), $sformatf("master No.%0d reset inf", mst_id), UVM_LOW)
       vif.Master_cb.aw_id     <= '0;
       vif.Master_cb.aw_addr   <= '0;
       vif.Master_cb.aw_len    <= '0;
       vif.Master_cb.aw_size   <= '0;
       vif.Master_cb.aw_burst  <= default_burst_type;
       vif.Master_cb.aw_lock   <= '0;
       vif.Master_cb.aw_cache  <= '0;
       vif.Master_cb.aw_prot   <= '0;
       vif.Master_cb.aw_qos    <= '0;
       vif.Master_cb.aw_region <= '0;
       vif.Master_cb.aw_atop   <= '0;
       vif.Master_cb.aw_user   <= '0;
       vif.Master_cb.aw_valid  <= '0;
       vif.Master_cb.w_data    <= '0;
       vif.Master_cb.w_strb    <= '0;
       vif.Master_cb.w_last    <= '0;
       vif.Master_cb.w_user    <= '0;
       vif.Master_cb.w_valid   <= '0;
       vif.Master_cb.b_ready   <= '1;
       vif.Master_cb.r_ready   <= '1;
       vif.Master_cb.ar_id     <= '0;
       vif.Master_cb.ar_valid  <= 1'b0;
       vif.Master_cb.ar_addr   <= '0;
       vif.Master_cb.ar_len    <= '0;
       vif.Master_cb.ar_size   <= '0;
       vif.Master_cb.ar_burst  <= default_burst_type;
       vif.Master_cb.ar_lock   <= '0;
       vif.Master_cb.ar_cache  <= '0;
       vif.Master_cb.ar_prot   <= '0;
       vif.Master_cb.ar_qos    <= '0;
       vif.Master_cb.ar_region <= '0;
       vif.Master_cb.ar_user   <= '0;
       @(posedge vif.rst_n);
       `uvm_info(get_full_name(), $sformatf("master No.%0d reset inf done", mst_id), UVM_LOW)
    endtask
    //}}}
    //{{{ main
    task main();
        `uvm_info("mst drv", "enter main()", UVM_LOW)
        //fork 
            //get_item();
            execute_item();
            //get_read_transaction();
            //get_write_response();
        //join
    endtask
    //}}}
    //{{{ get_item
    virtual task get_item();
        forever begin
            axi_mst_seq_item tx;
            seq_item_port.get_next_item(tx);
            accept_tr(tx);
            TXs_q.push_back(tx);
            seq_item_port.item_done();
        end
    endtask
    //}}}
    //{{{ execute_item
    virtual task execute_item();
        forever begin
            seq_item_port.get_next_item(tx);
            `uvm_info("mst drv","get item", UVM_LOW)
            //wait(TXs_q.size() !=0 );
            //tx = TXs_q.pop_front();
            if(tx.access_type == AXI_WRITE_ACCESS) begin
                drive_aw_address(tx);
                drive_write_transaction(tx);
                if(!rsp_in_flight_en) begin
                    //wait_write_response(tx);
                end
            end else begin
                drive_ar_address(tx);
            end
            seq_item_port.item_done();
        end
    endtask
    //}}}
    //{{{ wait_write_response
    virtual task wait_write_response(axi_mst_seq_item item);
        @(vif.b_valid);
        @ (vif.Master_cb);
        item.b_id = vif.b_id;
        item.b_user = vif.b_user;
        item.b_valid = vif.b_valid;
        item.b_resp = vif.b_resp;
        @ (vif.Master_cb);
        vif.Master_cb.b_ready <= 1'b1;
        @ (vif.Master_cb);
        vif.Master_cb.b_ready <= 1'b0;
    endtask
    //}}}
    //{{{ drive_aw_address
    virtual task drive_aw_address(axi_mst_seq_item item);
        @ (vif.Master_cb);
        vif.Master_cb.aw_id     <= item.aw_id    ;
        vif.Master_cb.aw_addr   <= item.aw_addr  ;
        vif.Master_cb.aw_lock   <= item.aw_lock  ;
        vif.Master_cb.aw_valid  <= item.aw_valid ;
        vif.Master_cb.aw_user   <= item.aw_user  ;
        vif.Master_cb.aw_len    <= item.aw_len   ;
        vif.Master_cb.aw_size   <= item.aw_size  ;
        vif.Master_cb.aw_burst  <= item.aw_burst ;
        vif.Master_cb.aw_cache  <= item.aw_cache ;
        vif.Master_cb.aw_prot   <= item.aw_prot  ;
        vif.Master_cb.aw_qos    <= item.aw_qos   ;
        vif.Master_cb.aw_region <= item.aw_region;
        vif.Master_cb.aw_atop   <= item.aw_atop  ;
        //if(vif.Master_cb.aw_ready !== 1'b1) @ (vif.Master_cb iff vif.Master_cb.aw_ready === 1'b1);
        @ (vif.Master_cb);
        vif.Master_cb.aw_id     <= '0 ;
        vif.Master_cb.aw_addr   <= '0 ;
        vif.Master_cb.aw_lock   <= '0 ;
        vif.Master_cb.aw_valid  <= '0 ;
        vif.Master_cb.aw_user   <= '0 ;
        vif.Master_cb.aw_len    <= '0 ;
        vif.Master_cb.aw_size   <= '0 ;
        //vif.Master_cb.aw_burst  <= '0 ; 
        vif.Master_cb.aw_cache  <= '0 ;
        vif.Master_cb.aw_prot   <= '0 ;
        vif.Master_cb.aw_qos    <= '0 ;
        vif.Master_cb.aw_region <= '0 ;
        vif.Master_cb.aw_atop   <= '0 ;
        AWID_q.push_back(item.aw_id);
    endtask
    //}}} 
    //{{{ drive_write_transaction
    virtual task drive_write_transaction(axi_mst_seq_item item);
        repeat(item.aw2w_delay) @ (vif.Master_cb);
        for(int unsigned i=0; i<item.aw_len+1; i++) begin
            @ (vif.Master_cb);
            vif.Master_cb.w_valid  <=  item.w_valid ;           
            vif.Master_cb.w_data   <=  item.w_data[i]  ;           
            vif.Master_cb.w_strb   <=  item.w_strb[i]  ;           
            vif.Master_cb.w_last   <=  item.w_last[i]  ;           
            vif.Master_cb.w_user   <=  item.w_user  ;
            //if(vif.Master_cb.w_ready !== 1'b1) @ (vif.Master_cb iff vif.Master_cb.w_ready === 1'b1);
        end
        @ (vif.Master_cb);
        vif.Master_cb.w_valid  <= '0   ;           
        vif.Master_cb.w_data   <= '0   ;           
        vif.Master_cb.w_strb   <= '0   ;           
        vif.Master_cb.w_last   <= '0   ;           
        vif.Master_cb.w_user   <= '0   ;
    endtask
    //}}}
    //{{{ drive_ar_address
    virtual task drive_ar_address(axi_mst_seq_item item);
        @ (vif.Master_cb);
        vif.Master_cb.ar_id     <= item.ar_id    ;
        vif.Master_cb.ar_addr   <= item.ar_addr  ;
        vif.Master_cb.ar_lock   <= item.ar_lock  ;
        vif.Master_cb.ar_valid  <= item.ar_valid ;
        vif.Master_cb.ar_user   <= item.ar_user  ;
        vif.Master_cb.ar_len    <= item.ar_len   ;
        vif.Master_cb.ar_size   <= item.ar_size  ;
        vif.Master_cb.ar_burst  <= item.ar_burst ;
        vif.Master_cb.ar_cache  <= item.ar_cache ;
        vif.Master_cb.ar_prot   <= item.ar_prot  ;
        vif.Master_cb.ar_qos    <= item.ar_qos   ;
        vif.Master_cb.ar_region <= item.ar_region;
        //if(vif.Master_cb.ar_ready !== 1'b1) @ (vif.Master_cb iff vif.Master_cb.ar_ready === 1'b1);
        @ (vif.Master_cb);
        vif.Master_cb.ar_id     <= '0 ;
        vif.Master_cb.ar_addr   <= '0 ;
        vif.Master_cb.ar_lock   <= '0 ;
        vif.Master_cb.ar_valid  <= '0 ;
        vif.Master_cb.ar_user   <= '0 ;
        vif.Master_cb.ar_len    <= '0 ;
        vif.Master_cb.ar_size   <= '0 ;
        //vif.Master_cb.ar_burst  <= '0 ;
        vif.Master_cb.ar_cache  <= '0 ;
        vif.Master_cb.ar_prot   <= '0 ;
        vif.Master_cb.ar_qos    <= '0 ;
        vif.Master_cb.ar_region <= '0 ;
        ARID_q.push_back(item.ar_id);
    endtask
    //}}}
    //{{{ get_read_transaction
    virtual task get_read_transaction();
    endtask
    //}}}
endclass





`endif 
