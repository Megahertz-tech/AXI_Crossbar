/* ***********************************************************
    document:       axi_mst_driver.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef ____
`define 
class axi_mst_driver extends uvm_driver #(axi_mst_seq_item);    
    virtual v_axi_inf   vif;
    shortint            mst_id;

   `uvm_component_utils(axi_mst_driver)
    function new (string name = "axi_mst_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void set_mst_id(shortint id);
        this.mst_id = id;
    endfunction
    
    //{{{ run_phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
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
       vif.aw_id     <= '0;
       vif.aw_addr   <= '0;
       vif.aw_len    <= '0;
       vif.aw_size   <= '0;
       vif.aw_burst  <= default_burst_type;
       vif.aw_lock   <= '0;
       vif.aw_cache  <= '0;
       vif.aw_prot   <= '0;
       vif.aw_qos    <= '0;
       vif.aw_region <= '0;
       vif.aw_atop   <= '0;
       vif.aw_user   <= '0;
       vif.aw_valid  <= '0;
       vif.w_data    <= '0;
       vif.w_strb    <= '0;
       vif.w_last    <= '0;
       vif.w_user    <= '0;
       vif.w_valid   <= '0;
       vif.b_ready   <= '0;
       vif.ar_id     <= '0;
       vif.ar_addr   <= '0;
       vif.ar_len    <= '0;
       vif.ar_size   <= '0;
       vif.ar_burst  <= default_burst_type;
       vif.ar_lock   <= '0;
       vif.ar_cache  <= '0;
       vif.ar_prot   <= '0;
       vif.ar_qos    <= '0;
       vif.ar_region <= '0;
       vif.ar_user   <= '0;
       vif.ar_valid  <= '0;
       vif.r_ready   <= '0;
       @(posedge vif.rst_n);
    endtask
    //}}}
    //{{{ main
    task main();
        fork 
            wr_rd_thread();
            rsp_thread();
        join
    endtask
    //}}}
    //{{{ wr_rd_thread
    task wr_rd_thread();
        forever begin
            axi_mst_seq_item tx;
            seq_item_port.get_next_item(tx);
        end
    endtask

endclass





`endif 
