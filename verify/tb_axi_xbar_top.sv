/* ***********************************************************
    document:       tb_axi_xbar_top.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    tb top for AXI4+ATOP crossbar implementation
**************************************************************/
/// Features to implement:
/// - Advanced test scenarios with configurable crossbar parameters
/// - Coverage-driven verification with functional and code coverage
/// - Protocol compliance checking with assertions
/// - Performance verification at 250MHz target frequency
/// - Atomic operation (ATOP) verification
/// - Stress testing and corner case coverage
`ifndef __TB_AXI_XBAR_TOP_SV__
`define __TB_AXI_XBAR_TOP_SV__

`include "uvm_macros.svh"
`include "axi_typedef_pkg.svh"
`include "axi_math_pkg.svh"
`include "axi_inf.sv"
`include "v_axi_inf.sv"
`include "tb_xbar_param_pkg.svh"

module tb_axi_xbar_top;
    import uvm_pkg::*;

    //{{{ tb cfg 
    parameter int   TbNumSlaves     = tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE;        // Number of slave ports to test
    parameter int   TbNumMasters    = tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE;       // Number of master ports to test
    parameter int   TbMstIdWidth    = tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE;     // Extended ID width for testing
    parameter int   TbSlvIdWidth    = tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE;
    parameter int   TbAxiDataWidth  = tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE;         // Data width for verification
    parameter int   TbAxiAddrWidth  = tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE;         // Address width
    parameter int   TbNumAddrRules  = tb_xbar_param_pkg::TB_ADDR_RULES_NUMBER_IN_USE;   // Number of address map rules
    parameter int   TbAxiUserWidth  = tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE;      
    parameter time  TbClkPeriod     = tb_xbar_param_pkg::CLK_PERIOD;                    // 250MHz target frequency
    //}}} 
    //{{{  Clock and reset
    bit clk;
    logic rst_n;
    // Clock generation
    initial begin
      clk <= 1'b0;
      forever begin
        #(TbClkPeriod) clk <= !clk;
      end   
    end

    // Reset generation
    initial begin
      #3ns;
      rst_n <= 1'b0;
      repeat ($urandom_range(5,20)) @(posedge clk); //deassertion can only be synchronous with a rising edge of ACLK.
      rst_n <= 1'b1;
    end
    //}}}
  localparam int MstPortsIdxWidth = axi_math_pkg::idx_width(TbNumMasters); //extended id width from the persipective of xbar
  //localparam int TbSlvIdWidth = TbMstIdWidth + MstPortsIdxWidth;
    //{{{ Interfaces 
    // interfaces for DUT
    axi_inf # (
        .AXI_ADDR_WIDTH ( TbAxiAddrWidth      ),
        .AXI_DATA_WIDTH ( TbAxiDataWidth      ),
        //.AXI_ID_WIDTH   ( MstIdWidth          ),
        .AXI_ID_WIDTH   ( TbMstIdWidth          ),
        .AXI_USER_WIDTH ( TbAxiUserWidth      )
    ) master_infs[TbNumMasters-1:0]();
    axi_inf # (
        .AXI_ADDR_WIDTH ( TbAxiAddrWidth      ),
        .AXI_DATA_WIDTH ( TbAxiDataWidth      ),
        .AXI_ID_WIDTH   ( TbSlvIdWidth        ),
        .AXI_USER_WIDTH ( TbAxiUserWidth      )
    ) slave_infs[TbNumSlaves-1:0]();
    // virtual interfaces for test
    v_axi_inf_mst # (
        .AXI_ADDR_WIDTH ( TbAxiAddrWidth      ),
        .AXI_DATA_WIDTH ( TbAxiDataWidth      ),
        .AXI_ID_WIDTH   ( TbMstIdWidth          ),
        .AXI_USER_WIDTH ( TbAxiUserWidth      )
    ) master_vifs[TbNumMasters] ();
        //.clk (clk),
        //.rst_n (rst_n)
    //) ;
    v_axi_inf_slv # (
        .AXI_ADDR_WIDTH ( TbAxiAddrWidth      ),
        .AXI_DATA_WIDTH ( TbAxiDataWidth      ),
        .AXI_ID_WIDTH   ( TbSlvIdWidth        ),
        .AXI_USER_WIDTH ( TbAxiUserWidth      )
    ) slave_vifs[TbNumSlaves] ();
        //.clk (clk),
        //.rst_n (rst_n)
    //) ;
    //}}}
    //{{{ assign 
    for(genvar i=0; i<TbNumMasters; i++) begin
        assign master_vifs[i].clk = clk;   
        assign master_vifs[i].rst_n = rst_n;
    end
    for(genvar i=0; i<TbNumSlaves; i++) begin
        assign slave_vifs[i].clk = clk;   
        assign slave_vifs[i].rst_n = rst_n;
    end
    for(genvar i=0; i<TbNumMasters; i++) begin : assign_masters 
        assign master_vifs[i].aw_ready  = master_infs[i].aw_ready   ;        
        assign master_vifs[i].w_ready   = master_infs[i].w_ready  ;         
        assign master_vifs[i].b_valid   = master_infs[i].b_valid  ;         
        assign master_vifs[i].b_id      = master_infs[i].b_id     ;         
        assign master_vifs[i].b_user    = master_infs[i].b_user   ;         
        assign master_vifs[i].b_resp    = master_infs[i].b_resp  ;
        assign master_vifs[i].ar_ready  = master_infs[i].ar_ready  ;        
        assign master_vifs[i].r_valid   = master_infs[i].r_valid  ;        
        assign master_vifs[i].r_id      = master_infs[i].r_id     ;        
        assign master_vifs[i].r_data    = master_infs[i].r_data   ;        
        assign master_vifs[i].r_last    = master_infs[i].r_last   ;        
        assign master_vifs[i].r_user    = master_infs[i].r_user   ;        
        assign master_vifs[i].r_resp    = master_infs[i].r_resp  ;

        assign master_infs[i].aw_id     = master_vifs[i].aw_id      ;        
        assign master_infs[i].aw_addr   = master_vifs[i].aw_addr    ;        
        assign master_infs[i].aw_lock   = master_vifs[i].aw_lock    ;        
        assign master_infs[i].aw_valid  = master_vifs[i].aw_valid   ;        
        assign master_infs[i].aw_user   = master_vifs[i].aw_user    ;        
        assign master_infs[i].aw_len    = master_vifs[i].aw_len     ;        
        assign master_infs[i].aw_size   = master_vifs[i].aw_size    ;        
        assign master_infs[i].aw_burst  = master_vifs[i].aw_burst   ;        
        assign master_infs[i].aw_cache  = master_vifs[i].aw_cache   ;        
        assign master_infs[i].aw_prot   = master_vifs[i].aw_prot    ;        
        assign master_infs[i].aw_qos    = master_vifs[i].aw_qos     ;        
        assign master_infs[i].aw_region = master_vifs[i].aw_region  ;        
        assign master_infs[i].aw_atop   = master_vifs[i].aw_atop    ;        
        assign master_infs[i].w_data    = master_vifs[i].w_data   ;         
        assign master_infs[i].w_valid   = master_vifs[i].w_valid  ;         
        assign master_infs[i].w_strb    = master_vifs[i].w_strb   ;         
        assign master_infs[i].w_last    = master_vifs[i].w_last   ;         
        assign master_infs[i].w_user    = master_vifs[i].w_user   ;         
        assign master_infs[i].b_ready   = master_vifs[i].b_ready  ;         
        
        assign master_infs[i].ar_id     = master_vifs[i].ar_id     ;        
        assign master_infs[i].ar_addr   = master_vifs[i].ar_addr   ;        
        assign master_infs[i].ar_lock   = master_vifs[i].ar_lock   ;        
        assign master_infs[i].ar_user   = master_vifs[i].ar_user   ;        
        assign master_infs[i].ar_valid  = master_vifs[i].ar_valid  ;        
        assign master_infs[i].ar_len    = master_vifs[i].ar_len     ;        
        assign master_infs[i].ar_size   = master_vifs[i].ar_size    ;        
        assign master_infs[i].ar_burst  = master_vifs[i].ar_burst   ;        
        assign master_infs[i].ar_cache  = master_vifs[i].ar_cache   ;        
        assign master_infs[i].ar_prot   = master_vifs[i].ar_prot    ;        
        assign master_infs[i].ar_qos    = master_vifs[i].ar_qos     ;        
        assign master_infs[i].ar_region = master_vifs[i].ar_region  ;        
        assign master_infs[i].r_ready   = master_vifs[i].r_ready  ;        
    end
    for(genvar i=0; i<TbNumSlaves; i++)begin : assign_slaves 
        assign slave_infs[i].aw_ready  = slave_vifs[i].aw_ready   ;        
        assign slave_infs[i].w_ready   = slave_vifs[i].w_ready  ;         
        assign slave_infs[i].b_valid   = slave_vifs[i].b_valid  ;         
        assign slave_infs[i].b_id      = slave_vifs[i].b_id     ;         
        assign slave_infs[i].b_resp    = slave_vifs[i].b_resp  ;        
        assign slave_infs[i].b_user    = slave_vifs[i].b_user   ;         
        assign slave_infs[i].ar_ready  = slave_vifs[i].ar_ready  ;        
        assign slave_infs[i].r_valid   = slave_vifs[i].r_valid  ;        
        assign slave_infs[i].r_id      = slave_vifs[i].r_id     ;        
        assign slave_infs[i].r_data    = slave_vifs[i].r_data   ;        
        assign slave_infs[i].r_last    = slave_vifs[i].r_last   ;        
        assign slave_infs[i].r_user    = slave_vifs[i].r_user   ;        
        assign slave_infs[i].r_resp    = slave_vifs[i].r_resp  ;  

        assign slave_vifs[i].aw_id     = slave_infs[i].aw_id      ;        
        assign slave_vifs[i].aw_addr   = slave_infs[i].aw_addr    ;        
        assign slave_vifs[i].aw_lock   = slave_infs[i].aw_lock    ;        
        assign slave_vifs[i].aw_valid  = slave_infs[i].aw_valid   ;        
        assign slave_vifs[i].aw_user   = slave_infs[i].aw_user    ;        
        assign slave_vifs[i].aw_len    = slave_infs[i].aw_len     ;        
        assign slave_vifs[i].aw_size   = slave_infs[i].aw_size    ;        
        assign slave_vifs[i].aw_burst  = slave_infs[i].aw_burst   ;        
        assign slave_vifs[i].aw_cache  = slave_infs[i].aw_cache   ;        
        assign slave_vifs[i].aw_prot   = slave_infs[i].aw_prot    ;        
        assign slave_vifs[i].aw_qos    = slave_infs[i].aw_qos     ;        
        assign slave_vifs[i].aw_region = slave_infs[i].aw_region  ;        
        assign slave_vifs[i].aw_atop   = slave_infs[i].aw_atop    ;        
        assign slave_vifs[i].w_data    = slave_infs[i].w_data   ;         
        assign slave_vifs[i].w_strb    = slave_infs[i].w_strb   ;         
        assign slave_vifs[i].w_last    = slave_infs[i].w_last   ;         
        assign slave_vifs[i].w_user    = slave_infs[i].w_user   ;         
        assign slave_vifs[i].w_valid   = slave_infs[i].w_valid  ;         
        assign slave_vifs[i].b_ready   = slave_infs[i].b_ready  ;         
        assign slave_vifs[i].ar_addr   = slave_infs[i].ar_addr   ;        
        assign slave_vifs[i].ar_id     = slave_infs[i].ar_id     ;        
        assign slave_vifs[i].ar_lock   = slave_infs[i].ar_lock   ;        
        assign slave_vifs[i].ar_user   = slave_infs[i].ar_user   ;        
        assign slave_vifs[i].ar_valid  = slave_infs[i].ar_valid  ;        
        assign slave_vifs[i].ar_len    = slave_infs[i].ar_len     ;        
        assign slave_vifs[i].ar_size   = slave_infs[i].ar_size    ;        
        assign slave_vifs[i].ar_burst  = slave_infs[i].ar_burst   ;        
        assign slave_vifs[i].ar_cache  = slave_infs[i].ar_cache   ;        
        assign slave_vifs[i].ar_prot   = slave_infs[i].ar_prot    ;        
        assign slave_vifs[i].ar_qos    = slave_infs[i].ar_qos     ;        
        assign slave_vifs[i].ar_region = slave_infs[i].ar_region  ;        
        assign slave_vifs[i].r_ready   = slave_infs[i].r_ready  ;        
    end
    //}}}        
    //{{{ Cfg to DUT
    parameter axi_typedef_pkg::xbar_cfg_t XbarCfg = '{
    NoSlvPorts:         TbNumMasters,       // Number of slave ports (master connections)     
    NoMstPorts:         TbNumSlaves,        // Number of master ports (slave connections)
    MaxMstTrans:        tb_xbar_param_pkg::TB_MAX_MASTER_TRANS, //8,
    MaxSlvTrans:        tb_xbar_param_pkg::TB_MAX_SLAVE_TRANS,  //4,
    FallThrough:        1'b0,
    LatencyMode:        10'b10_010_10_010,  // Pipeline AW/AR Demux: [AW, W, B, AR, R] Mux: [AW, W, B, AR, R]
    //AxiIdWidthSlvPorts: TbSlvIdWidth,
    AxiIdWidthSlvPorts: TbMstIdWidth,
    //AxiIdUsedSlvPorts:  TbSlvIdWidth,
    AxiIdUsedSlvPorts:  TbMstIdWidth,
    UniqueIds:          1'b0,
    AxiAddrWidth:       TbAxiAddrWidth,
    AxiDataWidth:       TbAxiDataWidth,
    NoAddrRules:        TbNumAddrRules,
    PipelineStages:     1
    };
    //}}}

    // Connectivity matrix - students can modify for testing partial connectivity
  localparam bit [TbNumSlaves-1:0][TbNumMasters-1:0] Connectivity = '1;

  // Configuration inputs (addr_map)
  typedef axi_typedef_pkg::xbar_rule_32_t            rule_t;
  rule_t [TbNumAddrRules-1:0]                        addr_map;
  logic [XbarCfg.NoSlvPorts-1:0]                     en_default_mst_port = '0;
  logic [TbNumSlaves-1:0][MstPortsIdxWidth-1:0]      default_mst_port = '0;
  logic test_en = 1'b0;
  
  initial begin
    for(int i=0; i<TbNumAddrRules; i++) begin
        addr_map[i] = assign_addr_map(i);
    end
  end
  //Celine TODO (now tie support_atomic to 1'b1)
  function rule_t assign_addr_map(int No);
    rule_t map;
    map.idx = No;
    map.start_addr = No * tb_xbar_param_pkg::BASE_ADDR_OFFSET;
    map.end_addr = (No+1) * tb_xbar_param_pkg::BASE_ADDR_OFFSET;
    map.support_atomic = 1'b1;
    return map;
  endfunction
  
  /*    -----------             --------------------------------------------------             -----------     */
  /*    | mst_vif |             |         ------------------------------         |             | slv_vif |     */
  /*    |         |             |...      |->slv_req          mst_rep->|      ...|             |         |     */
  /*    |         |   mst_infs  |         |->...                  ...->|         |   slv_infs  |         |     */
  /*    | mst_vif |<----------->|slv_port |           XBAR             | mst_port|<----------->| slv_vif |     */
  /*    |         |             |         |<-slv_rsp          mst_rsp<-|         |             |         |     */
  /*    |         |             |...      |<-...                  ...<-|      ...|             |         |     */
  /*    | mst_vif |             |         ------------------------------         |             | svl_vif |     */
  /*    |         |             |                                                |             |         |     */
  /*    |  ...    |             |                   xbar_wrapper                 |             |  ...    |     */
  /*    -----------             --------------------------------------------------             -----------     */
  /*     Manageers                                  Interconnect                               Subordinates    */

  // DUT instantiation
  axi_xbar_wrapper #(
  .AXI_USER_WIDTH   (TbAxiUserWidth),
  .Cfg              (XbarCfg),
  .ATOPS            (1'b1),
  .CONNECTIVITY     (Connectivity),
  .rule_t           (rule_t)
  )
  i_axi_dut_wrapper(
  .clk_i                    (clk),
  .rst_ni                   (rst_n),
  .test_i                   (test_en),
  .addr_map_i               (addr_map),
  .en_default_mst_port_i    (en_default_mst_port),
  .default_mst_port_i       (default_mst_port),
  .slv_ports                (master_infs),
  .mst_ports                (slave_infs)
  );
  
    // tb configuration 
    bit[TbNumSlaves-1:0] enable_slv_b_channel = '0;
  
    //{{{ UVM test setup (config, vifs) 
    //initial begin
    initial begin    
        void'($value$plusargs("enable_slv_b_channel=%d", enable_slv_b_channel));
        $display("enable_slv_b_channel: %0b", enable_slv_b_channel);
        //uvm setup configuration
        uvm_config_db#(int)::set(uvm_root::get(),"uvm_test_top","enable_slv_b_channel",enable_slv_b_channel);
        //{{{ uvm setup vifs 
        uvm_config_db#(virtual v_axi_inf_mst #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE), 
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "mst_vif[0]", master_vifs[0]);
        uvm_config_db#(virtual v_axi_inf_mst #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "mst_vif[1]", master_vifs[1]);
        uvm_config_db#(virtual v_axi_inf_mst #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "mst_vif[2]", master_vifs[2]);
        uvm_config_db#(virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "slv_vif[0]", slave_vifs[0]);
        uvm_config_db#(virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "slv_vif[1]", slave_vifs[1]);
        uvm_config_db#(virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "slv_vif[2]", slave_vifs[2]);
        uvm_config_db#(virtual v_axi_inf_slv #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
        ))::set(uvm_root::get(), "uvm_test_top.env*", "slv_vif[3]", slave_vifs[3]);
        //}}}
        run_test("xbar_simple_test_case");
    end
    //}}}
    //{{{ Final check
    final begin
        if (uvm_report_server::get_server().get_severity_count(UVM_FATAL) > 0) begin
            $display("Simulation finished with UVM_FATAL errors");
            $finish(2);
        end
        else if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) > 0) begin
            $display("Simulation finished with UVM_ERROR errors");
            $finish(1);
        end
        else begin
            $display("Test passed successfully");
            $finish(0);
        end
    end
    //}}}

    
endmodule
`endif 
