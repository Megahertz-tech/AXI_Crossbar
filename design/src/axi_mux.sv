// AXI Multiplexer: This module multiplexes the AXI4 slave ports down to one master port.
// The AXI IDs from the slave ports get extended with the respective slave port index.
// The extension width can be calculated with `$clog2(NoSlvPorts)`. This means the AXI
// ID for the master port has to be this `$clog2(NoSlvPorts)` wider than the ID for the
// slave ports.
// Responses are switched based on these bits. For example, with 4 slave ports
// a response with ID `6'b100110` will be forwarded to slave port 2 (`2'b10`).

// Register macros
`include "common_cells/assertions.svh"
`include "common_cells/registers.svh"

module axi_mux #(
  // AXI parameter and channel types
  parameter int unsigned SlvAxiIDWidth = 32'd0, // AXI ID width, slave ports
  parameter type         slv_aw_chan_t = logic, // AW Channel Type, slave ports
  parameter type         mst_aw_chan_t = logic, // AW Channel Type, master port
  parameter type         w_chan_t      = logic, //  W Channel Type, all ports
  parameter type         slv_b_chan_t  = logic, //  B Channel Type, slave ports
  parameter type         mst_b_chan_t  = logic, //  B Channel Type, master port
  parameter type         slv_ar_chan_t = logic, // AR Channel Type, slave ports
  parameter type         mst_ar_chan_t = logic, // AR Channel Type, master port
  parameter type         slv_r_chan_t  = logic, //  R Channel Type, slave ports
  parameter type         mst_r_chan_t  = logic, //  R Channel Type, master port
  parameter type         slv_req_t     = logic, // Slave port request type
  parameter type         slv_resp_t    = logic, // Slave port response type
  parameter type         mst_req_t     = logic, // Master ports request type
  parameter type         mst_resp_t    = logic, // Master ports response type
  parameter int unsigned NoSlvPorts    = 32'd0, // Number of slave ports
  // Maximum number of outstanding transactions per write
  parameter int unsigned MaxWTrans     = 32'd8,
  // If enabled, this multiplexer is purely combinatorial
  parameter bit          FallThrough   = 1'b0,
  // add spill register on write master ports, adds a cycle latency on write channels
  parameter bit          SpillAw       = 1'b1,
  parameter bit          SpillW        = 1'b0,
  parameter bit          SpillB        = 1'b0,
  // add spill register on read master ports, adds a cycle latency on read channels
  parameter bit          SpillAr       = 1'b1,
  parameter bit          SpillR        = 1'b0
) (
  input  logic                       clk_i,    // Clock
  input  logic                       rst_ni,   // Asynchronous reset active low
  input  logic                       test_i,   // Test Mode enable
  // slave ports (AXI inputs), connect master modules here
  input  slv_req_t  [NoSlvPorts-1:0] slv_reqs_i,
  output slv_resp_t [NoSlvPorts-1:0] slv_resps_o,
  // master port (AXI outputs), connect slave modules here
  output mst_req_t                   mst_req_o,
  input  mst_resp_t                  mst_resp_i
);

  localparam int unsigned MstIdxBits    = $clog2(NoSlvPorts);
  localparam int unsigned MstAxiIDWidth = SlvAxiIDWidth + MstIdxBits;
  typedef logic [MstIdxBits-1:0] extended_id_t;
  //{{{ inner debug signals 
  logic [NoSlvPorts-1:0]          debug_i_aw_valids;
  logic [NoSlvPorts-1:0]          debug_i_w_valids ;
  for(genvar i=0;i<NoSlvPorts;i++)begin
    assign debug_i_aw_valids[i] = slv_reqs_i[i].aw_valid;
    assign debug_i_w_valids[i] = slv_reqs_i[i].w_valid;
  end
  //}}}

