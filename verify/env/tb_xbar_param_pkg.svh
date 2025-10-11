/* ***********************************************************
    document:       tb_xbar_param_pkg.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Parameters used by all components and objects  
**************************************************************/
`ifndef __TB_XBAR_PARAM_PKG_SVH__
`define __TB_XBAR_PARAM_PKG_SVH__

package tb_xbar_param_pkg;

    parameter int unsigned  TB_MASTER_NUMBER_IN_USE = 3;
    parameter int unsigned  TB_SLAVE_NUMBER_IN_USE  = 4;
    parameter int unsigned  TB_ADDR_RULES_NUMBER_IN_USE = TB_SLAVE_NUMBER_IN_USE;

    parameter int unsigned  AXI_SLAVE_ID_WIDTH_IN_USE = 6;
    parameter int unsigned  AXI_ADDR_WIDTH_IN_USE = 32 ; 
    parameter int unsigned  AXI_DATA_WIDTH_IN_USE = 64 ; 
    parameter int unsigned  AXI_MASTER_ID_WIDTH_IN_USE   = AXI_SLAVE_ID_WIDTH_IN_USE + axi_math_pkg::idx_width(TB_MASTER_NUMBER_IN_USE); 
    parameter int unsigned  AXI_USER_WIDTH_IN_USE = 8  ; 
    parameter int unsigned  AXI_MASTER_NUMBER_IN_USE = 3; 
    parameter int unsigned  AXI_SLAVE_NUMBER_IN_USE = 4; 

    parameter time  CLK_PERIOD = 4ns; 
    //parameter time  ; 
    //parameter time  ; 
    //parameter int unsigned  ; 

endpackage 

import tb_xbar_param_pkg::*;

`endif 
