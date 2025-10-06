/* ***********************************************************
    document:       tb_axi_macro_define_pkg.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Macro to simplify the code
**************************************************************/
`ifndef __TB_AXI_MACRO_DEFINE_PKG_SVH__
`define __TB_AXI_MACRO_DEFINE_PKG_SVH__

package tb_axi_macro_define_pkg;

    `define ob_construct(TYPE) \
    function new(string name = `"TYPE`"); \
        super.new(name); \
    endfunction

    `define comp_construct(TYPE, PARENT) \
    function new(string name = `"TYPE`", uvm_component parent = `"PARENT`"); \
        super.new(name, parent); \
    endfunction

endpackage

import tb_axi_macro_define_pkg::*

`endif 
