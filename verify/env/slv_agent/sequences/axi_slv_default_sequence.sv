/* ***********************************************************
    document:       axi_slv_default_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_DEFAULT_SEQUENCE_SV__
`define __AXI_SLV_DEFAULT_SEQUENCE_SV__
`include "axi_slv_sequencer.sv"
`include "uvm_macros.svh"
class axi_slv_default_sequence extends uvm_sequence #(axi_slv_seq_item);
    shortint slv_id;
    int mem[int];
    `uvm_object_utils(axi_slv_default_sequence)
    //`uvm_declare_p_sequencer(axi_slv_sequencer)
    function new (string name = "axi_slv_default_sequence");
        super.new(name);
    endfunction
    function void set_slave_id (shortint id);
        this.slv_id = id;
    endfunction
    task body();
        axi_slv_seq_item req, rsp;
        int item_num = 0;
        `uvm_info("SLV_SEQ body", "enter body", UVM_LOW)
        #50ns;
        for(int i=0; i<10; i++) begin
            `uvm_create(req)
            `uvm_info("SLV_SEQ", "uvm_create req", UVM_LOW)
            `uvm_send(req)
            `uvm_info("SLV_SEQ", "uvm_send req", UVM_LOW)
            `uvm_create(rsp)
            `uvm_info("SLV_SEQ", "uvm_create rsp", UVM_LOW)
            rsp.copy(req);
            if(rsp.is_aw) begin
                assert(rsp.aw_valid) 
                else `uvm_error($sformatf("slave_%d AW-channel", slv_id), "aw_valid deasserted!")
            end
            if(rsp.is_w) begin
                assert(rsp.w_last[rsp.aw_len+1])
                else `uvm_error($sformatf("slave_%d W-channel", slv_id), "w_last deasserted!")          
                for(int i=0;i<rsp.aw_len+1;i++) begin
                    mem[rsp.aw_addr+8*i] =  rsp.w_data[i];   
                end
            end
            if(rsp.is_b) begin
                if(!rsp.randomize() with {
                    b_id == rsp.aw_id;
                    b_valid == 1'b1;
                    b_resp == AXI_OKAY;
                }) `uvm_error($sformatf("slave_%d B-channel", slv_id), "randomize wrong!!");
            end
            if(rsp.is_ar) begin
                assert(rsp.ar_valid)
                else `uvm_error($sformatf("slave_%d AR-channel", slv_id), "ar_valid deasserted!")
            end
            if(rsp.is_r) begin
                int data;
                rsp.r_valid = 1'b1;
                rsp.r_data = new[rsp.ar_len+1];   
                rsp.r_last = new[rsp.ar_len+1];
                rsp.r_resp = new[rsp.ar_len+1];
                foreach(rsp.r_last[i]) begin
                    rsp.r_last[i] = 1'b0;
                    rsp.r_resp[i] = AXI_OKAY;
                end
                rsp.r_last[rsp.ar_len+1] = 1'b1;
                foreach(rsp.r_data[i]) begin
                    if(mem.exists(rsp.ar_addr+8*i)) rsp.r_data[i] = mem[rsp.ar_addr+8*i];
                    else begin
                        assert(std::randomize(data));
                        rsp.r_data[i] =data;
                    end
                end
            end
            `uvm_send(rsp)
            `uvm_info("SLV_SEQ", "uvm_send rsp", UVM_LOW)
        end
        //if(p_sequencer==null) `uvm_error("SLV_SEQ","p_sequencer is null !!!!!!")
        //else `uvm_info("SLV_SEQ",p_sequencer.get_full_name(),UVM_LOW)
        /*
        while(1) begin
            //slave request
            req_item = axi_slv_seq_item::type_id::create("req_item");
            start_item(req_item, -1, p_sequencer);
            `uvm_info("SLV_SEQ", "start req", UVM_LOW)
            item_num++;
            finish_item(req_item);
            `uvm_info("SLV_SEQ", "finish req", UVM_LOW)
            //slave response
            start_item(rsp_item, -1, p_sequencer);
            `uvm_info("SLV_SEQ", "start rsp", UVM_LOW)
            rsp_item.copy(req_item);
            if(rsp_item.is_aw) begin
                assert(rsp_item.aw_valid) 
                else `uvm_error($sformatf("slave_%d AW-channel", slv_id), "aw_valid deasserted!")
            end
            if(rsp_item.is_w) begin
                assert(rsp_item.w_last[rsp_item.aw_len+1])
                else `uvm_error($sformatf("slave_%d W-channel", slv_id), "w_last deasserted!")          
                for(int i=0;i<rsp_item.aw_len+1;i++) begin
                    mem[rsp_item.aw_addr+8*i] =  rsp_item.w_data[i];   
                end
            end
            if(rsp_item.is_b) begin
                if(!rsp_item.randomize() with {
                    b_id == rsp_item.aw_id;
                    b_valid == 1'b1;
                    b_resp == AXI_OKAY;
                }) `uvm_error($sformatf("slave_%d B-channel", slv_id), "randomize wrong!!");
            end
            if(rsp_item.is_ar) begin
                assert(rsp_item.ar_valid)
                else `uvm_error($sformatf("slave_%d AR-channel", slv_id), "ar_valid deasserted!")
            end
            if(rsp_item.is_r) begin
                int data;
                rsp_item.r_valid = 1'b1;
                rsp_item.r_data = new[rsp_item.ar_len+1];   
                rsp_item.r_last = new[rsp_item.ar_len+1];
                rsp_item.r_resp = new[rsp_item.ar_len+1];
                foreach(rsp_item.r_last[i]) begin
                    rsp_item.r_last[i] = 1'b0;
                    rsp_item.r_resp[i] = AXI_OKAY;
                end
                rsp_item.r_last[rsp_item.ar_len+1] = 1'b1;
                foreach(rsp_item.r_data[i]) begin
                    if(mem.exists(rsp_item.ar_addr+8*i)) rsp_item.r_data[i] = mem[rsp_item.ar_addr+8*i];
                    else begin
                        assert(std::randomize(data));
                        rsp_item.r_data[i] =data;
                    end
                end
            end
            finish_item(rsp_item);
            #1ps;
        end
        */
    endtask


endclass 
`endif 
