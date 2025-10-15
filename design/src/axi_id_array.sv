/* ***********************************************************
    document:       axi_id_array.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_ID_ARRAY_SV__
`define __AXI_ID_ARRAY_SV__

module axi_id_array #(
    parameter int unsigned AxiLookBits    = 32'd3,
    parameter int unsigned MaxTrans       = 32'd8,
    parameter type         select_t       = logic
)(
    input  logic                          clk_i,
    input  logic                          rst_ni,
    input  logic                          test_i,
    //look up 
    input  logic [AxiLookBits-1:0]        lookup_axi_id_i,
    output logic                          lookup_sel_occupied_o,
    output select_t                       lookup_sel_o,
    //push
    input  select_t                       push_sel_i,
    input  logic [AxiLookBits-1:0]        push_axi_id_i,
    input  logic                          push_en_i,
    output logic                          full_o,
    //pop
    input  logic                          pop_en_i,
    input logic [AxiLookBits-1:0]         pop_axi_id_i
);
    localparam int unsigned NoLooks = 2**AxiLookBits; 
    localparam int unsigned Trans_Width = axi_math_pkg::idx_width(MaxTrans);
    typedef logic [Trans_Width-1:0] cnt_t;

    select_t [NoLooks-1:0]                  sels;
    //cnt_t [NoLooks-1:0]                     cnts; 
    logic [NoLooks-1:0]                     sel_occupied;
    
    //look up 
    assign lookup_sel_o = sels[lookup_axi_id_i];
    assign lookup_sel_occupied_o = sel_occupied[lookup_axi_id_i];

    //push and pop
    logic [NoLooks-1:0] push_en, pop_en;
    assign push_en      = (push_en_i)   ? (1<<push_axi_id_i)    : '0;
    assign pop_en       = (pop_en_i)    ? (1<<pop_axi_id_i)     : '0;

       
    for(genvar i=0; i<NoLooks; i++) begin : gen_id_counters
        logic   count_en, count_down, overflow;
        cnt_t   count_in_flight;
        always_ff @(posedge (clk_i) or negedge (rst_ni)) begin 
            if(~rst_ni)         sels[i] <= '0;
            else if(push_en[i]) sels[i] <= push_axi_id_i; 
        end
        always_comb begin
            unique case({push_en[i], pop_en[i]})
                2'b01: begin
                    count_en    = 1'b1;
                    count_down  = 1'b1;
                end
                2'b10: begin
                    count_en    = 1'b1;
                    count_down  = 1'b0;
                end
                default: begin
                    count_en    = 1'b0;
                    count_down  = 1'b0;
                end
            endcase
        end
        counter #(
            .WIDTH           ( Trans_Width ),
            .STICKY_OVERFLOW ( 1'b0         )
        ) i_in_flight_cnt (
            .clk_i      ( clk_i     ),
            .rst_ni     ( rst_ni    ),
            .clear_i    ( 1'b0      ),
            .en_i       ( count_en    ),
            .load_i     ( 1'b0      ),
            .down_i     ( count_down  ),
            .d_i        ( '0        ),
            .q_o        ( count_in_flight ),
            .overflow_o ( overflow  )
        );
        assign sel_occupied[i] = |count_in_flight;
        assign full_o = (count_in_flight == MaxTrans) | overflow; 
    end 

endmodule

`endif 
