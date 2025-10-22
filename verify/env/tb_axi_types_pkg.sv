/* ***********************************************************
    document:       tb_axi_types_pkg.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Encapsulting the data types for TB. 
                    All data types are defined in the AXI4 spec.
**************************************************************/
`ifndef __TB_AXI_TYPES_PKG_SVH__ 
`define __TB_AXI_TYPES_PKG_SVH__
`include "tb_xbar_param_pkg.svh"
package tb_axi_types_pkg;
    //typedef virtual axi_inf #(
    //    .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
    //    .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
    //    .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
    //    .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    //) virt_axi_mst_inf;
    //virtual axi_inf #(
    //    .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
    //    .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
    //    .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
    //    .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    //) virt_axi_slv_inf;
    //typedef logic [7:0]                             axi_burst_length; // the number of read/write transfers 
    typedef logic [3:0]                             axi_cache;
    typedef enum logic [2:0] { // the maximum number of bytes to transfer in each data transfer, or beat, in a burst.
        AXI_BURST_SIZE_1_BYTE    = 'b000,
        AXI_BURST_SIZE_2_BYTES   = 'b001,
        AXI_BURST_SIZE_4_BYTES   = 'b010,
        AXI_BURST_SIZE_8_BYTES   = 'b011,
        AXI_BURST_SIZE_16_BYTES  = 'b100,
        AXI_BURST_SIZE_32_BYTES  = 'b101,
        AXI_BURST_SIZE_64_BYTES  = 'b110,
        AXI_BURST_SIZE_128_BYTES = 'b111
    } axi_burst_size;  

    typedef enum logic [1:0] { // The AXI protocol defines three burst types
        AXI_FIXED_BURST        = 'b00, //is used for repeated accesses to the same location such as when loading or emptying a FIFO.
        AXI_INCREMENTING_BURST = 'b01, //is used for accesses to normal sequential memory.
        AXI_WRAPPING_BURST     = 'b10  //is used for cache line accesses
    } axi_burst_type; 
    typedef enum {
        AXI_DEVICE_NON_BUFFERABLE,
        AXI_DEVICE_BUFFERABLE,
        AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE,
        AXI_NORMAL_NON_CACHEABLE_BUFFERABLE,
        AXI_WRITE_THROUGH_NO_ALLOCATE,
        AXI_WRITE_THROUGH_READ_ALLOCATE,
        AXI_WRITE_THROUGH_WRITE_ALLOCATE,
        AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE,
        AXI_WRITE_BACK_NO_ALLOCATE,
        AXI_WRITE_BACK_READ_ALLOCATE,
        AXI_WRITE_BACK_WRITE_ALLOCATE,
        AXI_WRITE_BACK_READ_WRITE_ALLOCATE
    } axi_memory_type;

    typedef enum logic [1:0] { // For write: transaction-level. For read: transfer-level.
        AXI_OKAY         = 'b00, // Normal access success; or  an exclusive access has failed.
        AXI_EXOKAY       = 'b01, // Exclusive access okay; 
        AXI_SLAVE_ERROR  = 'b10, // Subordinate error. 
        AXI_DECODE_ERROR = 'b11  // Decode error.  
                                      // Generated, typically by an interconnect component, to indicate that 
                                      // there is no ubordinate at the transaction address. 
    } axi_response;
     
    typedef struct packed {
        logic allocate;
        logic other_allocate;
        logic modifiable;
        logic bufferable;
    } axi_write_cache;

    typedef struct packed {
        logic other_allocate;
        logic allocate;
        logic modifiable;
        logic bufferable;
    } axi_read_cache;

    typedef struct packed { // access permissions to be used to protect against illegal transactions
        logic instruction_access;
        logic non_secure_access;
        logic privileged_access;
    } axi_protection; // ARPROT, AWPROT

    typedef enum {
        AXI_WRITE_ACCESS,
        AXI_READ_ACCESS
    } axi_access_type;
    typedef enum logic[5:0] {
        AXI_NON_ATOMIC   = 6'b00_0000,
        AXI_ATOMIC_STORE = 6'b01_0000, //response without data
        AXI_ATOMIC_LOAD  = 6'b10_0000, //response with data
        AXI_ATOMIC_SWAP  = 6'b11_0000, //response with data
        AXI_ATOMIC_COMP  = 6'b11_0001  //response with data
    } axi_atop_e;


  function automatic axi_cache encode_memory_type(axi_memory_type memory_type, bit read_access);
    case (memory_type)
      AXI_DEVICE_NON_BUFFERABLE:               return 4'b0000;
      AXI_DEVICE_BUFFERABLE:                   return 4'b0001;
      AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE: return 4'b0010;
      AXI_NORMAL_NON_CACHEABLE_BUFFERABLE:     return 4'b0011;
      AXI_WRITE_THROUGH_NO_ALLOCATE:           return (read_access) ? 4'b1010 : 4'b0110;
      AXI_WRITE_THROUGH_READ_ALLOCATE:         return (read_access) ? 4'b1110 : 4'b0110;
      AXI_WRITE_THROUGH_WRITE_ALLOCATE:        return (read_access) ? 4'b1010 : 4'b1110;
      AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE:   return 4'b1110;
      AXI_WRITE_BACK_NO_ALLOCATE:              return (read_access) ? 4'b1011 : 4'b1110;
      AXI_WRITE_BACK_READ_ALLOCATE:            return (read_access) ? 4'b1111 : 4'b0111;
      AXI_WRITE_BACK_WRITE_ALLOCATE:           return (read_access) ? 4'b1011 : 4'b1111;
      AXI_WRITE_BACK_READ_WRITE_ALLOCATE:      return 4'b1111;
    endcase
  endfunction

  function automatic axi_memory_type decode_memory_type(axi_cache cache, bit read_access);
    if (read_access) begin
      case (cache)
        4'b0000:  return AXI_DEVICE_NON_BUFFERABLE;
        4'b0001:  return AXI_DEVICE_BUFFERABLE;
        4'b0010:  return AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
        4'b0011:  return AXI_NORMAL_NON_CACHEABLE_BUFFERABLE;
        4'b1010:  return AXI_WRITE_THROUGH_NO_ALLOCATE;
        4'b1110:  return AXI_WRITE_THROUGH_READ_ALLOCATE;
        4'b1010:  return AXI_WRITE_THROUGH_WRITE_ALLOCATE;
        4'b1110:  return AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE;
        4'b1011:  return AXI_WRITE_BACK_NO_ALLOCATE;
        4'b1111:  return AXI_WRITE_BACK_READ_ALLOCATE;
        4'b1011:  return AXI_WRITE_BACK_WRITE_ALLOCATE;
        4'b1111:  return AXI_WRITE_BACK_READ_WRITE_ALLOCATE;
      endcase
    end
    else begin
      case (cache)
        4'b0000:  return AXI_DEVICE_NON_BUFFERABLE;
        4'b0001:  return AXI_DEVICE_BUFFERABLE;
        4'b0010:  return AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
        4'b0011:  return AXI_NORMAL_NON_CACHEABLE_BUFFERABLE;
        4'b0110:  return AXI_WRITE_THROUGH_NO_ALLOCATE;
        4'b0110:  return AXI_WRITE_THROUGH_READ_ALLOCATE;
        4'b1110:  return AXI_WRITE_THROUGH_WRITE_ALLOCATE;
        4'b1110:  return AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE;
        4'b0111:  return AXI_WRITE_BACK_NO_ALLOCATE;
        4'b0111:  return AXI_WRITE_BACK_READ_ALLOCATE;
        4'b1111:  return AXI_WRITE_BACK_WRITE_ALLOCATE;
        4'b1111:  return AXI_WRITE_BACK_READ_WRITE_ALLOCATE;
      endcase
    end
  endfunction


endpackage 

import tb_axi_types_pkg::*;
`endif 
