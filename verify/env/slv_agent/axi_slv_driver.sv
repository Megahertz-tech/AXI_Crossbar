/* ***********************************************************
    document:       axi_slv_driver.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_DRIVER_SV__
`define __AXI_SLV_DRIVER_SV__
class axi_slv_driver extends uvm_driver #(axi_slv_seq_item);
    virtual v_axi_inf   vif;
    uvm_event           aw_valid_e,   aw_valid_done_e;
    uvm_event           w_valid_e,    w_valid_done_e;
    uvm_event           b_ready_e,    b_ready_done_e;
    uvm_event           ar_valid_e,   ar_valid_done_e;
    uvm_event           r_ready_e,    r_ready_done_e;

   `uvm_component_utils(axi_slv_driver)
    function new (string name = "axi_slv_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
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
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
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
        vif.aw_ready  <= '0;
        vif.w_ready   <= '0;
        vif.b_id      <= '0;
        vif.b_resp    <= '0;
        vif.b_user    <= '0;
        vif.b_valid   <= '0;
        vif.ar_ready  <= '0;
        vif.r_id      <= '0;
        vif.r_data    <= '0;
        vif.r_resp    <= '0;
        vif.r_last    <= '0;
        vif.r_user    <= '0;
        vif.r_valid   <= '0;
        @(posedge vif.rst_n);
    endtask
    //}}}
    //{{{ reset_events
    task reset_events();
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
        axi_slv_seq_item req, rsp;
        fork
            wait_all_activities();
            forever begin
                //Setup Phase 
                seq_item_port.get_next_item(req);
                do_setup(req);
                seq_item_port.item_done();
                // Access Phase 
                seq_item_port.get_next_item(rsp);
                do_access(req, rsp);
                seq_item_port.item_done();
            end
        join
    endtask
    //}}}
    //{{{ do_setup
    virtual task do_setup(axi_slv_seq_item item);
        fork : setup_block
            do_setup_aw(item);
            do_setup_w(item);
            do_setup_b(item);
            do_setup_ar(item);
            do_setup_r(item);
        join_any
        disable setup_block;
    endtask
    //}}}
    virtual task do_setup_aw(xi_slv_seq_item item);
        aw_valid_e.wait_trigger();

    endtask

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
    endtask
    //}}}
    //{{{ wait_for_w_valid
    task automatic wait_for_w_valid();
        `wait_sig_high(vif.Slave_cb, w_valid)
        //@(posedge vif.w_valid);
        -> w_valid_e;
        @ w_valid_done_e;
    endtask
    //}}}
    //{{{ wait_for_b_ready 
    task automatic wait_for_b_ready();
        `wait_sig_high(vif.Slave_cb, b_ready)
        //@(posedge vif.b_ready);
        -> b_ready_e;
        @ b_ready_done_e;
    endtask
    //}}}
    //{{{ wait_for_ar_valid
    task automatic wait_for_ar_valid();
        `wait_sig_high(vif.Slave_cb, ar_valid)
        //@(posedge vif.ar_valid);
        -> ar_valid_e;
        @ ar_valid_done_e;
    endtask
    //}}}
    //{{{ wait_for_r_ready
    task automatic wait_for_r_ready();
        `wait_sig_high(vif.Slave_cb, r_ready)
        //@(posedge vif.r_ready);
        -> r_ready_e;
        @ r_ready_done_e;
    endtask
    //}}}
    //{{{ wait_all_activities
    virtual task wait_all_activities();
        fork
            forever begin wait_for_aw_valid() end;
            forever begin wait_for_w_valid() end;
            forever begin wait_for_b_ready() end;
            forever begin wait_for_ar_valid() end;
            forever begin wait_for_r_ready() end;
        join
    endtask
    //}}}
endclass






`endif 
