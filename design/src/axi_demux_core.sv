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
  output axi_req_t    [NoMstPorts : 0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts : 0]  mst_resps_i
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
 

//{{{ AW channel
/*  1.  When the interconnect is required to determine the destination address space or 
        Subordinate space, it must realign the address and write data. 
                > There is a FIFO for W to store the target destination it will go.
    2.  An interconnect that combines write transactions from different Managers must 
        ensure that it forwards the write data in address order.
                > whether approve req.aw_valid
    3.  Atomic transactions must not use AXI ID values that are used by Non-atomic transactions 
        that are outstanding at the same time. This rule applies to transactions on either 
        the AR or AW channel. This rule ensures that there are no ordering constraints between 
        Atomic transactions and Non-atomic transactions.                                            
                > whether approve req.aw_valid                                                   */
    logic aw_valid_approved;      
            // 0. pre-condition: req_i.aw_valid = 1'b1
            // 1. in_flight transaction (aw+ar) is not up to MaxTrans
            //      for non-atomic transaction (aw_atop==0), if (!lookup_aw_sel_taken) || (look_up_aw_sel == aw_sel_i) 
            //      for atomic transaction     (!aw_atop==0), loop up (aw, ar) is not taken. 
            // 2. check if W sel FIFO is full 
            //      if avaliable : aw_id in-flight counter ++, push aw_sel into W FIFO
            //      if not       : stall ( aw_valid_approved = 0)
    select_t   loopup_aw_sel;
    logic      lookup_aw_sel_taken; 
    logic      lookup_aw_sel_from_ar_taken;
    //Celine TODO (for now tie to 0) 
    assign lookup_aw_sel_from_ar_taken = 1'b0;
    always_comb begin
        aw_valid_approved = 1'b0;
        if(slv_req_i.aw_valid) begin
            if(!tr_in_flight_full) begin
                if(slv_req_i.aw.aw_atop == 5'b0_0000) begin
                    if( (!lookup_aw_sel_taken) || (loopup_aw_sel == slv_aw_select_i)) begin
                        aw_valid_approved = 1'b1;
                    end
                end else begin
                    if(!(lookup_aw_sel_taken | lookup_aw_sel_from_ar_taken)) begin
                        aw_valid_approved = 1'b1;
                    end
                end
            end
        end
    end
    always_comb begin
        mst_reqs_o = '0;
        for(int unsigned i=0; i<NoMstPorts; i++) begin
            //aw 
            if(aw_valid_approved) begin
                if(i == slv_aw_select_i) begin
                    mst_reqs_o[i].aw_valid = 1'b1;
                    mst_reqs_o[i].aw = slv_req_i.aw;
                end
            end
            //w
        end
    end
    logic aw_confirmed;  
    assign aw_confirmed = aw_valid_approved & mst_resps_i[slv_aw_select_i].aw_ready; 


    axi_id_in_flight_array #(
        .AxiLookBits    (AxiLookBits),  
        .MaxTrans       (MaxTrans),
        .select_t       (select_t)
    ) i_aw_id_in_flight_array(
    .clk_i,
    .rst_ni,
    .test_i,
    //look up (for atomic transaction)
    .lookup_axi_id_i        (slv_req_i.aw.id[0+:AxiLookBits]),
    .lookup_for_atomic_id_i (0),
    .lookup_sel_occupied_o  (lookup_aw_sel_taken),
    .lookup_sel_o           (loopup_aw_sel),
    .loopup_for_atomic_id_taken_o(/*not used*/),
    //push
    .push_sel_i             (slv_req_i.aw.id[0+:AxiLookBits]),
    .push_axi_id_i          (slv_aw_select_i),
    .push_en_i              (aw_confirmed),
    .in_fligh_cnt_o         (aw_in_flight_cnt),
    //pop
    .pop_en_i               (slv_resp_o.b_valid & slv_req_i.b_ready),
    .pop_axi_id_i           (slv_resp_o.b.id[0+:AxiLookBits])
    )
//}}}
//{{{ W channel 
    /*  There is a FIFO for W to store the target destination it will go.
        When aw_confirmed, push aw_select_i into FIFO 
        When fifo is empty, there is a scenario that aw_valid_approved and w_valid is asserted at the same time. 
            pre-condition: fifo_empty
        */
    
    logic       w_valid_approved;
    logic       w_sel_empty;
    logic       w_sel_pup_pulse;
    select_t    w_select, w_select_from_fifo;
    always_comb begin
        w_valid_approved = 1'b0;
        if(slv_req_i.w_valid) begin
            w_valid_approved = 1'b1;
        end
    end
    fifo_v3 #(
        .FALL_THROUGH(0),
        .DEPTH(MaxTrans),
        .dtype(select_t)
    ) i_w_sel_fifo (
        .clk_i,
        .rst_ni,
        .flush_i(1'b0),
        .testmode_i(test_i),
        .push_i(aw_confirmed),
        .data_i(slv_aw_select_i),
        .pop_i(),
        .data_o(w_select_from_fifo),
        .full_o(/*not used*/),
        .empty_o(w_sel_empty),
        .usage_o(/*not used*/)
    );
//}}}
    
    
    
    /**************************
        AW state macheine
    **************************/
    /*
    // FSM {AW_IDLE, AW_AVALIABLE, AW_LOCK, AW_FULL}
    typedef enum logic [4-1:0] {
        AW_IDLE         = 4'b0001,
        AW_AVALIABLE    = 4'b0010,
        AW_LOCK         = 4'b0100,
        AW_FULL         = 4'b1000
    } aw_fsm_sta_e;
    aw_fsm_sta_e cur_aw_sta, nxt_aw_sta;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            cur_aw_sta <= AW_IDLE;
        end else begin
            cur_aw_sta <= nxt_aw_sta;
        end
    end
    // confirm the next state 
    always_comb begin
        nxt_aw_sta = cur_aw_sta;
        unique case (1'b1)
            cur_aw_sta[0]: begin // AW_IDLE
                if(slv_req_i.aw_valid) nxt_aw_sta = AW_LOCK;
            end
            cur_aw_sta[1]: begin // AW_AVALIABLE
                if(slv_req_i.aw_valid) nxt_aw_sta = AW_LOCK;
            end
            cur_aw_sta[2]: begin // AW_LOCK (forward it to the selected master port and log one-copy in the aw_id_counter)
                if(w_done && (~aw_full)) begin
                    nxt_aw_sta <= AW_AVALIABLE;
                end else if (aw_full) begin
                    nxt_aw_sta <= AW_FULL;
                end
            end
            cur_aw_sta[3]: begin //AW_FULL
                if(~aw_full) begin
                    nxt_aw_sta <= AW_AVALIABLE;
                end
            end
        endcase
    end

    // AW valid/ready handshake
    always_comb begin
        slv_resp_o.aw_ready = 1'b0;
        if(aw_ready_from_mst_port) begin
            slv_resp_o.aw_ready = 1'b1;
        end
    end
*/
/*
    AW decides which downstream master port the according W goes to. 
*/

//{{{ B channel

//}}}


endmodule 

`endif 
