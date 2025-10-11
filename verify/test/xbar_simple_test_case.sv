/* ***********************************************************
    document:       xbar_simple_test_case.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_SIMPLE_TEST_CASE_SV__
`define __XBAR_SIMPLE_TEST_CASE_SV__

class xbar_simple_test_case extends xbar_test_base;
    
    `uvm_component_utils(xbar_simple_test_case)
    function new (string name = "xbar_simple_test_case", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        xbar_simple_sequence    simple_seq = xbar_simple_sequence::type_id::create("simple_seq");
        phase.raise_objection(this);
            init_vseq(simple_seq);
            simple_seq.start(null);
        phase.drop_objection(this);
    endtask


endclass
`endif 