/*    topology                                                                       */
/*      -------- <= ---------      <-    <-    <-  --------   ||                     */
/*   ==>|  ID  | ==>|aw  arb|-->  -->   -->   -->  |      | <-||                     */
/*   ...|extend|    ---------   ----------         |      |...||                     */
/*    =>|      | ==>  ==>  ==>  |w order |--> -->  |      |-->||                     */
/*      |      |  <=   <=   <=  ---------- <-  <-  |spill |   ||                     */
/*      |      |                                   |      |   || Subordinate         */
/*    <=|      |  =>   =>   =>  ---------- ->  ->  | reg  | ->||                     */
/*   ...|  ID  | <==  <==  <==  |b demux |<-- <--  |      |...||                     */
/*   <==|strip |    ---------   ----------         |      |<--||                     */
/*      |      | ==>|ar  arb|-->  -->   -->   -->  |      |   ||                     */
/*      -------- <= ---------      <-    <-    <-  --------   ||                     */
/*     id_prepend    fair_rr     fifo/demux        spill reg                         */
/*                                                            interface              */

    //{{{ internal signals 
    mst_aw_chan_t [NoSlvPorts-1:0]  aw_chans    ;
    logic [NoSlvPorts-1:0]          aw_valids   ;
    logic [NoSlvPorts-1:0]          aw_readies  ;
    w_chan_t [NoSlvPorts-1:0]       w_chans     ;
    logic [NoSlvPorts-1:0]          w_valids   ;
    logic [NoSlvPorts-1:0]          w_readies  ;
    mst_b_chan_t [NoSlvPorts-1:0]   b_chans     ;
    logic [NoSlvPorts-1:0]          b_valids   ;
    logic [NoSlvPorts-1:0]          b_readies  ;
    mst_ar_chan_t [NoSlvPorts-1:0]  ar_chans    ;
    logic [NoSlvPorts-1:0]          ar_valids   ;
    logic [NoSlvPorts-1:0]          ar_readies  ;
    mst_r_chan_t[NoSlvPorts-1:0]    r_chans     ;
    logic [NoSlvPorts-1:0]          r_valids   ;
    logic [NoSlvPorts-1:0]          r_readies  ;
    //}}}}
