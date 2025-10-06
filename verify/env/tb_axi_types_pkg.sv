/* ***********************************************************
    document:       tb_axi_types_pkg.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Encapsulting the data types for TB. 
                    All data types are defined in the AXI4 spec.
**************************************************************/
`ifndef __TB_AXI_TYPES_PKG_SVH__ 
`define __TB_AXI_TYPES_PKG_SVH__
package tb_axi_types_pkg;
    `include "tb_axi_macro_define.svh"

    typedef logic [`TVIP_AXI_MAX_ID_WIDTH-1:0]      tvip_axi_id;
    typedef logic [`TVIP_AXI_MAX_ADDRESS_WIDTH-1:0] tvip_axi_address;
    typedef logic [7:0]                             tvip_axi_burst_length; // the number of read/write transfers 
    typedef logic [3:0]                             tvip_axi_cache;
    typedef logic [3:0]                             tvip_axi_qos;
    typedef logic [`TVIP_AXI_MAX_DATA_WIDTH-1:0]    tvip_axi_data;
    typedef logic [`TVIP_AXI_MAX_DATA_WIDTH/8-1:0]  tvip_axi_strobe;
    typedef enum logic [2:0] { // the maximum number of bytes to transfer in each data transfer, or beat, in a burst.
        TVIP_AXI_BURST_SIZE_1_BYTE    = 'b0000,
        TVIP_AXI_BURST_SIZE_2_BYTES   = 'b0001,
        TVIP_AXI_BURST_SIZE_4_BYTES   = 'b0010,
        TVIP_AXI_BURST_SIZE_8_BYTES   = 'b0011,
        TVIP_AXI_BURST_SIZE_16_BYTES  = 'b0100,
        TVIP_AXI_BURST_SIZE_32_BYTES  = 'b0101,
        TVIP_AXI_BURST_SIZE_64_BYTES  = 'b0110,
        TVIP_AXI_BURST_SIZE_128_BYTES = 'b0111
    } tvip_axi_burst_size;  

    typedef enum logic [1:0] { // The AXI protocol defines three burst types
        TVIP_AXI_FIXED_BURST        = 'b00, //is used for repeated accesses to the same location such as when loading or emptying a FIFO.
        TVIP_AXI_INCREMENTING_BURST = 'b01, //is used for accesses to normal sequential memory.
        TVIP_AXI_WRAPPING_BURST     = 'b10  //is used for cache line accesses
    } tvip_axi_burst_type; 
    typedef enum {
        TVIP_AXI_DEVICE_NON_BUFFERABLE,
        TVIP_AXI_DEVICE_BUFFERABLE,
        TVIP_AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE,
        TVIP_AXI_NORMAL_NON_CACHEABLE_BUFFERABLE,
        TVIP_AXI_WRITE_THROUGH_NO_ALLOCATE,
        TVIP_AXI_WRITE_THROUGH_READ_ALLOCATE,
        TVIP_AXI_WRITE_THROUGH_WRITE_ALLOCATE,
        TVIP_AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE,
        TVIP_AXI_WRITE_BACK_NO_ALLOCATE,
        TVIP_AXI_WRITE_BACK_READ_ALLOCATE,
        TVIP_AXI_WRITE_BACK_WRITE_ALLOCATE,
        TVIP_AXI_WRITE_BACK_READ_WRITE_ALLOCATE
    } tvip_axi_memory_type;

    typedef enum logic [1:0] { // For write: transaction-level. For read: transfer-level.
        TVIP_AXI_OKAY         = 'b00, // Normal access success; or  an exclusive access has failed.
        TVIP_AXI_EXOKAY       = 'b01, // Exclusive access okay; 
        TVIP_AXI_SLAVE_ERROR  = 'b10, // Subordinate error. 
        TVIP_AXI_DECODE_ERROR = 'b11  // Decode error.  
                                      // Generated, typically by an interconnect component, to indicate that 
                                      // there is no ubordinate at the transaction address. 
    } tvip_axi_response;
     
    typedef struct packed {
        logic allocate;
        logic other_allocate;
        logic modifiable;
        logic bufferable;
    } tvip_axi_write_cache;

    typedef struct packed {
        logic other_allocate;
        logic allocate;
        logic modifiable;
        logic bufferable;
    } tvip_axi_read_cache;

    typedef struct packed { // access permissions to be used to protect against illegal transactions
        logic instruction_access;
        logic non_secure_access;
        logic privileged_access;
    } tvip_axi_protection; // ARPROT, AWPROT


  function automatic tvip_axi_cache encode_memory_type(tvip_axi_memory_type memory_type, bit read_access);
    case (memory_type)
      TVIP_AXI_DEVICE_NON_BUFFERABLE:               return 4'b0000;
      TVIP_AXI_DEVICE_BUFFERABLE:                   return 4'b0001;
      TVIP_AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE: return 4'b0010;
      TVIP_AXI_NORMAL_NON_CACHEABLE_BUFFERABLE:     return 4'b0011;
      TVIP_AXI_WRITE_THROUGH_NO_ALLOCATE:           return (read_access) ? 4'b1010 : 4'b0110;
      TVIP_AXI_WRITE_THROUGH_READ_ALLOCATE:         return (read_access) ? 4'b1110 : 4'b0110;
      TVIP_AXI_WRITE_THROUGH_WRITE_ALLOCATE:        return (read_access) ? 4'b1010 : 4'b1110;
      TVIP_AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE:   return 4'b1110;
      TVIP_AXI_WRITE_BACK_NO_ALLOCATE:              return (read_access) ? 4'b1011 : 4'b1110;
      TVIP_AXI_WRITE_BACK_READ_ALLOCATE:            return (read_access) ? 4'b1111 : 4'b0111;
      TVIP_AXI_WRITE_BACK_WRITE_ALLOCATE:           return (read_access) ? 4'b1011 : 4'b1111;
      TVIP_AXI_WRITE_BACK_READ_WRITE_ALLOCATE:      return 4'b1111;
    endcase
  endfunction

  function automatic tvip_axi_memory_type decode_memory_type(tvip_axi_cache cache, bit read_access);
    if (read_access) begin
      case (cache)
        4'b0000:  return TVIP_AXI_DEVICE_NON_BUFFERABLE;
        4'b0001:  return TVIP_AXI_DEVICE_BUFFERABLE;
        4'b0010:  return TVIP_AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
        4'b0011:  return TVIP_AXI_NORMAL_NON_CACHEABLE_BUFFERABLE;
        4'b1010:  return TVIP_AXI_WRITE_THROUGH_NO_ALLOCATE;
        4'b1110:  return TVIP_AXI_WRITE_THROUGH_READ_ALLOCATE;
        4'b1010:  return TVIP_AXI_WRITE_THROUGH_WRITE_ALLOCATE;
        4'b1110:  return TVIP_AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE;
        4'b1011:  return TVIP_AXI_WRITE_BACK_NO_ALLOCATE;
        4'b1111:  return TVIP_AXI_WRITE_BACK_READ_ALLOCATE;
        4'b1011:  return TVIP_AXI_WRITE_BACK_WRITE_ALLOCATE;
        4'b1111:  return TVIP_AXI_WRITE_BACK_READ_WRITE_ALLOCATE;
      endcase
    end
    else begin
      case (cache)
        4'b0000:  return TVIP_AXI_DEVICE_NON_BUFFERABLE;
        4'b0001:  return TVIP_AXI_DEVICE_BUFFERABLE;
        4'b0010:  return TVIP_AXI_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
        4'b0011:  return TVIP_AXI_NORMAL_NON_CACHEABLE_BUFFERABLE;
        4'b0110:  return TVIP_AXI_WRITE_THROUGH_NO_ALLOCATE;
        4'b0110:  return TVIP_AXI_WRITE_THROUGH_READ_ALLOCATE;
        4'b1110:  return TVIP_AXI_WRITE_THROUGH_WRITE_ALLOCATE;
        4'b1110:  return TVIP_AXI_WRITE_THROUGH_READ_WRITE_ALLOCATE;
        4'b0111:  return TVIP_AXI_WRITE_BACK_NO_ALLOCATE;
        4'b0111:  return TVIP_AXI_WRITE_BACK_READ_ALLOCATE;
        4'b1111:  return TVIP_AXI_WRITE_BACK_WRITE_ALLOCATE;
        4'b1111:  return TVIP_AXI_WRITE_BACK_READ_WRITE_ALLOCATE;
      endcase
    end
  endfunction


endpackage 
`endif 
