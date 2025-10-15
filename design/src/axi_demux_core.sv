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
  // Master Ports
  output axi_req_t    [NoMstPorts-1:0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts-1:0]  mst_resps_i
);


    logic aw_sel_valid; 
    assign aw_sel_valid = (slv_aw_select_i < NoMstPorts);


 

/*  When the interconnect is required to determine the destination address space or 
    Subordinate space, it must realign the address and write data.  
*/
//{{{ AW channe
    logic       aw_valid, aw_ready;
    // AW lock for its W to be arrived and then forwarded. 
    logic       aw_array_full;
    logic       lookup_sel_occupied;
    select_t    loopup_aw_sel;
    axi_id_array #(
        .AxiLookBits    (AxiLookBits),  
        .MaxTrans       (MaxTrans),
        .select_t       (select_t)
    ) i_aw_id_array(
    .clk_i,
    .rst_ni,
    .test_i,
    
    .lookup_axi_id_i(slv_req_i.aw.id[0+:AxiLookBits]),
    .lookup_sel_occupied_o(lookup_sel_occupied),
    .lookup_sel_o(loopup_aw_sel),
    
    .push_sel_i(w_cnt_up),
    .push_axi_id_i(slv_aw_select_i),
    .push_en_i(slv_req_i.aw.id[0+:AxiLookBits]),
    .full_o(aw_array_full),
    
    .pop_en_i(slv_resp_o.b_valid & slv_req_i.b_ready),
    .pop_axi_id_i(slv_resp_o.b.id[0+:AxiLookBits])
    )
    
    
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
//}}}
/*
    AW decides which downstream master port the according W goes to. 
*/
//{{{ W channel 
    select_t    w_sel;
    logic       w_sel_vld;
//}}}

//{{{ B channel

//}}}


endmodule 

`endif 
