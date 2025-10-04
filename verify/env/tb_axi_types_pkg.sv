/* ***********************************************************
    document:       tb_axi_types_pkg.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Encapsulting the data types for TB. 
                    All data types are defined in the AXI4 spec.
**************************************************************/
`ifndef __TB_AXI_TYPES_PKG_SVH__ 
`define __TB_AXI_TYPES_PKG_SVH__
package tb_axi_types_pkg;

    typedef enum logic [2:0] {
      TVIP_AXI_BURST_SIZE_1_BYTE    = 'b000,
      TVIP_AXI_BURST_SIZE_2_BYTES   = 'b001,
      TVIP_AXI_BURST_SIZE_4_BYTES   = 'b010,
      TVIP_AXI_BURST_SIZE_8_BYTES   = 'b011,
      TVIP_AXI_BURST_SIZE_16_BYTES  = 'b100,
      TVIP_AXI_BURST_SIZE_32_BYTES  = 'b101,
      TVIP_AXI_BURST_SIZE_64_BYTES  = 'b110,
      TVIP_AXI_BURST_SIZE_128_BYTES = 'b111
    } tvip_axi_burst_size;




endpackage 
`endif 