//{{{ axi_id_prepend
    /*  prepend extended id (slave port index) to master ports (connect with Subordinate) 
        strip   extended id to slave ports.                                               */
    typedef logic[MstIdxBits-1:0] id_extend_t;
    for(genvar i=0; i<NoSlvPorts; i++) begin  : axi_id_prepend
        axi_id_prepend #(
        .NoBus            ( 32'd1               ), // Can take multiple axi busses
        .AxiIdWidthSlvPort( SlvAxiIDWidth       ), // AXI ID Width of the Slave Ports
        .AxiIdWidthMstPort( MstAxiIDWidth       ), // AXI ID Width of the Master Ports
        .slv_aw_chan_t    ( slv_aw_chan_t       ),
        .slv_w_chan_t     ( w_chan_t            ),
        .slv_b_chan_t     ( slv_b_chan_t        ),
        .slv_ar_chan_t    ( slv_ar_chan_t       ),
        .slv_r_chan_t     ( slv_r_chan_t        ),
        .mst_aw_chan_t    ( mst_aw_chan_t       ),
        .mst_w_chan_t     ( w_chan_t            ),
        .mst_b_chan_t     ( mst_b_chan_t        ),
        .mst_ar_chan_t    ( mst_ar_chan_t       ),
        .mst_r_chan_t     ( mst_r_chan_t        )        
        ) i_axi_id_prepend (
            .pre_id_i(id_extend_t'(i)),

            .slv_aw_chans_i (slv_reqs_i[i].aw),              
            .slv_aw_valids_i(slv_reqs_i[i].aw_valid),
            .slv_aw_readies_o(slv_resps_o[i].aw_ready),
                                 
            .slv_w_chans_i(slv_reqs_i[i].w),
            .slv_w_valids_i(slv_reqs_i[i].w_valid),
            .slv_w_readies_o(slv_resps_o[i].w_ready),
                                 
            .slv_b_chans_o(slv_resps_o[i].b),
            .slv_b_valids_o(slv_resps_o[i].b_valid),
            .slv_b_readies_i(slv_reqs_i[i].b_ready),
                                 
            .slv_ar_chans_i(slv_reqs_i[i].ar),
            .slv_ar_valids_i(slv_reqs_i[i].ar_valid),
            .slv_ar_readies_o(slv_resps_o[i].ar_ready),
                                 
            .slv_r_chans_o(slv_resps_o[i].r),
            .slv_r_valids_o(slv_resps_o[i].r_valid),
            .slv_r_readies_i(slv_reqs_i[i].r_ready),
                                 
            .mst_aw_chans_o(aw_chans[i]),
            .mst_aw_valids_o(aw_valids[i]),
            .mst_aw_readies_i(aw_readies[i]),
                                 
            .mst_w_chans_o(w_chans[i]),
            .mst_w_valids_o(w_valids[i]),
            .mst_w_readies_i(w_readies[i]),
                                 
            .mst_b_chans_i(b_chans[i]),
            .mst_b_valids_i(b_valids[i]),
            .mst_b_readies_o(b_readies[i]),
                                 
            .mst_ar_chans_o(ar_chans[i]),
            .mst_ar_valids_o(ar_valids[i]),
            .mst_ar_readies_i(ar_readies[i]),
                                 
            .mst_r_chans_i(r_chans[i]),
            .mst_r_valids_i(r_valids[i]),
            .mst_r_readies_o(r_readies[i])      
        );
    end
    
//}}}
//{{{ inner id full debug signals 
    logic [NoSlvPorts-1:0] [SlvAxiIDWidth-1:0] debug_ext_before_aw_id;
    logic [NoSlvPorts-1:0] [MstAxiIDWidth-1:0] debug_ext_after_aw_id;
    id_extend_t[NoSlvPorts-1:0]     debug_ext_aw_id;
    for(genvar i=0; i<NoSlvPorts; i++) begin
        assign debug_ext_before_aw_id[i] = slv_reqs_i[i].aw.id;
        assign debug_ext_after_aw_id[i] = aw_chans[i].id;
        assign debug_ext_aw_id[i] = aw_chans[i].id[SlvAxiIDWidth +: MstIdxBits];
    end
//}}}
//{{{ arbitor for aw 
    localparam int unsigned IDX_WIDTH = axi_math_pkg::idx_width(NoSlvPorts);
    mst_aw_chan_t           aw_gnt;
    logic                   aw_valid_gnt;
    logic                   aw_ready_sp;
    logic[IDX_WIDTH-1:0]    aw_idx_gnt;
    fair_round_robin_arbiter #(
        .NumIn     (NoSlvPorts   ),
        .DataType  (mst_aw_chan_t)
    ) i_aw_fair_rr_arb (
        .clk_i,
        .rst_ni,
        .flush_i    (1'b0),
        .req_i      (aw_valids),
        .data_i     (aw_chans),
        .gnt_i      (aw_ready_sp),
        .gnt_o      (aw_readies),
        .req_o      (aw_valid_gnt),
        .data_o     (aw_gnt),
        .idx_o      (aw_idx_gnt)  
    );

    spill_register #(
        .T       ( mst_aw_chan_t  ),
        .Bypass  ( ~SpillAw   )
    ) i_aw_spill_reg (
        .clk_i,
        .rst_ni,
        .valid_i ( aw_valid_gnt   ),
        .ready_o ( aw_ready_sp    ),
        .data_i  ( aw_gnt         ),
        .valid_o ( mst_req_o.aw_valid),
        .ready_i ( mst_resp_i.aw_ready),
        .data_o  ( mst_req_o.aw     )
    );
