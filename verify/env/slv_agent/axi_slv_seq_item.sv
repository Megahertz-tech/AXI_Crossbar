/* ***********************************************************
    document:       axi_slv_seq_item.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef ____
`define 
class axi_slv_seq_item extends axi_seq_item_base;
    bit is_aw, is_w, is_b, is_rw, is_r;
    `uvm_object_utils_begin(axi_slv_seq_item)
        `uvm_field_int(is_aw, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_w, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_b, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_rw, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_r, UVM_DEFAULT | UVM_BIN)
    `uvm_object_utils_end
    function new (string name = "axi_slv_seq_item");
        super.new(name);
    endfunction


endclass






`endif 
