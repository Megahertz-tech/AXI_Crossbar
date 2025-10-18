/* ***********************************************************
    document:       fair_round_robin_arbitrate.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __FAIR_ROUND_ROBIN_ARBITRATE_SV__
`define __FAIR_ROUND_ROBIN_ARBITRATE_SV__

module fair_round_robin_arbitrate #(
    parameter int unsigned NumIn      = 4,
    parameter type         DataType   = logic
)(
    input  logic                        clk_i,
    input  logic                        rst_ni,
    input  logic                        flush_i ,
    input  logic [NumIn-1:0]            req_i   ,
    input  DataType [NumIn-1:0]         data_i  ,
    input  logic                        gnt_i   ,
    output logic [NumIn-1:0]            gnt_o   ,
    output logic                        req_o   ,
    output DataType                     data_o  ,
    output logic [$clog2(NumIn)-1:0]    idx_o      
);
    localparam int unsigned PTR_WIDTH = $clog2(NumIn);
    typedef enum logic[1:0] {
        IDLE    = 2'b01,
        ACESS   = 2'b10
    } state_e;
    enum {
        I_BIT = 0,
        A_BIT = 1
    } state_bit;


    logic resource_idle; 
    logic any_req_asserted;
    state_e                 cur_sta,        nxt_sta;
    logic [PTR_WIDTH-1:0]   cur_frr_ptr,    nxt_frr_ptr;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            cur_sta <= IDLE;
            cur_frr_ptr <= '0;
        end else begin
            cur_sta <= nxt_sta;
            cur_frr_ptr <= nxt_frr_ptr;
        end
    end
    assign any_req_asserted = (|req_i);
    always_comb begin
        nxt_sta     = cur_sta;
        nxt_frr_ptr = cur_frr_ptr;
        unique case (1'b1) 
            cur_sta[I_BIT]: begin
                if(any_req_asserted) begin
                    nxt_sta = ACCESS;
                    nxt_frr_ptr = pick_next_grant_pos(req_i, cur_frr_ptr);                    
                end
            end
            cur_sta[A_BIT]: begin
                if(gnt_i) begin
                    nxt_sta = IDLE;
                end
            end
        endcase 
    end
    always_comb begin
        req_o = 1'b0; 
        data_o = '0;
        idx_o = '0;
        if(cur_sta==ACCESS)begin
            req_o = req_i[cur_frr_ptr];
            data_0 = data_i[cur_frr_ptr];
            idx_o = cur_frr_ptr;
        end
    end
        
    
    // pick next grant position in round-robin order
    function automatic int unsigned pick_next_grant_pos (
        input logic[NumIn-1:0]  req,
        input int               start_pos,
    );
        for (int unsigned i=0; i<NumIn; i++) begin
            int unsigned idx = (start_pos + i) % NumIn;
            if (req[idx]) begin
                return idx;
            end
        end
    endfunction


endmodule
`endif 