//}}}
//{{{ w 
/*      An interconnect that combines write transactions from different Managers must 
        ensure that it forwards the write data in address order.                                 */
    typedef enum logic [1:0] {
        AW_IDLE      = 2'b01,
        AW_APPROVE   = 2'b10
    } aw_state_e;
    enum {I_BIT = 0, A_BIT = 1} state_bit;
    aw_state_e      aw_cur_sta, aw_nxt_sta;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            aw_cur_sta <= AW_IDLE;
        end else begin
            aw_cur_sta <= aw_nxt_sta;
        end
    end
    logic aw_extended_id_push_en;
    always_comb begin
        aw_nxt_sta = aw_cur_sta;
        aw_extended_id_push_en = 1'b0;
        unique case(1'b1) 
            aw_cur_sta[I_BIT]: begin
                if(aw_valid_gnt) begin
                    aw_nxt_sta = AW_APPROVE;
                    aw_extended_id_push_en = 1'b1; // w can arrive following the aw 
                end
            end
            aw_cur_sta[A_BIT]: begin
                if(aw_ready_sp) begin
                    aw_nxt_sta = AW_IDLE;
                end
            end
            default: begin end
        endcase 
    end
    //{{{ w inner debug signals
    logic debug_aw_confirmed;
    assign debug_aw_confirmed = aw_valid_gnt && mst_resp_i.aw_ready;
    extended_id_t   debug_w_push_id;
    assign debug_w_push_id = aw_gnt.id[SlvAxiIDWidth +: MstIdxBits];
    logic [MstAxiIDWidth-1:0]  debug_w_aw_gnt_id_full;
    assign debug_w_aw_gnt_id_full = aw_gnt.id;
    //}}}
    extended_id_t  w_ext_id;
    logic w_pop_en;
    logic w_id_empty;
    fifo_v4 #(
        .FALL_THROUGH   (0),
        .DEPTH          (MaxWTrans * NoSlvPorts),
        .dtype          (extended_id_t)
    ) i_w_extended_id_fifo (
        .clk_i,
        .rst_ni,
        .flush_i(1'b0),
        .testmode_i(test_i),
        .push_i(aw_extended_id_push_en),
        //.data_i(mst_req_o.aw.id[SlvAxiIDWidth+:MstIdxBits]),
        .data_i(aw_gnt.id[SlvAxiIDWidth+:MstIdxBits]),
        .pop_i(w_pop_en),
        .data_o(w_ext_id),
        .full_o(/*not used*/),
        .empty_o(w_id_empty),
        .usage_o(/*not used*/)
    );
    typedef enum logic [1:0] {
        W_IDLE      = 2'b01,
        W_APPROVE   = 2'b10
    } w_state_e;

    w_state_e   w_cur_sta, w_nxt_sta;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            w_cur_sta <= W_IDLE;
        end else begin
            w_cur_sta <= w_nxt_sta;
        end
    end
    logic [NoSlvPorts-1:0]          w_valids_delay;         
    w_chan_t [NoSlvPorts-1:0]       w_chans_delay ;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            w_valids_delay <= '0;
            w_chans_delay  <= '0;
        end else begin
            w_valids_delay <= w_valids;
            w_chans_delay  <= w_chans;
        end
    end
    logic mst_w_ready_sp;
    always_comb begin
        w_nxt_sta = w_cur_sta;
        w_pop_en  = 0;
        unique case(1'b1) 
            w_cur_sta[I_BIT]: begin
                if((!w_id_empty) && (w_valids != 0)) begin
                    for(int unsigned i=0; i<NoSlvPorts; i++) begin
                        if(w_valids[i] && (i == w_ext_id)) begin
                            w_nxt_sta = W_APPROVE;
                        end 
                    end
                end
            end
            w_cur_sta[A_BIT]: begin
                if(w_valids_delay[w_ext_id] && mst_w_ready_sp && w_chans_delay[w_ext_id].last) begin
                //if(w_valids[w_ext_id] && mst_w_ready_sp && w_chans[w_ext_id].last) begin
                    w_nxt_sta = W_IDLE;
                    w_pop_en = 1'b1;
                end
            end
            default: begin end
        endcase 
    end

    logic       w_valid;
    w_chan_t    w_chan;
    always_comb begin
        w_valid     = 1'b0;
        w_chan      = '0;
        w_readies   = '0;
        if(w_cur_sta == W_APPROVE) begin
            w_valid = w_valids_delay[w_ext_id];
            w_chan  = w_chans_delay[w_ext_id];
            if(mst_w_ready_sp) w_readies = 1'b1 << w_ext_id;
        end
    end
    spill_register #(
      .T       ( w_chan_t ),
      .Bypass  ( ~SpillW  )
    ) i_w_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( w_valid        ),
      .ready_o ( mst_w_ready_sp        ),
      .data_i  ( w_chan         ),
      .valid_o ( mst_req_o.w_valid  ),
      .ready_i ( mst_resp_i.w_ready ),
      .data_o  ( mst_req_o.w        )
    );
