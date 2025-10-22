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
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    ) virt_axi_slv_inf;
    //virtual v_axi_inf   vif;
    virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )   vif;
    uvm_event           aw_valid_e,   aw_valid_done_e;
    uvm_event           w_valid_e,    w_valid_done_e;
    uvm_event           b_ready_e,    b_ready_done_e;
    uvm_event           ar_valid_e,   ar_valid_done_e;
    uvm_event           r_ready_e,    r_ready_done_e;
    bit  debug_aw_valid, debug_w_valid;
    bit  debug_w_last;
    bit  debug_aw_valid_done_branch, debug_aw_valid_done_main;
    //int                 mem[int];
    axi_slv_seq_item    aw, w, b, ar, r;
    semaphore           access_sem = new(1); 

   `uvm_component_utils(axi_slv_driver)
    function new (string name = "axi_slv_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(), "into build_phase", UVM_LOW)
        aw_valid_e      = uvm_event_pool::get_global("aw_valid_e");   
        w_valid_e       = uvm_event_pool::get_global("w_valid_e");
        b_ready_e       = uvm_event_pool::get_global("b_ready_e");
        ar_valid_e      = uvm_event_pool::get_global("ar_valid_e");
        r_ready_e       = uvm_event_pool::get_global("r_ready_e");
        aw_valid_done_e = uvm_event_pool::get_global("aw_valid_done_e");
        w_valid_done_e  = uvm_event_pool::get_global("w_valid_done_e");
        b_ready_done_e  = uvm_event_pool::get_global("b_ready_done_e");
        ar_valid_done_e = uvm_event_pool::get_global("ar_valid_done_e");
        r_ready_done_e  = uvm_event_pool::get_global("r_ready_done_e");
        aw = axi_slv_seq_item::type_id::create("aw");
        w = axi_slv_seq_item::type_id::create("w");
        b = axi_slv_seq_item::type_id::create("b");
        ar = axi_slv_seq_item::type_id::create("r");
        r = axi_slv_seq_item::type_id::create("r");
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(), "into connect_phase", UVM_LOW)
    endfunction
    function void set_interface(virt_axi_slv_inf inf);
        if(inf == null) `uvm_fatal("Set_Inf", "interface handle is NULL, please check if target interface has been intantiated")
        else this.vif = inf;
    endfunction

    //{{{ run_phase
    task run_phase(uvm_phase phase);
        forever begin 
            reset_if();
            reset_events();
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
        //vif.Slave_cb.aw_ready  <= '1;
        vif.Slave_cb.aw_ready  <= '0;
        vif.Slave_cb.w_ready   <= '0;
        vif.Slave_cb.b_id      <= '0;
        vif.Slave_cb.b_resp    <= '0;
        vif.Slave_cb.b_user    <= '0;
        vif.Slave_cb.b_valid   <= '0;
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
    /*virtual task main();
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
                            access_sem.get(1);
                            seq_item_port.get_next_item(aw_req);
                            aw_req.copy(aw);
                            #1ps;
                            aw_valid_done_e.reset();
                            seq_item_port.item_done(aw_req);
                            access_sem.put(1);
                    end
                    forever begin
                            w_valid_done_e.wait_trigger();
                            access_sem.get(1);
                            seq_item_port.get_next_item(w_req);
                            w_req.copy(w);
                            #1ps;
                            w_valid_done_e.reset();
                            seq_item_port.item_done(w_req);
                            access_sem.put(1);
                    end
               join
                //do_setup(req);
                //seq_item_port.item_done(req);
            //end
            /*forever begin
                // Access Phase 
                seq_item_port.get_next_item(rsp);
                do_access(rsp);
                seq_item_port.item_done(rsp);
            end 
        join
    endtask*/
    //}}}
    //{{{ do_setup
    virtual task do_setup(axi_slv_seq_item item);
        fork : setup_block
            do_setup_aw(item);
            do_setup_w(item);
            //do_setup_b(item);
            //do_setup_ar(item);
            //do_setup_r(item);
        join_any
        disable setup_block;
    endtask
    //}}}
    //{{{ do_setup_aw
    virtual task do_setup_aw(axi_slv_seq_item item);
        aw_valid_e.wait_trigger();
        if(!vif.Slave_cb.aw_ready) begin
            @ (vif.Slave_cb);
            vif.Slave_cb.aw_ready <= 1'b1;
        end
        #1ps;
        @ (vif.Slave_cb);
        if(vif.aw_valid) begin
            item.is_aw      = 1'b1;
            item.aw_id      = vif.aw_id      ;                   
            item.aw_addr    = vif.aw_addr    ;                    
            item.aw_lock    = vif.aw_lock    ;                    
            item.aw_valid   = vif.aw_valid   ;                    
            item.aw_user    = vif.aw_user    ;                    
            item.aw_len     = vif.aw_len     ;                    
            item.aw_size    = vif.aw_size    ;                    
            item.aw_burst   = vif.aw_burst   ;                    
            item.aw_cache   = vif.aw_cache   ;                    
            item.aw_prot    = vif.aw_prot    ;                    
            item.aw_qos     = vif.aw_qos     ;                    
            item.aw_region  = vif.aw_region  ;                    
            item.aw_atop    = vif.aw_atop    ;                    
        end
        #1ps;
        @ (vif.Slave_cb);
        vif.Slave_cb.aw_ready <= 1'b0;
        /*else begin
            @(vif.Slave_cb.aw_valid); 
            item.is_aw      = 1'b1;
            item.aw_id      = vif.aw_id      ;                   
            item.aw_addr    = vif.aw_addr    ;                    
            item.aw_lock    = vif.aw_lock    ;                    
            item.aw_valid   = vif.aw_valid   ;                    
            item.aw_user    = vif.aw_user    ;                    
            item.aw_len     = vif.aw_len     ;                    
            item.aw_size    = vif.aw_size    ;                    
            item.aw_burst   = vif.aw_burst   ;                    
            item.aw_cache   = vif.aw_cache   ;                    
            item.aw_prot    = vif.aw_prot    ;                    
            item.aw_qos     = vif.aw_qos     ;                    
            item.aw_region  = vif.aw_region  ;                    
            item.aw_atop    = vif.aw_atop    ;
        end*/
        //@(negedge vif.Slave_cb.aw_valid);
        aw_valid_e.reset();
        #1ps;
        aw_valid_done_e.trigger();
    endtask
    //}}}
    //{{{ do_setup_w
    virtual task do_setup_w(axi_slv_seq_item item);
        w_valid_e.wait_trigger();
        @ (vif.Slave_cb);
        vif.Slave_cb.w_ready <= 1'b1;
        wait (vif.w_last)
        debug_w_last = 1'b1;;
        #1ps;
        @ (vif.Slave_cb);
        vif.Slave_cb.w_ready <= 1'b0;
        w_valid_e.reset();
        #1ps;
        w_valid_done_e.trigger();
        /*
        @ (vif.Slave_cb);
        item.w_data = new[item.aw_burst+1];
        item.w_strb = new[item.aw_burst+1];
        item.w_last = new[item.aw_burst+1];
        for(int i=0;i<item.aw_burst+1;i++) begin
            if(vif.Slave_cb.w_valid) begin
                //mem[item.aw_addr+i] = vif.Slave_cb.w_data; 
                item.w_data[i] = vif.Slave_cb.w_data;
                item.w_strb[i] = vif.Slave_cb.w_strb;
                item.w_last[i] = vif.Slave_cb.w_last;
                @ (vif.Slave_cb);
            end
            else begin
                @ (vif.Slave_cb.w_valid);
                // mem[item.aw_addr+i] = vif.Slave_cb.w_data; 
                item.w_data[i] = vif.Slave_cb.w_data;
                item.w_strb[i] = vif.Slave_cb.w_strb;
                item.w_last[i] = vif.Slave_cb.w_last;
                @ (vif.Slave_cb);
            end
        end */
    endtask
    //}}}
    //{{{ wait_for_nclocks
    task automatic wait_for_nclocks (int n = 1);
        repeat(n) @ (posedge vif.clk);
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
        debug_w_valid = 1'b1;
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
    virtual task set_up_all_activities();
        fork: setup_all_activities_folk
            forever begin do_setup_aw(aw); end
            forever begin do_setup_w(w); end
        join
    endtask
    virtual task main();
        axi_slv_seq_item    aw_req, w_req;
        fork 
            //aw
            forever begin
                @(posedge vif.aw_valid);
                if(!vif.Slave_cb.aw_ready) begin
                    @ (vif.Slave_cb);
                    vif.Slave_cb.aw_ready <= 1'b1;
                end
                #100ps;
                @ (vif.Slave_cb);
                if(vif.aw_valid) begin
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
                end
                #100ps;
                @ (vif.Slave_cb);
                vif.Slave_cb.aw_ready <= 1'b0;
                access_sem.get(1);
                seq_item_port.get_next_item(aw_req);
                aw_req.copy(aw);
                #10ps;
                seq_item_port.item_done(aw_req);
                access_sem.put(1);
            end
            //w
            forever begin
                @(posedge vif.w_valid);
                @ (vif.Slave_cb);
                vif.Slave_cb.w_ready <= 1'b1;
                wait (vif.w_last)
                #100ps;
                @ (vif.Slave_cb);
                vif.Slave_cb.w_ready <= 1'b0;
                access_sem.get(1);
                            seq_item_port.get_next_item(w_req);
                            w_req.copy(w);
                            #10ps;
                            seq_item_port.item_done(w_req);
                            access_sem.put(1);
            end
        join
    endtask
endclass: axi_slv_driver






`endif 
