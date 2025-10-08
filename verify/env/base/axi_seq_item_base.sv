/* ***********************************************************
    document:       axi_seq_item_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    base sequence_item 
**************************************************************/
`ifndef __AXI_SEQ_ITEM_BASE_SV__
`define __AXI_SEQ_ITEM_BASE_SV__
class axi_seq_item_base extends uvm_sequence_item;
    rand axi_access_type    access_type;
    rand axi_id             id;
    rand axi_address        address;
    rand axi_data           data[];
    rand axi_strobe         strobe[];
    rand shortint           burst_length;
    rand axi_burst_size     burst_size;
    rand axi_burst_type     burst_type;
    rand axi_memory_type    memory_type;
    rand axi_protection     protection;
    rand axi_qos            qos;
    rand axi_response       response[];
    rand bit                need_response;
    
    global_cfg gcfg = global_cfg::get();
        
    `uvm_object_utils_begin(axi_seq_item_base)
        `uvm_field_enum(axi_access_type, access_type, UVM_DEFAULT)
        `uvm_field_int(id, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(strobe, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_size, burst_size, UVM_DEFAULT)
        `uvm_field_enum(axi_burst_type, burst_type, UVM_DEFAULT)
        `uvm_field_enum(axi_memory_type, memory_type, UVM_DEFAULT)
        `uvm_field_int(protection, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(axi_qos, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_enum(axi_response, response, UVM_DEFAULT)
        //`uvm_field_enum(, , UVM_DEFAULT)
        `uvm_field_int(axi_qos, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(axi_response, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
    `uvm_object_utils_end
    `ob_construct(axi_seq_item_base)

    //constraint c_valid_id{
    //     (id >> gcfg.)       
    //}

endclass






`endif 