//}}}
//{{{ b
    // demux b 
    logic           b_valid_sp;
    mst_b_chan_t    b_chan_sp;
    extended_id_t   b_id_ext;  
    assign b_id_ext = mst_resp_i.b.id[SlvAxiIDWidth +: MstIdxBits];
    assign b_chans  = {NoSlvPorts{b_chan_sp}}; // go to strip id function
    always_comb begin 
        b_valids = '0;
        if(b_valid_sp) begin
            b_valids[b_id_ext] = 1'b1;
        end
    end
    //assign slv_b_valids = (b_valid_sp) ? (1<<b_id_ext) : '0;
    spill_register #(
      .T       ( mst_b_chan_t ),
      .Bypass  ( ~SpillB      )
    ) i_b_spill_reg (
      .clk_i   ( clk_i                      ),
      .rst_ni  ( rst_ni                     ),
      .valid_i ( mst_resp_i.b_valid         ),
      .ready_i ( b_readies[b_id_ext] ),
      .data_i  ( mst_resp_i.b               ),
      .valid_o ( b_valid_sp                 ),
      .ready_o ( mst_req_o.b_ready          ),
      .data_o  ( b_chan_sp                  )
    );
//}}}













  // TODO: Implement the AXI multiplexer logic here
  //
  // HINTS:
  // 1. Handle the case where NoSlvPorts == 1 (pass-through)
  // 2. For multiple slave ports, you need to:
  //    a) Prepend slave port index to transaction IDs
  //    b) Arbitrate between slave port requests (AW and AR channels)
  //    c) Multiplex W channel based on AW arbitration decisions
  //    d) Demultiplex B and R channels based on MSB bits of response IDs
  //    e) Use FIFOs to track write transaction routing
  // 3. Consider spill registers for timing optimization
  // 4. Ensure proper AXI protocol compliance (handshaking, etc.)
  //
  // Key submodules you'll need:
  // - axi_id_prepend: To add slave port index to transaction IDs
  // - rr_arb_tree: Round-robin arbiter for AW/AR channels
  // - fifo_v3: FIFO for tracking write transactions
  // - spill_register: Pipeline registers for timing
  //
  // Architecture Overview:
  // [Slave Ports] -> [ID Prepend] -> [Arbiters] -> [Spill Regs] -> [Master Port]
  //                                      |
  //                                  [W FIFO] (tracks AW decisions)
  //
  // [Master Port] -> [Spill Regs] -> [ID Decode] -> [Slave Ports]

  // Your implementation goes here...

endmodule

