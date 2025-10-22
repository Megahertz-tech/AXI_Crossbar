/* ***********************************************************
    document:       axi_slv_driver.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_DRIVER_SV__
`define __AXI_SLV_DRIVER_SV__
`include "tb_axi_types_pkg.sv"
class axi_slv_driver extends uvm_driver #(axi_slv_seq_item);
typedef virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    ) virt_axi_slv_inf;
    //virtual v_axi_inf   vif;
    virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )   vif;
    parameter int unsigned MaxTrans = tb_xbar_param_pkg::TB_MAX_SLAVE_TRANS;
    parameter int unsigned ID_WIDTH = tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE;

    bit enable_b_channel = 1'b1;
    bit enable_r_channel = 1'b1;

    axi_slv_seq_item    req_q[$];
    bit                 schedule_response_q[$];
    semaphore           sqr_access_sem = new(1);
    semaphore           trans_sem = new(MaxTrans);

    //{{{ base function 
   `uvm_component_utils(axi_slv_driver)
    function new (string name = "axi_slv_driver", uvm_component parent);
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
    function void set_interface(virt_axi_slv_inf inf);
        if(inf == null) `uvm_fatal("Set_Inf", "interface handle is NULL, please check if target interface has been intantiated")
        else this.vif = inf;
    endfunction
    //}}}

    //{{{ run_phase
    task run_phase(uvm_phase phase);
        forever begin 
            reset_if();
            reset_driver();
            fork
                main();
                @(negedge vif.rst_n);
            join_any
            disable fork;
        end
    endtask
    //}}}
    //{{{ reset_if
    virtual task reset_if();
        `uvm_info("SLV driver"," reset inf", UVM_LOW)
        //vif.Slave_cb.aw_ready  <= '0;
        vif.Slave_cb.aw_ready  <= '1;
        vif.Slave_cb.w_ready   <= '0;
        vif.Slave_cb.b_id      <= '0;
        vif.Slave_cb.b_resp    <= '0;
        vif.Slave_cb.b_user    <= '0;
        vif.Slave_cb.b_valid   <= '0;
        //vif.Slave_cb.ar_ready  <= '0;
        vif.Slave_cb.ar_ready  <= '1;
        vif.Slave_cb.r_id      <= '0;
        vif.Slave_cb.r_data    <= '0;
        vif.Slave_cb.r_resp    <= '0;
        vif.Slave_cb.r_last    <= '0;
        vif.Slave_cb.r_user    <= '0;
        vif.Slave_cb.r_valid   <= '0;
        @(posedge vif.rst_n);
    endtask
    //}}}
    //{{{ reset_driver
    virtual function void reset_driver();
        req_q.delete();
        schedule_response_q.delete();
    endfunction 
    //}}}
    //{{{ do_setup_aw
    virtual task  automatic  do_setup_aw();
                axi_slv_seq_item    aw_req;
                axi_slv_seq_item    aw;
                axi_slv_seq_item    ar; // for atomic transaction 
                @(posedge vif.aw_valid);
                trans_sem.get(1);
                aw = axi_slv_seq_item::type_id::create("aw");
                if(!vif.Slave_cb.aw_ready) begin
                    @ (vif.Slave_cb);
                    vif.Slave_cb.aw_ready <= 1'b1;
                end
                #10ps;
                //if(vif.aw_valid) begin
                    aw.is_aw      = 1'b1;
                    aw.aw_id      = vif.aw_id      ;                   
                    aw.aw_addr    = vif.aw_addr    ;                    
                    aw.aw_lock    = vif.aw_lock    ;                    
                    aw.aw_valid   = vif.aw_valid   ;                    
                    aw.aw_user    = vif.aw_user    ;                    
                    aw.aw_len     = vif.aw_len     ;                    
                    aw.aw_size    = vif.aw_size    ;                    
                    aw.aw_burst   = vif.aw_burst   ;                    
                    aw.aw_cache   = vif.aw_cache   ;                    
                    aw.aw_prot    = vif.aw_prot    ;                    
                    aw.aw_qos     = vif.aw_qos     ;                    
                    aw.aw_region  = vif.aw_region  ;                    
                    aw.aw_atop    = vif.aw_atop    ;                    
                //end
                #10ps;
                @ (vif.Slave_cb);
                vif.Slave_cb.aw_ready <= 1'b0;

                sqr_access_sem.get(1);
                seq_item_port.get_next_item(aw_req);
                aw_req.copy(aw);
                #10ps;
                seq_item_port.item_done(aw_req);
                sqr_access_sem.put(1);

                if(aw.aw_atop ==  AXI_NON_ATOMIC) begin
                    assert(aw.is_aw) else `uvm_error("DO_SETUP_AW", "AXI_NON_ATOMIC: aw.is_aw is 0!")
                    req_q.push_back(aw);
                end
                //{{{ for atomic transaction                
                else if(aw.aw_atop == AXI_ATOMIC_STORE) begin
                    assert(aw.is_aw) else `uvm_error("DO_SETUP_AW", "atomic AXI_ATOMIC_STORE: aw.is_aw is 0!")
                    req_q.push_back(aw);
                    #10ps;
                    schedule_response_q.push_back(1'b1); //b 
                end 
                else if(!(aw.aw_atop == AXI_ATOMIC_STORE)) begin
                    ar = axi_slv_seq_item::type_id::create("ar");
                    ar.is_atomic_ar    = 1'b1;
                    ar.is_ar           = 1'b0;
                    ar.ar_id      = aw.aw_id      ;
                    ar.ar_addr    = aw.aw_addr    ;
                    ar.ar_lock    = aw.aw_lock    ;
                    ar.ar_valid   = aw.aw_valid   ;
                    ar.ar_user    = aw.aw_user    ;
                    ar.ar_len     = aw.aw_len     ;
                    ar.ar_size    = aw.aw_size    ;
                    ar.ar_burst   = aw.aw_burst   ;
                    ar.ar_cache   = aw.aw_cache   ;
                    ar.ar_prot    = aw.aw_prot    ;
                    ar.ar_qos     = aw.aw_qos     ;
                    ar.ar_region  = aw.aw_region  ;
                    assert(aw.is_aw) else `uvm_error("DO_SETUP_AW", "atomic ~AXI_ATOMIC_STORE: aw.is_aw is 0!")
                    req_q.push_back(aw);
                    #10ps;
                    schedule_response_q.push_back(1'b1); //b 
                    #10ps;
                    assert(ar.is_atomic_ar) else `uvm_error("DO_SETUP_AW", "atomic ~AXI_ATOMIC_STORE: ar.is_atomic_ar is 0!")
                    req_q.push_back(ar);
                    #10ns;
                    schedule_response_q.push_back(1'b1); //r 
                end
                //}}}
    endtask
    //}}}
    //{{{ do_setup_w
    virtual task do_setup_w();
                axi_slv_seq_item    w_req;
                axi_slv_seq_item    aw, w;
                @(posedge vif.w_valid);
                w = axi_slv_seq_item::type_id::create("w");
                w.is_w = 1'b1;
                @ (vif.Slave_cb);
                vif.Slave_cb.w_ready <= 1'b1;
                wait (vif.w_last)
                #10ps;
                @ (vif.Slave_cb);
                vif.Slave_cb.w_ready <= 1'b0;

                sqr_access_sem.get(1);
                seq_item_port.get_next_item(w_req);
                w_req.copy(w);
                #10ps;
                seq_item_port.item_done(w_req);
                sqr_access_sem.put(1);

                schedule_response_q.push_back(1'b1); // b
    endtask
    //}}}
    //{{{ do_setup_ar
    virtual task  automatic  do_setup_ar();
                axi_slv_seq_item    ar_req;
                axi_slv_seq_item    ar;
                @(posedge vif.ar_valid);
                trans_sem.get(1);
                ar = axi_slv_seq_item::type_id::create("ar");
                if(!vif.Slave_cb.ar_ready) begin
                    @ (vif.Slave_cb);
                    vif.Slave_cb.ar_ready <= 1'b1;
                end
                #10ps;
                if(vif.ar_valid) begin
                    ar.is_ar      = 1'b1;
                    ar.is_atomic_ar      = 1'b0;
                    ar.ar_id      = vif.ar_id      ;                   
                    ar.ar_addr    = vif.ar_addr    ;                    
                    ar.ar_lock    = vif.ar_lock    ;                    
                    ar.ar_valid   = vif.ar_valid   ;                    
                    ar.ar_user    = vif.ar_user    ;                    
                    ar.ar_len     = vif.ar_len     ;                    
                    ar.ar_size    = vif.ar_size    ;                    
                    ar.ar_burst   = vif.ar_burst   ;                    
                    ar.ar_cache   = vif.ar_cache   ;                    
                    ar.ar_prot    = vif.ar_prot    ;                    
                    ar.ar_qos     = vif.ar_qos     ;                    
                    ar.ar_region  = vif.ar_region  ;                    
                end
                #10ps;
                @ (vif.Slave_cb);
                vif.Slave_cb.ar_ready <= 1'b0;

                sqr_access_sem.get(1);
                seq_item_port.get_next_item(ar_req);
                ar_req.copy(ar);
                #10ps;
                seq_item_port.item_done(ar_req);
                sqr_access_sem.put(1);
                
                assert(ar.is_ar) else `uvm_error("DO_SETUP_AR","ar.is_ar is 0!") 
                req_q.push_back(ar);
                #10ps;
                schedule_response_q.push_back(1'b1); //r
    endtask
    //}}}
//{{{ schedule_response  (b ,r)
    task automatic schedule_response();
        axi_slv_seq_item    req;
        wait(req_q.size()!=0);
        wait(schedule_response_q.size() != 0);
        //assert(req_q.size()) else `uvm_error("SLV_DRV", "schedule_response req_q is empty!!!")
        req = req_q.pop_front();
        if(req.is_aw) begin
            if(enable_b_channel) begin
                do_b_response(req);
            end
            else begin
                #20ns;
            end
            void'(schedule_response_q.pop_front());
        end else if(req.is_ar | req.is_atomic_ar) begin
            if(enable_r_channel) begin
                do_r_response(req);
            end
            else begin
                #20ns;
            end
            void'(schedule_response_q.pop_front());
        end else begin
            `uvm_error("SLV_DRV", "schedule_response the req is not aw, ar, atomic_ar !!!")
            void'(schedule_response_q.pop_front());
        end
    endtask 

//}}}
    //{{{ do_b_response 
    task automatic do_b_response(input axi_slv_seq_item    aw);
        aw.set_access_b_response();
        repeat(aw.w2b_delay) @ (vif.Slave_cb);
        @ (vif.Slave_cb);
        vif.Slave_cb.b_valid <= aw.b_valid;
        vif.Slave_cb.b_id    <= aw.b_id ;
        vif.Slave_cb.b_resp  <= aw.b_resp ;
        vif.Slave_cb.b_user  <= aw.b_user ;
        @(posedge vif.b_ready);
        @ (vif.Slave_cb);
        vif.Slave_cb.b_valid <= 1'b0;
        vif.Slave_cb.b_id    <= '0;
        vif.Slave_cb.b_resp  <= '0;
        vif.Slave_cb.b_user  <= '0;
        trans_sem.put(1);
    endtask 
    //}}}
    //{{{ do_r_response
    task automatic do_r_response(input axi_slv_seq_item ar);
        ar.set_one_transfer_transaction_r();
        repeat(ar.ar2r_delay) @ (vif.Slave_cb);
        for(int unsigned i=0; i<ar.ar_len+1; i++) begin
            @ (vif.Slave_cb);
            vif.Slave_cb.r_id     <=  ar.r_id;
            vif.Slave_cb.r_valid  <=  ar.r_valid ;           
            vif.Slave_cb.r_data   <=  ar.r_data[i]  ;           
            vif.Slave_cb.r_last   <=  ar.r_last[i]  ;           
            vif.Slave_cb.r_user   <=  ar.r_user  ;
            vif.Slave_cb.r_resp   <=  ar.r_resp[i];
            wait (vif.r_ready);
        end
        #1ps;
        @ (vif.Slave_cb);
        vif.Slave_cb.r_id     <= '0   ;
        vif.Slave_cb.r_valid  <= '0   ;           
        vif.Slave_cb.r_data   <= '0   ;           
        vif.Slave_cb.r_last   <= '0   ;           
        vif.Slave_cb.r_user   <= '0   ;
        vif.Slave_cb.r_resp   <= '0   ;
        if(!ar.is_atomic_ar) trans_sem.put(1);
    endtask
    //}}}
    virtual task main();
        fork 
            // aw
            forever begin do_setup_aw(); end
            // w
            forever begin do_setup_w(); end
            // ar
            forever begin do_setup_ar(); end 
            // b,r
            forever begin schedule_response(); end 
        join
    endtask
    //{{{ wait_for_nclocks
    task automatic wait_for_nclocks (int n = 1);
        repeat(n) @ (posedge vif.clk);
    endtask
    //}}} 
    /*
    //{{{ reset_events
   task reset_events();
        `uvm_info("SLV driver", "reset events", UVM_LOW)
        aw_valid_e.reset();              
        w_valid_e.reset();       
        b_ready_e.reset();       
        ar_valid_e.reset();      
        ar_valid_e.reset();      
        r_ready_e.reset();       
        aw_valid_done_e.reset(); 
        w_valid_done_e.reset();  
        b_ready_done_e.reset();  
        ar_valid_done_e.reset(); 
        r_ready_done_e.reset();  
    endtask
    //}}}
    //{{{ main
    virtual task main();
        axi_slv_seq_item    aw_req, w_req;
        fork : main_fork
            wait_all_activities();
            set_up_all_activities();
            //forever begin
                //Setup Phase 
                //seq_item_port.get_next_item(req);
                fork : Setup_fork
                    forever begin
                            aw_valid_done_e.wait_trigger();
                            sqr_access_sem.get(1);
                            seq_item_port.get_next_item(aw_req);
                            aw_req.copy(aw);
                            #1ps;
                            aw_valid_done_e.reset();
                            seq_item_port.item_done(aw_req);
                            sqr_access_sem.put(1);
                    end
                    forever begin
                            w_valid_done_e.wait_trigger();
                            sqr_access_sem.get(1);
                            seq_item_port.get_next_item(w_req);
                            w_req.copy(w);
                            #1ps;
                            w_valid_done_e.reset();
                            seq_item_port.item_done(w_req);
                            sqr_access_sem.put(1);
                    end
               join
                //do_setup(req);
                //seq_item_port.item_done(req);
            //end
            forever begin
                // Access Phase 
                seq_item_port.get_next_item(rsp);
                do_access(rsp);
                seq_item_port.item_done(rsp);
            end 
        join
    endtask
    //}}}
    //{{{ do_setup
    virtual task do_setup(axi_slv_seq_item item);
        fork : setup_block
            //do_setup_aw(item);
            //do_setup_w(item);
            //do_setup_b(item);
            //do_setup_ar(item);
            //do_setup_r(item);
        join_any
        disable setup_block;
    endtask
    //}}}
    //{{{ wait_for_aw_valid
    task automatic wait_for_aw_valid();
        //`wait_sig_high(vif.Slave_cb, aw_valid)
        @(posedge vif.aw_valid);
        aw_valid_e.trigger();
        aw_valid_done_e.wait_trigger();
        #1ps;
        //aw_valid_done_e.reset();
    endtask
    //}}}
    //{{{ wait_for_w_valid
    task automatic wait_for_w_valid();
        //`wait_sig_high(vif.Slave_cb, w_valid)
        @(posedge vif.w_valid);
        //debug_w_valid = 1'b1;
        w_valid_e.trigger();
        w_valid_done_e.wait_trigger();
        #1ps;
        //w_valid_done_e.reset();
    endtask
    //}}}
    //{{{ wait_for_b_ready 
    task automatic wait_for_b_ready();
        //`wait_sig_high(vif.Slave_cb, b_ready)
        @(posedge vif.b_ready);
        b_ready_e.trigger();
        b_ready_done_e.wait_trigger();
        #1ps;
        b_ready_done_e.reset();
    endtask
    //}}}
    //{{{ wait_for_ar_valid
    task automatic wait_for_ar_valid();
        //`wait_sig_high(vif.Slave_cb, ar_valid)
        @(posedge vif.ar_valid);
        ar_valid_e.trigger();
        ar_valid_done_e.wait_trigger();
        #1ps;
        ar_valid_done_e.reset();
    endtask
    //}}}
    //{{{ wait_for_r_ready
    task automatic wait_for_r_ready();
        //`wait_sig_high(vif.Slave_cb, r_ready)
        @(posedge vif.r_ready);
        r_ready_e.trigger();
        r_ready_done_e.wait_trigger();
        #1ps;
        r_ready_done_e.reset();
    endtask
    //}}}
    //{{{ wait_all_activities
    virtual task wait_all_activities();
        fork: wait_all_activities_fork
            forever begin wait_for_aw_valid(); end
            forever begin wait_for_w_valid(); end
            forever begin wait_for_b_ready(); end
            forever begin wait_for_ar_valid(); end
            forever begin wait_for_r_ready(); end
        join
    endtask
    //}}}
    //{{{ set_up_all_activities
    virtual task set_up_all_activities();
        fork: setup_all_activities_folk
            forever begin do_setup_aw(); end
            forever begin do_setup_w(); end
        join
    endtask
    //}}}
    */
    
endclass: axi_slv_driver






`endif 
