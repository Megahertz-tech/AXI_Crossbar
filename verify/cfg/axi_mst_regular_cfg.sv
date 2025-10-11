/* ***********************************************************
    document:       axi_mst_regular_cfg.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    The configuration for the Regular transactions 
                    and accesses to normal sequencial memory.
**************************************************************/
`ifndef __AXI_MST_REGULAR_CFG_SV__
`define __AXI_MST_REGULAR_CFG_SV__
`include "tb_axi_macro_define_pkg.svh"
class axi_mst_regular_cfg extends tb_axi_cfg_base;
    `uvm_object_utils(axi_mst_regular_cfg)    
    `ob_construct(axi_mst_regular_cfg)

    constraint c_addr_and_data_width
    {
            axi_addr_width == gcfg.TbAxiAddrWidth;
            axi_data_width == gcfg.TbAxiDataWidth;
            }
/*
The Regular attribute is defined, to identify transactions which meet the following criteria:
• AxLEN is 1, 2, 4, 8, or 16.
• AxSIZE is the same as the data bus width, if AxLEN is greater than 1.
• AxBURST is INCR or WRAP, not FIXED.
• AxADDR is aligned to the transaction container for INCR transactions.
• AxADDR is aligned to AxSIZE for WRAP transactions.
*/
    constraint c_burst_length_for_regular_transaction {
        //burst_length inside {1,2,4,8,16};
        burst_length inside {2,4,8,16};
    }
/*
INCR is used for accesses to normal sequential memory.
In an incrementing burst, the address for each transfer in the burst is an increment of
the address for the previous transfer. The increment value depends on the size of the transfer.
*/
    constraint c_burst_type
    {
            burst_type == AXI_INCREMENTING_BURST;
            }
    function void post_randomize();
        if(burst_length > 1) begin
                if(gcfg.TbAxiDataWidth == 1)            burst_size = AXI_BURST_SIZE_1_BYTE;
                else if(gcfg.TbAxiDataWidth == 2)       burst_size = AXI_BURST_SIZE_2_BYTES  ;
                else if(gcfg.TbAxiDataWidth == 4)       burst_size = AXI_BURST_SIZE_4_BYTES  ;
                else if(gcfg.TbAxiDataWidth == 8)       burst_size = AXI_BURST_SIZE_8_BYTES  ;
                else if(gcfg.TbAxiDataWidth == 16)      burst_size = AXI_BURST_SIZE_16_BYTES ;
                else if(gcfg.TbAxiDataWidth == 32)      burst_size = AXI_BURST_SIZE_32_BYTES ;
                else if(gcfg.TbAxiDataWidth == 64)      burst_size = AXI_BURST_SIZE_64_BYTES ;
                else if(gcfg.TbAxiDataWidth == 128)     burst_size = AXI_BURST_SIZE_128_BYTES;
                else `uvm_error(get_type_name(), $psprintf("wrong data width: %d", gcfg.TbAxiDataWidth));
        end
    endfunction


endclass

`endif 
