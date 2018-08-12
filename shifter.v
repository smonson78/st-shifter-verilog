// Shifter model based on Ijor's reverse-engineering.

`define RISING 2'b01
`define FALLING 2'b10
`define HIGH 2'b11
`define LOW 2'b00

module shifter(CLOCK_32, de, cs, load, data, data_out, rw, addr, oe, r, g, b);
	input CLOCK_32;
	input de, cs, load, rw;
	input [15:0] data;
	output [15:0] data_out;
	input [4:0] addr;
	output oe;
		
	// STE-style palettes with LSB in position 3
	output [3:0] r;
	output [3:0] g; 
	output [3:0] b;

	wire [3:0] mono_intensity;

	reg [15:0] shift_rr[3:0];
	reg [15:0] shift_ir[3:0];
	reg [1:0] resolution;
	reg [11:0] palette [15:0];
	wire [63:0] shift_ir_test;
	
	// For use of gtkwave
	assign shift_ir_test = {
		shift_ir[0], shift_ir[1], shift_ir[2], shift_ir[3]
	};
	wire [63:0] shift_rr_test;
	assign shift_rr_test = {
		shift_rr[0], shift_rr[1], shift_rr[2], shift_rr[3]
	};
	
	wire [3:0] palette_low;
	wire [1:0] palette_med;
	wire mono;
	
	reg [3:0] palette_index;
	wire reset;
	
	reg [1:0] de_state;
	reg [1:0] load_state;
	reg [3:0] load_count;
	
	reg load_detect;
	reg reload;
	reg reload_delay;
	reg [3:0] pixel_count;
	reg load_detect_delay;
	reg pixel_counter_enable;
	reg shifter_running;
	reg first_load_seen;
	reg [2:0] loads_seen;

	wire pixel_clock;

	assign reset = (!load) && (!cs);
	assign mono = shift_rr[0][15];
	assign mono_intensity = palette[0][0] == 0 ?
		(mono ? 4'b1111 : 4'b0) : (mono ? 4'b0 : 4'b1111);
	assign r = resolution == 2 ? mono_intensity : 
		    {palette[palette_index][10:8], palette[palette_index][11]};
	assign g = resolution == 2 ? mono_intensity :
		    {palette[palette_index][6:4], palette[palette_index][7]};
	assign b = resolution == 2 ? mono_intensity :
		    {palette[palette_index][2:0], palette[palette_index][3]};

	assign palette_low = {
		shift_rr[3][15], 
		shift_rr[2][15],
		shift_rr[1][15], 
		shift_rr[0][15]
	};

	assign palette_med = {
		shift_rr[1][15], 
		shift_rr[0][15]
	};
	
	// data bus
	assign oe = (!cs) && rw;
	assign data_out = addr[4] == 1 ? {6'b0, resolution, 8'b0} : {4'b0, palette[addr[3:0]]};

	reg [1:0] speed_divider;
	
	assign pixel_clock = resolution == 2 ? CLOCK_32 :
		(resolution == 1 ? speed_divider[0] : speed_divider[1]);
	
	// Generate 16MHz and 8MHz pixel clocks from 32MHz clock
	always @(posedge CLOCK_32) begin
		if (reset) begin
			speed_divider <= 0;
		end else begin
			speed_divider <= speed_divider + 2'b1;
		end
	end
	
	initial begin
	    shift_rr[0] = 0;
	    shift_rr[1] = 0;
	    shift_rr[2] = 0;
	    shift_rr[3] = 0;
		load_detect = 0;
		load_detect_delay = 0;
		load_state = 2'b11; // because it's active low
		de_state = 0;
		load_count = 0;
		resolution = 0;
		pixel_count = 0;
		pixel_counter_enable = 0;
		speed_divider = 2'b0;
		reload = 0;
	end
	
	// Shift registers for detecting edges/levels
	always @(posedge CLOCK_32) begin
		de_state <= {de_state[0], de};
		load_state <= {load_state[0], load};
	end	
	
	always @(posedge load or posedge reload_delay) begin
		// Count loads by shifting ones into this shift register
		if (reload_delay) begin
			load_count <= 4'b0000;
		end else if (load) begin
			load_count <= {load_count[2:0], 1'b1};
		end
	end
	
	// shifter reload
	always @(posedge pixel_clock) begin
	    if (load_count[3] && pixel_count == 4'b1111) begin
			reload = 1;
		end else begin
			reload = 0;
		end
	end
	
	// reload_delay
	always @(posedge pixel_clock or posedge reset) begin
	    if (reset) begin
	        reload_delay = 0;
	    end else begin
	        reload_delay = reload;
	    end
    end
	
	// load detect
	wire n_de;
	assign n_de = ~de;
	always @(posedge load or posedge n_de) begin
		if (n_de) begin
			load_detect = 0;
		end else if (load) begin
			load_detect = 1;
		end
	end
	
	always @(posedge pixel_clock) begin
		load_detect_delay = load_detect;
	end
    
	always @(posedge load_detect_delay or posedge reload or posedge reset) begin
		if (load_detect_delay) begin
			pixel_counter_enable = 1;
		end else if (reset) begin
			pixel_counter_enable = 0;
		end else if (reload) begin
			pixel_counter_enable = load_detect_delay;
		end
	end
	
	always @(posedge pixel_clock) begin
		if (pixel_counter_enable) begin
			pixel_count <= pixel_count + 4'b1;
		end else begin
			pixel_count <= 4'd4; 
		end
	end
	
	always @(posedge pixel_clock) begin
		if (reload_delay) begin
			// Refill shifter when empty
			shift_rr[0] <= shift_ir[0];
			shift_rr[1] <= shift_ir[1];
			shift_rr[2] <= shift_ir[2];
			shift_rr[3] <= shift_ir[3];
		end else begin
			// normal shift
			if (resolution == 0) begin
				// lo-res, every 4th clock
				shift_rr[0] <= {shift_rr[0][14:0], 1'b0};
				shift_rr[1] <= {shift_rr[1][14:0], 1'b0};
				shift_rr[2] <= {shift_rr[2][14:0], 1'b0};
				shift_rr[3] <= {shift_rr[3][14:0], 1'b0};		
			end else if (resolution == 1) begin
				// Medium res, every 2nd clock
				shift_rr[0] <= {shift_rr[0][14:0], shift_rr[2][15]};
				shift_rr[1] <= {shift_rr[1][14:0], shift_rr[3][15]};
				shift_rr[2] <= {shift_rr[2][14:0], 1'b0};
				shift_rr[3] <= {shift_rr[3][14:0], 1'b0};		
			end else begin
				// Monochrome, every clock
				shift_rr[0] <= {shift_rr[0][14:0], shift_rr[1][15]};
				shift_rr[1] <= {shift_rr[1][14:0], shift_rr[2][15]};
				shift_rr[2] <= {shift_rr[2][14:0], shift_rr[3][15]};
				shift_rr[3] <= {shift_rr[3][14:0], 1'b0};
			end
		end
	end
	
	// register writes
	always @(posedge CLOCK_32) begin
		if (reset) begin
			resolution <= 2'b0;
		end else if (!cs && !rw) begin
			if (addr == 16) begin
				resolution <= data[1:0];
			end else begin
				palette[addr[3:0]] <= data[11:0];
			end
		end
	end

	// load shifter
	always @(posedge CLOCK_32) begin
		if (load_state == `RISING && cs) begin
			// Shift them all over by one
			shift_ir[3] <= data;
			shift_ir[2] <= shift_ir[3];
			shift_ir[1] <= shift_ir[2];
			shift_ir[0] <= shift_ir[1];
		end
	end
	
	// Assign palette index
	always @(posedge pixel_clock) begin
		palette_index <= resolution == 0 ? palette_low : {2'b00, palette_med};
	end	

endmodule
