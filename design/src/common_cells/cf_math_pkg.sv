/// Common Functions Math Package
///
/// This package provides common mathematical functions used throughout
/// the AXI infrastructure, particularly for calculating bit widths
/// and index sizes.
///
/// TODO: Students may extend this package with additional mathematical
/// utility functions as needed for their implementations.

package cf_math_pkg;

  /// Calculate the minimum number of bits required to represent `num_idx` indices
  ///
  /// This function returns the minimum bit width needed to represent values
  /// from 0 to num_idx-1. For example:
  /// - idx_width(1) = 1 (to represent index 0)
  /// - idx_width(2) = 1 (to represent indices 0,1)
  /// - idx_width(3) = 2 (to represent indices 0,1,2)
  /// - idx_width(4) = 2 (to represent indices 0,1,2,3)
  /// - idx_width(5) = 3 (to represent indices 0,1,2,3,4)
  ///
  /// @param num_idx Number of indices to represent
  /// @return Minimum bit width required
  function automatic int unsigned idx_width(input int unsigned num_idx);
    if (num_idx <= 1) begin
      return 1;
    end else begin
      return $clog2(num_idx);
    end
  endfunction

  /// Calculate the next power of 2 that is >= the input value
  ///
  /// @param value Input value
  /// @return Next power of 2 >= value
  function automatic int unsigned next_pow2(input int unsigned value);
    if (value <= 1) begin
      return 1;
    end else begin
      return 1 << $clog2(value-1) + 1;
    end
  endfunction

  /// Check if a value is a power of 2
  ///
  /// @param value Input value
  /// @return 1 if value is power of 2, 0 otherwise
  function automatic bit is_pow2(input int unsigned value);
    return (value != 0) && ((value & (value - 1)) == 0);
  endfunction

  /// Calculate the minimum of two unsigned integers
  ///
  /// @param a First value
  /// @param b Second value
  /// @return Minimum of a and b
  function automatic int unsigned min(input int unsigned a, input int unsigned b);
    return (a < b) ? a : b;
  endfunction

  /// Calculate the maximum of two unsigned integers
  ///
  /// @param a First value
  /// @param b Second value
  /// @return Maximum of a and b
  function automatic int unsigned max(input int unsigned a, input int unsigned b);
    return (a > b) ? a : b;
  endfunction

endpackage