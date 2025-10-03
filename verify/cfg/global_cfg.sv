/* ***********************************************************
    document:       global_cfg.sv
    author:         Celine (He Zhao) 
    Date:           03/10/2025
    Description:    globally accessible singleton configure 
                    object for verification 
**************************************************************/
`ifndef __GLOBAL_CFG_SV__
`define __GLOBAL_CFG_SV__

`include "axi_typedef_pkg.svh"

class global_cfg;
    protected static global_cfg me = get();
    static function global_cfg get();
        if(me == null) me = new();
        return me;
    endfunction 
    

    int TbNumSlaves = 4;           // Number of slave ports to test
    int TbNumMasters = 3;          // Number of master ports to test
    int TbSlvIdWidth = 6;          // Extended ID width for testing
    int TbAxiDataWidth = 64;       // Data width for verification
    int TbAxiAddrWidth = 32;       // Address width
    int TbNumAddrRules = 8;        // Number of address map rules
    time TbClkPeriod = 4ns;        // 250MHz target frequency
    time TbApplTime = 0.2 * TbClkPeriod;
    time TbTestTime = 0.8 * TbClkPeriod;                            


endclass 
`endif
