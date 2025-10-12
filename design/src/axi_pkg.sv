// AXI Package
// Contains all necessary type definitions, constants, and generally useful functions.
`ifndef AXI_PKG_SV
`define AXI_PKG_SV
package axi_pkg;
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

  /// AXI Transaction Burst Width.
  typedef logic [1:0]  burst_t;
  /// AXI Transaction Response Type.
  typedef logic [1:0]   resp_t;
  /// AXI Transaction Cacheability Type.
  typedef logic [3:0]  cache_t;
  /// AXI Transaction Protection Type.
  typedef logic [2:0]   prot_t;
  /// AXI Transaction Quality of Service Type.
  typedef logic [3:0]    qos_t;
  /// AXI Transaction Region Type.
  typedef logic [3:0] region_t;
  /// AXI Transaction Length Type.
  typedef logic [7:0]    len_t;
  /// AXI Transaction Size Type.
  typedef logic [2:0]   size_t;
  /// AXI5 Atomic Operation Type.
  typedef logic [5:0]   atop_t; // atomic operations
  /// AXI5 Non-Secure Address Identifier.
  typedef logic [3:0]  nsaid_t;

  /// In a fixed burst:
  /// - The address is the same for every transfer in the burst.
  /// - The byte lanes that are valid are constant for all beats in the burst.  However, within
  ///   those byte lanes, the actual bytes that have `wstrb` asserted can differ for each beat in
  ///   the burst.
  /// This burst type is used for repeated accesses to the same location such as when loading or
  /// emptying a FIFO.
  localparam BURST_FIXED = 2'b00;
  /// In an incrementing burst, the address for each transfer in the burst is an increment of the
  /// address for the previous transfer.  The increment value depends on the size of the transfer.
  /// For example, the address for each transfer in a burst with a size of 4 bytes is the previous
  /// address plus four.
  /// This burst type is used for accesses to normal sequential memory.
  localparam BURST_INCR  = 2'b01;
  /// A wrapping burst is similar to an incrementing burst, except that the address wraps around to
  /// a lower address if an upper address limit is reached.
  /// The following restrictions apply to wrapping bursts:
  /// - The start address must be aligned to the size of each transfer.
  /// - The length of the burst must be 2, 4, 8, or 16 transfers.
  localparam BURST_WRAP  = 2'b10;

  /// Normal access success.  Indicates that a normal access has been successful. Can also indicate
  /// that an exclusive access has failed.
  localparam RESP_OKAY   = 2'b00;
  /// Exclusive access okay.  Indicates that either the read or write portion of an exclusive access
  /// has been successful.
  localparam RESP_EXOKAY = 2'b01;
  /// Slave error.  Used when the access has reached the slave successfully, but the slave wishes to
  /// return an error condition to the originating master.
  localparam RESP_SLVERR = 2'b10;
  /// Decode error.  Generated, typically by an interconnect component, to indicate that there is no
  /// slave at the transaction address.
  localparam RESP_DECERR = 2'b11;

  /// When this bit is asserted, the interconnect, or any component, can delay the transaction
  /// reaching its final destination for any number of cycles.
  localparam CACHE_BUFFERABLE = 4'b0001;
  /// When HIGH, Modifiable indicates that the characteristics of the transaction can be modified.
  /// When Modifiable is LOW, the transaction is Non-modifiable.
  localparam CACHE_MODIFIABLE = 4'b0010;
  /// When this bit is asserted, read allocation of the transaction is recommended but is not
  /// mandatory.
  localparam CACHE_RD_ALLOC   = 4'b0100;
  /// When this bit is asserted, write allocation of the transaction is recommended but is not
  /// mandatory.
  localparam CACHE_WR_ALLOC   = 4'b1000;

  // ATOP[5:0]
  /// - Sends a single data value with an address.
  /// - The target swaps the value at the addressed location with the data value that is supplied in
  ///   the transaction.
  /// - The original data value at the addressed location is returned.
  /// - Outbound data size is 1, 2, 4, or 8 bytes.
  /// - Inbound data size is the same as the outbound data size.
  localparam ATOP_ATOMICSWAP  = 6'b110000;
  /// - Sends two data values, the compare value and the swap value, to the addressed location.
  ///   The compare and swap values are of equal size.
  /// - The data value at the addressed location is checked against the compare value:
  ///   - If the values match, the swap value is written to the addressed location.
  ///   - If the values do not match, the swap value is not written to the addressed location.
  /// - The original data value at the addressed location is returned.
  /// - Outbound data size is 2, 4, 8, 16, or 32 bytes.
  /// - Inbound data size is half of the outbound data size because the outbound data contains both
  ///   compare and swap values, whereas the inbound data has only the original data value.
  localparam ATOP_ATOMICCMP   = 6'b110001;
  // ATOP[5:4]
  /// Perform no atomic operation.
  localparam ATOP_NONE        = 2'b00;
  /// - Sends a single data value with an address and the atomic operation to be performed.
  /// - The target performs the operation using the sent data and value at the addressed location as
  ///   operands.
  /// - The result is stored in the address location.
  /// - A single response is given without data.
  /// - Outbound data size is 1, 2, 4, or 8 bytes.
  localparam ATOP_ATOMICSTORE = 2'b01;
  /// Sends a single data value with an address and the atomic operation to be performed.
  /// - The original data value at the addressed location is returned.
  /// - The target performs the operation using the sent data and value at the addressed location as
  ///   operands.
  /// - The result is stored in the address location.
  /// - Outbound data size is 1, 2, 4, or 8 bytes.
  /// - Inbound data size is the same as the outbound data size.
  localparam ATOP_ATOMICLOAD  = 2'b10;
  // ATOP[3]
  /// For AtomicStore and AtomicLoad transactions `AWATOP[3]` indicates the endianness that is
  /// required for the atomic operation.  The value of `AWATOP[3]` applies to arithmetic operations
  /// only and is ignored for bitwise logical operations.
  /// When deasserted, this bit indicates that the operation is little-endian.
  localparam ATOP_LITTLE_END  = 1'b0;
  /// When asserted, this bit indicates that the operation is big-endian.
  localparam ATOP_BIG_END     = 1'b1;
  // ATOP[2:0]
  /// The value in memory is added to the sent data and the result stored in memory.
  localparam ATOP_ADD   = 3'b000;
  /// Every set bit in the sent data clears the corresponding bit of the data in memory.
  localparam ATOP_CLR   = 3'b001;
  /// Bitwise exclusive OR of the sent data and value in memory.
  localparam ATOP_EOR   = 3'b010;
  /// Every set bit in the sent data sets the corresponding bit of the data in memory.
  localparam ATOP_SET   = 3'b011;
  /// The value stored in memory is the maximum of the existing value and sent data. This operation
  /// assumes signed data.
  localparam ATOP_SMAX  = 3'b100;
  /// The value stored in memory is the minimum of the existing value and sent data. This operation
  /// assumes signed data.
  localparam ATOP_SMIN  = 3'b101;
  /// The value stored in memory is the maximum of the existing value and sent data. This operation
  /// assumes unsigned data.
  localparam ATOP_UMAX  = 3'b110;
  /// The value stored in memory is the minimum of the existing value and sent data. This operation
  /// assumes unsigned data.
  localparam ATOP_UMIN  = 3'b111;
  // ATOP[5] == 1'b1 indicated that an atomic transaction has a read response
  // Ussage eg: if (req_i.aw.atop[axi_pkg::ATOP_R_RESP]) begin
  localparam ATOP_R_RESP = 32'd5;
  
  //{{{ Celine add 
    typedef struct packed {
      int unsigned NoSlvPorts;         // Number of slave ports (master connections)
      int unsigned NoMstPorts;         // Number of master ports (slave connections)
      int unsigned MaxMstTrans;        // Max outstanding transactions per slave port
      int unsigned MaxSlvTrans;        // Max outstanding transactions per master port per ID
      bit          FallThrough;        // AW→W routing fall-through enable
      logic [9:0]  LatencyMode;        // Pipeline configuration per channel
      int unsigned AxiIdWidthSlvPorts; // Slave port ID width
      int unsigned AxiIdUsedSlvPorts;  // Used ID bits for ordering decisions
      bit          UniqueIds;          // ID uniqueness guarantee
      int unsigned AxiAddrWidth;       // Address width
      int unsigned AxiDataWidth;       // Data width
      int unsigned NoAddrRules;        // Number of address map rules
      int unsigned PipelineStages;     // Cross-connection pipeline depth
    } xbar_cfg_t;

    typedef struct packed {
        int unsigned idx;
        logic [31:0] start_addr;
        logic [31:0] end_addr;
    } xbar_rule_32_t;

    //}}}

endpackage
`endif
