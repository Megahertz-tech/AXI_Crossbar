/* ***********************************************************
    document:       axi_demux_core.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_DEMUX_CORE__
`define __AXI_DEMUX_CORE__

module axi_demux_core #(
  parameter int unsigned AxiIdWidth     = 32'd0,
  parameter bit          AtopSupport    = 1'b1,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic,
  parameter type         b_chan_t       = logic,
  parameter type         r_chan_t       = logic,
  parameter int unsigned NoMstPorts     = 32'd0,
  parameter int unsigned MaxTrans       = 32'd8,
  parameter int unsigned AxiLookBits    = 32'd3,
  parameter bit          UniqueIds      = 1'b0,
  // Dependent parameters, DO NOT OVERRIDE!
  parameter int unsigned SelectWidth    = (NoMstPorts > 32'd1) ? $clog2(NoMstPorts) : 32'd1,
  parameter type         select_t       = logic [SelectWidth-1:0]
) (
  input  logic                          clk_i,
  input  logic                          rst_ni,
  input  logic                          test_i,
  // Slave Port
  input  axi_req_t                      slv_req_i,
  input  select_t                       slv_aw_select_i,
  input  select_t                       slv_ar_select_i,
  output axi_resp_t                     slv_resp_o,
  // Master Ports (one more for the xbar default subordinate to handle error situation)
  output axi_req_t    [NoMstPorts-1: 0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts-1: 0]  mst_resps_i
);
    localparam int unsigned NoIds     = 2**AxiLookBits;
    localparam int unsigned CntWidth  = axi_math_pkg::is_pow2(NoIds) ? axi_math_pkg::idx_width(MaxTrans) + 1 : axi_math_pkg::idx_width(MaxTrans);

/* The Max number of transaction in flight is defined by MaxTrans 
   This module maintains a counter for the transaction in flight (aw + ar) 
*/
    logic [CntWidth-1:0] aw_in_flight_cnt, ar_in_flight_cnt;
    logic [CntWidth-1:0] tr_in_flight_cnt;
    logic                tr_in_flight_full;
    assign tr_in_flight_cnt     = aw_in_flight_cnt + ar_in_flight_cnt;
    assign tr_in_flight_full    = (tr_in_flight_cnt == MaxTrans); 
    typedef enum logic [2:0] {
        AW_IDLE         = 3'b001, 
        AW_APPROVE      = 3'b010, // non-atomic aw
        AW_ATOP_APPROVE = 3'b100  // atomic aw 
    } aw_state_e;
    typedef enum logic [2:0] {
        AR_IDLE         = 3'b001,
        AR_APPROVE      = 3'b010, // ar
        AR_ATOP_APPROVE = 3'b100  // atomic aw 
    } ar_state_e;
    enum { AW_I_BIT = 0,        AW_A_BIT = 1,        AW_AA_BIT = 2    } aw_state_bit;
    enum { AR_I_BIT = 0,        AR_A_BIT = 1,        AR_AA_BIT = 2    } ar_state_bit_e;
    aw_state_e     aw_cur_sta,          aw_nxt_sta;
    ar_state_e              ar_cur_sta,     ar_nxt_sta;

