/* ***********************************************************
    document:       global_cfg.sv
    author:         Celine (He Zhao) 
    Date:           03/10/2025
    Description:    Globally accessible singleton constant configure 
                    object for the architecture of DUT and TB. 
                    Different configure means different architecture 
                    of DUT and TB.
**************************************************************/
`ifndef __GLOBAL_CFG_SV__
`define __GLOBAL_CFG_SV__

`include "axi_typedef_pkg.svh"
`include "axi_math_pkg.svh"

class global_cfg;
    protected static global_cfg me = get();
    static function global_cfg get();
        if(me == null) me = new();
        return me;
    endfunction 
    

    const int TbNumSlaves = 4;           // Number of slave ports to test
    const int TbNumMasters = 3;          // Number of master ports to test
    const int TbSlvIdWidth = 6;          // Extended ID width for testing
    const int TbAxiDataWidth = 64;       // Data width for verification
    const int TbAxiAddrWidth = 32;       // Address width
    const int TbNumAddrRules = 8;        // Number of address map rules
    const time TbClkPeriod = 4ns;        // 250MHz target frequency
    const time TbApplTime = 0.2 * TbClkPeriod;
    const time TbTestTime = 0.8 * TbClkPeriod;                            

    int MstIdWidth = cf_math_pkg::idx_width(TbNumMasters);

endclass 
`endif
