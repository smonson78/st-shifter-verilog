module shifter_module(CLOCK_32, de, cs, load, data, rw, addr, r, g, b);

	input CLOCK_32;
	input de, cs, load, rw;
	inout [15:0] data;
	input [4:0] addr;

	wire [3:0] shifter_r;
	wire [3:0] shifter_g;
	wire [3:0] shifter_b;
	
	output [3:0] r;
	output [3:0] g;
	output [3:0] b;

	wire [15:0] shifter_data_out;
	wire oe;

	assign data = oe ? shifter_data_out : 16'hz;
	assign r = shifter_r;
	assign g = shifter_g;
	assign b = shifter_b;

	shifter shifter_model(CLOCK_32, de, cs, load, data, shifter_data_out, rw, addr, oe, shifter_r, shifter_g, shifter_b);

endmodule
