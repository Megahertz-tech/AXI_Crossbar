/* ***********************************************************
    document:       axi_slv_default_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_DEFAULT_SEQUENCE_SV__
`define __AXI_SLV_DEFAULT_SEQUENCE_SV__
class axi_slv_default_sequence extends uvm_sequence #(axi_slv_seq_item);
    shortint slv_id;
    int mem[int];
    `uvm_object_utils(axi_slv_default_sequence)
    function new (string name = "axi_slv_default_sequence");
        super.new(name);
    endfunction
    function void set_slave_id (shortint id);
        this.slv_id = id;
    endfunction
    task body();
        axi_slv_seq_item req_item, rsp_item;
        while(1) begin
            //slave request
            req_item = axi_slv_seq_item::type_id::create("req_item");
            start_item(req_item);
            finish_item(req_item);
            //slave response
            start_item(rsp_item);
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
    endtask


endclass 
`endif 
