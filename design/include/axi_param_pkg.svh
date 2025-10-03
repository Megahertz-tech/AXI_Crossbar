/* ***********************************************************
    document:       axi_param_pkg.svh
    author:         Celine (He Zhao) 
    Date:           09/29/2025
    Description:    encapsulate common parameters  
**************************************************************/
`ifndef __AXI_PARAM_PKG_SVH___
`define __AXI_PARAM_PKG_SVH___
package axi_param_pkg;
  /// AXI Transaction Burst Width.
  parameter int unsigned BurstWidth  = 32'd2;
  /// AXI Transaction Response Width.
  parameter int unsigned RespWidth   = 32'd2;
  /// AXI Transaction Cacheability Width.
  parameter int unsigned CacheWidth  = 32'd4;
  /// AXI Transaction Protection Width.
  parameter int unsigned ProtWidth   = 32'd3;
  /// AXI Transaction Quality of Service Width.
  parameter int unsigned QosWidth    = 32'd4;
  /// AXI Transaction Region Width.
  parameter int unsigned RegionWidth = 32'd4;
  /// AXI Transaction Length Width.
  parameter int unsigned LenWidth    = 32'd8;
  /// AXI Transaction Size Width.
  parameter int unsigned SizeWidth   = 32'd3;
  /// AXI Lock Width.
  parameter int unsigned LockWidth   = 32'd1;
  /// AXI5 Atomic Operation Width.
  parameter int unsigned AtopWidth   = 32'd6;
  /// AXI5 Non-Secure Address Identifier.
  parameter int unsigned NsaidWidth  = 32'd4;

endpackage

// import package into $unit
import axi_param_pkg::* 

`endif
