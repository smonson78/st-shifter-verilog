// 256x12 dual-port RAM for palette registers
// This read-write interface for both ports is the same as the Altera dual-port RAM
// megafunction - port B is actually read-only.
module pal_ram(addr_a, addr_b, clk, data_a, data_b, we_a, we_b, q_a, q_b);
	input clk;
	input [7:0] addr_a;
	input [7:0] addr_b;
	input [15:0] data_a, data_b;
	input we_a, we_b;
	output reg [15:0] q_a, q_b;
	reg [11:0] ram[255:0];

	// port a - used for R/W register interface
	always @ (posedge clk) begin
		if (we_a) begin
			ram[addr_a] <= data_a[11:0];
			q_a <= {4'b0, data_a};
		end else begin
			q_a <= {4'b0, ram[addr_a]};
		end

	end

	// port b - read-only
	always @ (posedge clk) begin
		q_b <= {4'b0, ram[addr_b]};
	end

endmodule
