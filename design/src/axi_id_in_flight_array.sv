/* ***********************************************************
    document:       axi_id_in_flight_array.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_ID_IN_FLIGHT_ARRAY_SV__
`define __AXI_ID_IN_FLIGHT_ARRAY_SV__

module axi_id_in_flight_array #(
    parameter int unsigned AxiLookBits    = 32'd3,
    parameter int unsigned MaxTrans       = 32'd8,
    parameter int unsigned CntWidth       = 32'd4,
    parameter type         select_t       = logic
)(
    input  logic                          clk_i,
    input  logic                          rst_ni,
    input  logic                          test_i,
    //look up 
    input  logic [AxiLookBits-1:0]        lookup_axi_id_i,
    input  logic [AxiLookBits-1:0]        lookup_for_atomic_id_i,
    output logic                          lookup_sel_taken_o,
    output logic                          loopup_for_atomic_id_taken_o,
    output select_t                       lookup_sel_o,
    //push
    input  select_t                       push_sel_i,
    input  logic [AxiLookBits-1:0]        push_axi_id_i,
    input  logic                          push_en_i,
    //pop
    input  logic                          pop_en_i,
    input logic [AxiLookBits-1:0]         pop_axi_id_i,
    //in_flight count
    output logic [CntWidth-1:0]           in_fligh_cnt_o
);
    localparam int unsigned NoLooks     = 2**AxiLookBits; 

    select_t [NoLooks-1:0]                  sels;
    logic [NoLooks-1:0]                     sel_taken;
    logic [NoLooks-1:0] [CntWidth-1:0]      id_in_flight_cnts; 
    
    //look up 
    assign lookup_sel_o                 = sels[lookup_axi_id_i];
    assign lookup_sel_taken_o           = sel_taken[lookup_axi_id_i];
    assign loopup_for_atomic_id_taken_o = sel_taken[lookup_for_atomic_id_i];

    //push and pop
    logic [NoLooks-1:0] push_en, pop_en;
    assign push_en      = (push_en_i)   ? (1<<push_axi_id_i)    : '0;
    assign pop_en       = (pop_en_i)    ? (1<<pop_axi_id_i)     : '0;

    //in_flight count 
    always_comb begin
        in_fligh_cnt_o = '0;
        for(int unsigned i=0; i<NoLooks; i++) begin
            in_fligh_cnt_o += id_in_flight_cnts[i];
        end
    end

       
    for(genvar i=0; i<NoLooks; i++) begin : gen_id_counters
        logic   count_en, count_down, overflow;
        always_ff @(posedge (clk_i) or negedge (rst_ni)) begin 
            if(~rst_ni)         sels[i] <= '0;
            else if(push_en[i]) sels[i] <= push_sel_i; 
        end
        always_comb begin
            unique case({push_en[i], pop_en[i]})
                2'b01: begin
                    count_en    = 1'b1;
                    count_down  = 1'b1;  //pop
                end
                2'b10: begin
                    count_en    = 1'b1;
                    count_down  = 1'b0;  //push
                end
                default: begin
                    count_en    = 1'b0;
                    count_down  = 1'b0;
                end
            endcase
        end
        counter #(
            .WIDTH           (CntWidth      ),
            .STICKY_EN       ( 1'b0         )
        ) i_in_flight_cnt (
            .clk_i      ( clk_i                 ),
            .rst_ni     ( rst_ni                ),
            .clear_i    ( 1'b0                  ),
            .en_i       ( count_en              ),
            .load_i     ( 1'b0                  ),
            .down_i     ( count_down            ),
            .d_i        ( {CntWidth{1'b0}}      ),
            .q_o        ( id_in_flight_cnts[i]  ),
            .overflow_o ( /* not use */         )
        );

        assign sel_taken[i] = |(id_in_flight_cnts[i]);
    end 

endmodule

`endif 
