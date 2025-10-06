/* ***********************************************************
    document:       tb_axi_macro_param.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Define the max width for the data type 
**************************************************************/
`ifndef __TB_AXI_MACRO_PARAM_SVH__
`define __TB_AXI_MACRO_PARAM_SVH__

`ifndef TVIP_AXI_MAX_ID_WIDTH
  `define TVIP_AXI_MAX_ID_WIDTH 32
`endif

`ifndef TVIP_AXI_MAX_ADDRESS_WIDTH
  `define TVIP_AXI_MAX_ADDRESS_WIDTH  64
`endif

`ifndef TVIP_AXI_MAX_DATA_WIDTH
  `define TVIP_AXI_MAX_DATA_WIDTH 1024
`endif

`endif 
