/* ***********************************************************
    document:       fair_round_robin_arbiter.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __FAIR_ROUND_ROBIN_ARBITER_SV__
`define __FAIR_ROUND_ROBIN_ARBITER_SV__

module fair_round_robin_arbiter #(
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
        IDLE        = 2'b01,
        ACCESS      = 2'b10
    } state_e;
    enum {
        I_BIT       = 0,
        A_BIT       = 1
    } state_bit;


    logic access_start;
    state_e                 cur_sta,        nxt_sta;
    logic [PTR_WIDTH-1:0]   cur_frr_ptr,    nxt_frr_ptr;
    logic [PTR_WIDTH-1:0]   cur_gnt_index,  nxt_gnt_index;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            cur_sta         <= IDLE;
            cur_frr_ptr     <= '0;
            cur_gnt_index   <= '0;
        end else begin
            cur_sta         <= nxt_sta;
            cur_frr_ptr     <= nxt_frr_ptr;
            cur_gnt_index   <= nxt_gnt_index;
        end
    end    
    always_comb begin
        nxt_sta         = cur_sta;
        nxt_frr_ptr     = cur_frr_ptr;
        nxt_gnt_index   = cur_gnt_index;
        unique case (1'b1) 
            cur_sta[I_BIT]: begin
                //if((req_i != 0) && (!access_start)) begin
                if(req_i != 0) begin
                    nxt_sta         = ACCESS;
                    nxt_gnt_index   = pick_grant_pos(req_i, cur_frr_ptr); 
                    nxt_frr_ptr     = (pick_grant_pos(req_i, cur_frr_ptr) + 1) % NumIn;
                end
            end
            cur_sta[A_BIT]: begin
                if(gnt_i) begin
                    nxt_sta = IDLE;
                end
            end
            default: begin end
        endcase 
    end
    always_comb begin
        access_start    = 1'b0;
        if(cur_sta==ACCESS) begin
            access_start = req_i[cur_gnt_index];
        end
    end
    logic [NumIn-1:0] req_i_delay;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            req_i_delay <= '0;
        end else begin
            req_i_delay <= req_i;
        end
    end    
    assign data_o  = data_i[cur_gnt_index];
    assign idx_o   = cur_gnt_index;
    always_comb begin
        req_o = 1'b0; 
        //data_o = '0;
        //idx_o = '0;
        gnt_o = '0;
        if(cur_sta==ACCESS)begin
            req_o   = req_i_delay[cur_gnt_index];
            //data_o  = data_i[cur_gnt_index];
            //idx_o   = cur_gnt_index;
            gnt_o   = gnt_i << cur_gnt_index;
        end
    end
        
    function automatic int unsigned pick_grant_pos (
        input logic[NumIn-1:0]  req,
        input int               start_pos
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