//{{{ AW channel
/*  1.  When the interconnect is required to determine the destination address space or 
        Subordinate space, it must realign the address and write data. 
    2.  An interconnect that combines write transactions from different Managers must 
        ensure that it forwards the write data in address order.
    3.  Atomic transactions must not use AXI ID values that are used by Non-atomic transactions 
        that are outstanding at the same time. This rule applies to transactions on either 
        the AR or AW channel. This rule ensures that there are no ordering constraints between 
        Atomic transactions and Non-atomic transactions.                                            
            
            // 0. pre-condition: req_i.aw_valid = 1'b1
            // 1. in_flight transaction (aw+ar) is not up to MaxTrans
            //      for non-atomic transaction (aw_atop==0), if (!lookup_aw_sel_taken) || (look_up_aw_sel == aw_sel_i) 
            //      for atomic transaction     (!aw_atop==0), loop up (aw, ar) is not taken. 
            // 2. check if W sel FIFO is full 
            //      if avaliable : aw_id in-flight counter ++, push aw_sel into W FIFO
            //      if not       : stall 
*/
    select_t       aw_sel_cur,          aw_sel_nxt;
    select_t                ar_atomic_sel_cur,      ar_atomic_sel_nxt;     // for atomic transaciton
    logic [AxiLookBits-1:0] ar_atomic_push_id_cur,  ar_atomic_push_id_nxt; //  for atomic transaciton
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            aw_cur_sta              <= AW_IDLE;
            aw_sel_cur              <= '0;
            ar_atomic_sel_cur       <= '0;
            ar_atomic_push_id_cur   <= '0;
        end else begin
            aw_cur_sta              <= aw_nxt_sta;
            aw_sel_cur              <= aw_sel_nxt;
            ar_atomic_sel_cur       <= ar_atomic_sel_nxt;
            ar_atomic_push_id_cur   <= ar_atomic_push_id_nxt;
        end
    end
    logic       aw_push_en;
    select_t    loopup_aw_sel;
    logic       lookup_aw_sel_taken; 
    logic       lookup_aw_sel_from_ar_taken;
    always_comb begin
        aw_nxt_sta = aw_cur_sta;
        aw_sel_nxt = aw_sel_cur;
        aw_push_en = 1'b0;
        ar_atomic_sel_nxt        = ar_atomic_sel_cur;       //  for atomic transaciton
        ar_atomic_push_id_nxt    = ar_atomic_push_id_cur;   //  for atomic transaciton
        unique case(1'b1)
            aw_cur_sta[AW_I_BIT]: begin //AW_IDLE
                if(slv_req_i.aw_valid && (!tr_in_flight_full)) begin
                    if((slv_req_i.aw.atop == 6'b00_0000) || slv_req_i.aw.atop[5:4] == 2'b01) begin //non-atomic, atomic store transaction
                        if( (!lookup_aw_sel_taken) || (loopup_aw_sel == slv_aw_select_i)) begin
                            aw_nxt_sta = AW_APPROVE;
                            aw_sel_nxt = slv_aw_select_i;
                        end
                    end else begin
                        if(tr_in_flight_cnt < (MaxTrans-1)) begin //must have two available room for atomic load, swap and compare transaction
                            if((!(lookup_aw_sel_taken | lookup_aw_sel_from_ar_taken)) && ar_cur_sta == AR_IDLE) begin
                                aw_nxt_sta              = AW_ATOP_APPROVE;
                                aw_sel_nxt              = slv_aw_select_i;
                                ar_atomic_sel_nxt       = slv_aw_select_i;                   //  for atomic transaciton
                                ar_atomic_push_id_nxt   = slv_req_i.aw.id[0 +: AxiLookBits]; //  for atomic transaciton
                            end
                        end
                    end
                end
            end
            aw_cur_sta[AW_A_BIT]: begin // AW_APPROVE
                if(mst_resps_i[aw_sel_cur].aw_ready) begin
                    aw_nxt_sta      = AW_IDLE;
                    aw_push_en      = 1'b1;
                end
            end
            aw_cur_sta[AW_AA_BIT]: begin // AW_ATOP_APPROVE
                if(mst_resps_i[aw_sel_cur].aw_ready) begin
                    aw_nxt_sta      = AW_IDLE;
                    aw_push_en      = 1'b1;
                end
            end
            default: begin end
        endcase
    end
    
    axi_id_in_flight_array #(
        .AxiLookBits    (AxiLookBits),  
        .MaxTrans       (MaxTrans   ),
        .select_t       (select_t   )
    ) i_aw_id_in_flight_array(
    .clk_i,
    .rst_ni,
    .test_i,
    //look up (for atomic transaction)
    .lookup_axi_id_i                (slv_req_i.aw.id[0 +: AxiLookBits]      ),
    .lookup_for_atomic_id_i         ({AxiLookBits{1'b0}}                    ),  //not used: tie to 0
    .lookup_sel_taken_o             (lookup_aw_sel_taken                    ),
    .lookup_sel_o                   (loopup_aw_sel                          ),
    .loopup_for_atomic_id_taken_o   (       /*not used*/                    ),
    //push
    .push_sel_i                     (aw_sel_cur                             ),
    .push_axi_id_i                  (slv_req_i.aw.id[0 +: AxiLookBits]      ),
    .push_en_i                      (aw_push_en                             ),
    .in_fligh_cnt_o                 (aw_in_flight_cnt                       ),
    //pop
    .pop_en_i                       (slv_resp_o.b_valid & slv_req_i.b_ready ),
    .pop_axi_id_i                   (slv_resp_o.b.id[0 +: AxiLookBits]      )
    );
//}}}
//{{{ aw inner debug signals
`ifdef DEBUG_DESIGN_SIGNAL 
    logic                   debug_aw_slv_req_i_aw_valid;
    logic[NoMstPorts-1:0]   debug_aw_mst_resp_aw_readies; 
    logic                   debug_aw_SM_A2I_condition;
    assign debug_aw_slv_req_i_aw_valid  = slv_req_i.aw_valid;
    for(genvar i=0; i<NoMstPorts;i++)begin: debug_mst_resp_aw_ready
        assign debug_aw_mst_resp_aw_readies[i] = mst_resps_i[i].aw_ready;    
    end
    assign debug_aw_SM_A2I_condition = mst_resps_i[aw_sel_cur].aw_ready;
`endif
//}}}
//{{{ W channel 
    /*  There is a FIFO for W to store the target destination it will go.
        Realign the adrress and write data: we enforce W follows the AW, don't permit AW and W at the same cycle. 
        When aw_confirmed, push aw_select_i into FIFO 
        when fifo is not empty, use sel pop from fifo. and We always use the sel from fifo. 
            pre-condition: !fifo_empty 
            if req_i.w_valid  --> w_valid_approved = 1'b1            
            
        */
    typedef enum logic[1:0] {
        W_IDLE      = 2'b01,
        W_APPROVE   = 2'b10 // w
    } w_state_e;
    enum {
        I_BIT       = 0,
        A_BIT       = 1
    } state_bit_e;

    w_state_e   w_cur_sta,  w_nxt_sta;
    logic       w_pop_en;
    select_t    w_select_from_fifo;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            w_cur_sta <= W_IDLE;
        end else begin
            w_cur_sta <= w_nxt_sta;
        end
    end
    logic       w_sel_empty;
    always_comb begin
        w_nxt_sta   = w_cur_sta;
        w_pop_en    = 1'b0;
        unique case(1'b1)
            w_cur_sta[I_BIT]: begin 
                if((!w_sel_empty) && slv_req_i.w_valid) begin
                    w_nxt_sta = W_APPROVE;
                    w_pop_en  = 1'b1;
                end
            end 
            w_cur_sta[A_BIT]: begin
                if(slv_req_i.w_valid && slv_req_i.w.last && mst_resps_i[w_select_from_fifo].w_ready) begin
                    w_nxt_sta   = W_IDLE;
                end
            end
            default: begin end
        endcase
    end
    logic   w_push_en; 
    assign  w_push_en = (aw_cur_sta == AW_ATOP_APPROVE) ? 1'b0 : aw_push_en; 
    fifo_v3 #(
        .FALL_THROUGH       (0       ),
        .DEPTH              (MaxTrans),
        .dtype              (select_t)
    ) i_w_sel_fifo (
        .clk_i,
        .rst_ni,
        .flush_i        (1'b0               ),
        .testmode_i     (test_i             ),
        .push_i         (w_push_en          ),
        .data_i         (aw_sel_cur         ),
        .pop_i          (w_pop_en           ),
        .data_o         (w_select_from_fifo ),
        .full_o         (/*not used*/       ),
        .empty_o        (w_sel_empty        ),
        .usage_o        (/*not used*/       )
    );
//}}}
//{{{ w inner debug signals
`ifdef DEBUG_DESIGN_SIGNAL 
    logic debug_w_slv_req_i_w_valid, debug_w_slv_req_i_w_last;
    logic debug_w_w_select_ready;
    logic debug_w_SM_A2I_condition;
    logic[NoMstPorts-1:0] debug_w_mst_resp_w_readies; 

    assign debug_w_slv_req_i_w_valid  = slv_req_i.w_valid;
    assign debug_w_slv_req_i_w_last  = slv_req_i.w.last;
    for(genvar i=0; i<NoMstPorts;i++)begin: debug_mst_resp_w_ready
        assign debug_w_mst_resp_w_readies[i] = mst_resps_i[i].w_ready;    
    end
    assign debug_w_w_select_ready = mst_resps_i[w_select_from_fifo].w_ready;
    assign debug_w_SM_A2I_condition = slv_req_i.w_valid && slv_req_i.w.last && mst_resps_i[w_select_from_fifo].w_ready;
`endif
//}}}
    localparam int unsigned IDX_WIDTH = axi_math_pkg::idx_width(NoMstPorts);
//{{{ B channel arbiter
    b_chan_t                            b_gnt;
    b_chan_t [NoMstPorts-1:0]           b_chans;
    logic                               b_valid_gnt;
    logic[IDX_WIDTH-1:0]                b_idx_gnt;
    logic[NoMstPorts-1:0]               b_valids;
    logic[NoMstPorts-1:0]               b_readies;

    for(genvar i=0;i<NoMstPorts;i++)begin
        assign b_valids[i]              = mst_resps_i[i].b_valid;   
        assign b_chans[i]               = mst_resps_i[i].b;
    end
    fair_round_robin_arbiter #(
        .NumIn      (NoMstPorts      ),
        .DataType   (b_chan_t        )
    ) i_b_fair_rr_arb (
        .clk_i,
        .rst_ni,
        .flush_i    (1'b0               ),
        .req_i      (b_valids           ),
        .data_i     (b_chans            ),
        .gnt_i      (slv_req_i.b_ready  ),
        .gnt_o      (b_readies          ),
        .req_o      (b_valid_gnt        ),
        .data_o     (b_gnt              ),
        .idx_o      (b_idx_gnt          )  
    );
//}}}
//{{{ AR channel     
    select_t                    ar_sel_cur,     ar_sel_nxt;
    logic [AxiLookBits-1:0]     ar_push_id_cur, ar_push_id_nxt;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            ar_cur_sta      <= AR_IDLE;
            ar_sel_cur      <= '0;
            ar_push_id_cur  <= '0;
        end else begin
            ar_cur_sta      <= ar_nxt_sta;
            ar_sel_cur      <= ar_sel_nxt;
            ar_push_id_cur  <= ar_push_id_nxt;
        end
    end
    logic       ar_push_en;
    select_t    loopup_ar_sel;
    logic       lookup_ar_sel_taken;
    always_comb begin
        ar_nxt_sta      = ar_cur_sta;
        ar_sel_nxt      = ar_sel_cur;
        ar_push_en      = 1'b0;
        ar_push_id_nxt  = ar_push_id_cur;
        unique case(1'b1)
            ar_cur_sta[AR_I_BIT]: begin // AR_IDLE
                if(slv_req_i.ar_valid && (!tr_in_flight_full) && aw_cur_sta != AW_ATOP_APPROVE) begin
                    if((!lookup_ar_sel_taken) || (loopup_ar_sel == slv_ar_select_i))begin
                        ar_nxt_sta      = AR_APPROVE;
                        ar_sel_nxt      = slv_ar_select_i;
                        ar_push_id_nxt  = slv_req_i.ar.id[0 +: AxiLookBits];
                    end
                end
                else if(aw_cur_sta == AW_ATOP_APPROVE) begin 
                    ar_nxt_sta          = AR_ATOP_APPROVE;
                    ar_sel_nxt          = ar_atomic_sel_cur;
                    ar_push_id_nxt      = ar_atomic_push_id_cur;
                end
            end
            ar_cur_sta[AR_A_BIT]: begin // AR_APPROVE
                if(mst_resps_i[ar_sel_cur].ar_ready) begin 
                    ar_nxt_sta      = AR_IDLE;
                    ar_push_en      = 1'b1;
                end
            end
            ar_cur_sta[AR_AA_BIT]: begin // AW_ATOP_APPROVE
                if(aw_cur_sta == AW_IDLE) begin
                    ar_nxt_sta      = AR_IDLE;
                    ar_push_en      = 1'b1;
                end
            end
            default: begin end
        endcase
    end

    axi_id_in_flight_array #(
        .AxiLookBits    (AxiLookBits),  
        .MaxTrans       (MaxTrans   ),
        .select_t       (select_t   )
    ) i_ar_id_in_flight_array(
    .clk_i,
    .rst_ni,
    .test_i,
    //look up (for atomic transaction)
    .lookup_axi_id_i                (slv_req_i.ar.id[0 +: AxiLookBits]),
    .lookup_for_atomic_id_i         (slv_req_i.aw.id[0 +: AxiLookBits]), //for atomic transaction aw SM
    .lookup_sel_taken_o             (lookup_ar_sel_taken              ),
    .lookup_sel_o                   (loopup_ar_sel                    ),
    .loopup_for_atomic_id_taken_o   (lookup_aw_sel_from_ar_taken ),  //for atomic transaction aw SM
    //push
    .push_en_i                      (ar_push_en                       ),
    .push_sel_i                     (ar_sel_cur                       ),
    .push_axi_id_i                  (ar_push_id_cur                   ),
    .in_fligh_cnt_o                 (ar_in_flight_cnt                 ),
    //pop   
    .pop_en_i                       (slv_resp_o.r_valid && slv_resp_o.r.last && slv_req_i.r_ready),
    .pop_axi_id_i                   (slv_resp_o.r.id[0 +: AxiLookBits]  )
    );
//}}}
//{{{ R channel arbiter
    r_chan_t                            r_gnt;
    r_chan_t [NoMstPorts-1:0]           r_chans;
    logic                               r_valid_gnt;
    logic[IDX_WIDTH-1:0]                r_idx_gnt;
    logic[NoMstPorts-1:0]               r_valids;
    logic[NoMstPorts-1:0]               r_readies;
    for(genvar i=0;i<NoMstPorts;i++)begin
        assign r_valids[i]              = mst_resps_i[i].r_valid;   
        assign r_chans[i]               = mst_resps_i[i].r;
    end
    fair_round_robin_arbiter #(
        .NumIn     (NoMstPorts      ),
        .DataType  (r_chan_t        )
    ) i_r_fair_rr_arb (
        .clk_i,
        .rst_ni,
        .flush_i    (1'b0               ),
        .req_i      (r_valids           ),
        .data_i     (r_chans            ),
        .gnt_i      (slv_req_i.r_ready  ),
        .gnt_o      (r_readies          ),
        .req_o      (r_valid_gnt        ),
        .data_o     (r_gnt              ),
        .idx_o      (r_idx_gnt          )  
    );
//}}}
// output 
    always_comb begin
        mst_reqs_o = '0;
        slv_resp_o = '0;
        for(int unsigned i=0; i<NoMstPorts; i++) begin
            //aw 
            if(!(aw_cur_sta == AW_IDLE)) begin
                if(i == aw_sel_cur) begin
                    mst_reqs_o[i].aw_valid  = slv_req_i.aw_valid;
                    mst_reqs_o[i].aw        = slv_req_i.aw;
                    slv_resp_o.aw_ready     = mst_resps_i[i].aw_ready;
                end
            end
            //w
            if(w_cur_sta == W_APPROVE) begin
                if(i == w_select_from_fifo) begin
                    mst_reqs_o[i].w_valid   = slv_req_i.w_valid;
                    mst_reqs_o[i].w         = slv_req_i.w;
                    slv_resp_o.w_ready      = mst_resps_i[i].w_ready;
                end
            end
            //b
            mst_reqs_o[i].b_ready    = b_readies[i]; 
            //ar 
            if(ar_cur_sta == AR_APPROVE)begin
                if(i == ar_sel_cur) begin
                    mst_reqs_o[i].ar_valid  = slv_req_i.ar_valid;
                    mst_reqs_o[i].ar        = slv_req_i.ar;
                    slv_resp_o.ar_ready     = mst_resps_i[i].ar_ready;
                end
            end
            //r 
            mst_reqs_o[i].r_ready   = r_readies[i];
        end
        //b
        slv_resp_o.b_valid   = b_valid_gnt;
        slv_resp_o.b         = b_gnt;
        //r
        slv_resp_o.r_valid   = r_valid_gnt;
        slv_resp_o.r         = r_gnt;
    end

endmodule 

`endif 
