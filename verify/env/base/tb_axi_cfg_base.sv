/* ***********************************************************
    document:       tb_axi_cfg_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __TB_AXI_CFG_BASE_SV__
`define __TB_AXI_CFG_BASE_SV__
`include "tb_axi_macro_define_pkg.svh"
class tb_axi_cfg_base extends uvm_object;
    rand int                axi_data_width;
    rand int                axi_addr_width;
    rand shortint           burst_length;   // the number of read/write transfers
    rand axi_burst_size     burst_size;     // the maximum number of bytes to transfer in each data transfer, or beat, in a burst.
    rand axi_burst_type     burst_type;

    global_cfg gcfg = global_cfg::get();

    `uvm_object_utils_begin(tb_axi_cfg_base)
        `uvm_field_int(axi_addr_width, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(axi_data_width, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_size, burst_size, UVM_DEFAULT)
        `uvm_field_enum(axi_burst_type, burst_type, UVM_DEFAULT)
    `uvm_object_utils_end


    
endclass 

`endif 
