/* ***********************************************************
    document:       axi_atomic_filter.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_ATOMIC_FILTER_SV__
`define __AXI_ATOMIC_FILTER_SV__
module axi_atomic_filter #(
  parameter type         axi_req_t       = logic    // AXI request type
) (
  input  logic      clk_i,              // Clock
  input  logic      rst_ni,             // Asynchronous reset, active low
  input  axi_req_t  slv_req_i,          // Slave request input
  output axi_req_t  filtered_req_o      // Filtered request output
);

    always_comb begin
        filtered_req_o = slv_req_i;
        if(slv_req_i.aw_valid && (!(slv_req_i.aw.atop[5:4] == 2'b00))) begin
            if(!(slv_req_i.aw.atop[5:4] == 2'b01)) begin
                filtered_req_o.ar.id = slv_req_i.ar.id;
                if(slv_req_i.aw.atop[5:4] == 2'b11) begin
                    filtered_req_o.ar.len = slv_req_i.ar.len >> 1;
                end else begin
                    filtered_req_o.ar.len = slv_req_i.ar.len;
                end
            end
        end
    end


endmodule


`endif 
