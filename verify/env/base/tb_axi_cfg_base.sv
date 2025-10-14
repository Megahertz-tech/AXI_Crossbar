/* ***********************************************************
    document:       tb_axi_cfg_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __TB_AXI_CFG_BASE_SV__
`define __TB_AXI_CFG_BASE_SV__
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "tb_axi_types_pkg.sv"
`include "tb_xbar_param_pkg.svh"
class tb_axi_cfg_base extends uvm_object;
    parameter int ADDR_OFFSET   = tb_xbar_param_pkg::BASE_ADDR_OFFSET                 ; 
    parameter int ADDR_SLICES   = tb_xbar_param_pkg::TB_ADDR_RULES_NUMBER_IN_USE      ;

    rand bit                        addr_overflow_en;
    rand shortint                   burst_length;   // the number of read/write transfers
    rand axi_burst_size             burst_size;     // the maximum number of bytes to transfer in each data transfer, or beat, in a burst.
    rand axi_burst_type             burst_type;
    

    `uvm_object_utils_begin(tb_axi_cfg_base)
        //`uvm_field_int(ADDR_OFFSET, UVM_DEFAULT | UVM_HEX)
        //`uvm_field_int(ADDR_SLICES, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(addr_overflow_en, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_size, burst_size, UVM_DEFAULT)
        `uvm_field_enum(axi_burst_type, burst_type, UVM_DEFAULT)
    `uvm_object_utils_end
    function new (string name = "tb_axi_cfg_base");
        super.new(name);
    endfunction

    
endclass 

`endif 