// interface wrap
`include "axi/assign.svh"
`include "axi/typedef.svh"
module axi_mux_intf #(
  parameter int unsigned SLV_AXI_ID_WIDTH = 32'd0, // Synopsys DC requires default value for params
  parameter int unsigned MST_AXI_ID_WIDTH = 32'd0,
  parameter int unsigned AXI_ADDR_WIDTH   = 32'd0,
  parameter int unsigned AXI_DATA_WIDTH   = 32'd0,
  parameter int unsigned AXI_USER_WIDTH   = 32'd0,
  parameter int unsigned NO_SLV_PORTS     = 32'd0, // Number of slave ports
  // Maximum number of outstanding transactions per write
  parameter int unsigned MAX_W_TRANS      = 32'd8,
  // if enabled, this multiplexer is purely combinatorial
  parameter bit          FALL_THROUGH     = 1'b0,
  // add spill register on write master ports, adds a cycle latency on write channels
  parameter bit          SPILL_AW         = 1'b1,
  parameter bit          SPILL_W          = 1'b0,
  parameter bit          SPILL_B          = 1'b0,
  // add spill register on read master ports, adds a cycle latency on read channels
  parameter bit          SPILL_AR         = 1'b1,
  parameter bit          SPILL_R          = 1'b0
) (
  input  logic   clk_i,                  // Clock
  input  logic   rst_ni,                 // Asynchronous reset active low
  input  logic   test_i,                 // Testmode enable
  AXI_BUS.Slave  slv [NO_SLV_PORTS-1:0], // slave ports
  AXI_BUS.Master mst                     // master port
);

  typedef logic [SLV_AXI_ID_WIDTH-1:0] slv_id_t;
  typedef logic [MST_AXI_ID_WIDTH-1:0] mst_id_t;
  typedef logic [AXI_ADDR_WIDTH -1:0]  addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0]   user_t;
  // channels typedef
  `AXI_TYPEDEF_AW_CHAN_T(slv_aw_chan_t, addr_t, slv_id_t, user_t)
  `AXI_TYPEDEF_AW_CHAN_T(mst_aw_chan_t, addr_t, mst_id_t, user_t)

  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)

  `AXI_TYPEDEF_B_CHAN_T(slv_b_chan_t, slv_id_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(mst_b_chan_t, mst_id_t, user_t)

  `AXI_TYPEDEF_AR_CHAN_T(slv_ar_chan_t, addr_t, slv_id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(mst_ar_chan_t, addr_t, mst_id_t, user_t)

  `AXI_TYPEDEF_R_CHAN_T(slv_r_chan_t, data_t, slv_id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(mst_r_chan_t, data_t, mst_id_t, user_t)

  `AXI_TYPEDEF_REQ_T(slv_req_t, slv_aw_chan_t, w_chan_t, slv_ar_chan_t)
  `AXI_TYPEDEF_RESP_T(slv_resp_t, slv_b_chan_t, slv_r_chan_t)

  `AXI_TYPEDEF_REQ_T(mst_req_t, mst_aw_chan_t, w_chan_t, mst_ar_chan_t)
  `AXI_TYPEDEF_RESP_T(mst_resp_t, mst_b_chan_t, mst_r_chan_t)

  slv_req_t  [NO_SLV_PORTS-1:0] slv_reqs;
  slv_resp_t [NO_SLV_PORTS-1:0] slv_resps;
  mst_req_t                     mst_req;
  mst_resp_t                    mst_resp;

  for (genvar i = 0; i < NO_SLV_PORTS; i++) begin : gen_assign_slv_ports
    `AXI_ASSIGN_TO_REQ(slv_reqs[i], slv[i])
    `AXI_ASSIGN_FROM_RESP(slv[i], slv_resps[i])
  end

  `AXI_ASSIGN_FROM_REQ(mst, mst_req)
  `AXI_ASSIGN_TO_RESP(mst_resp, mst)

  axi_mux #(
    .SlvAxiIDWidth ( SLV_AXI_ID_WIDTH ),
    .slv_aw_chan_t ( slv_aw_chan_t    ), // AW Channel Type, slave ports
    .mst_aw_chan_t ( mst_aw_chan_t    ), // AW Channel Type, master port
    .w_chan_t      ( w_chan_t         ), //  W Channel Type, all ports
    .slv_b_chan_t  ( slv_b_chan_t     ), //  B Channel Type, slave ports
    .mst_b_chan_t  ( mst_b_chan_t     ), //  B Channel Type, master port
    .slv_ar_chan_t ( slv_ar_chan_t    ), // AR Channel Type, slave ports
    .mst_ar_chan_t ( mst_ar_chan_t    ), // AR Channel Type, master port
    .slv_r_chan_t  ( slv_r_chan_t     ), //  R Channel Type, slave ports
    .mst_r_chan_t  ( mst_r_chan_t     ), //  R Channel Type, master port
    .slv_req_t     ( slv_req_t        ),
    .slv_resp_t    ( slv_resp_t       ),
    .mst_req_t     ( mst_req_t        ),
    .mst_resp_t    ( mst_resp_t       ),
    .NoSlvPorts    ( NO_SLV_PORTS     ), // Number of slave ports
    .MaxWTrans     ( MAX_W_TRANS      ),
    .FallThrough   ( FALL_THROUGH     ),
    .SpillAw       ( SPILL_AW         ),
    .SpillW        ( SPILL_W          ),
    .SpillB        ( SPILL_B          ),
    .SpillAr       ( SPILL_AR         ),
    .SpillR        ( SPILL_R          )
  ) i_axi_mux (
    .clk_i       ( clk_i     ), // Clock
    .rst_ni      ( rst_ni    ), // Asynchronous reset active low
    .test_i      ( test_i    ), // Test Mode enable
    .slv_reqs_i  ( slv_reqs  ),
    .slv_resps_o ( slv_resps ),
    .mst_req_o   ( mst_req   ),
    .mst_resp_i  ( mst_resp  )
  );
endmodule
