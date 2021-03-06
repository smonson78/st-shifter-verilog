`timescale 1 ns / 100 ps
module tb();

	reg CLOCK_32;
	reg de, cs, load, rw;
	reg [15:0] data;
	reg [4:0] addr;

	// shifter implementation
	wire [15:0] shifter_data_out;
	wire [3:0] shifter_r;
	wire [3:0] shifter_g;
	wire [3:0] shifter_b;
	wire oe;
	shifter shifter_model(CLOCK_32, de, cs, load, data, shifter_data_out, rw, addr, oe, 
		shifter_r, shifter_g, shifter_b);

	always
		#15 CLOCK_32 = ~CLOCK_32;	
				
	initial
	begin
		$display($time, " << Starting Simulation >> ");
		$dumpfile("dump.lxt");
		$dumpvars(0, tb);
	 
		CLOCK_32 = 1'b0;
		de = 0;
		cs = 1;
		rw = 1;
		load = 1;
		addr = 0;
		#90
		/*
        // reset! - but don't because it screws up the first shifts
        #30
        de = 0;
        cs = 0;
        load = 0;
        #30
        cs = 1;
        load = 1;
        */
		// Set palette colour 0 to black
		#30
		data = 16'h0000;
		addr = 5'h0;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 16 to white
		#30
		data = 16'h0fff;
		addr = 5'hf;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 3 to white
		#30
		addr = 5'h3;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;
		#15
		data = 16'hz;

		// Set resolution medium
		
		#30
		data = 16'd0;
		addr = 16'd16;
		cs = 1'b0;
		rw = 1'b0;
		#30
		cs = 1'b1;
		rw = 1'b1;
		#15
		data = 16'hz;
		
	    // Start loading data
		#30
		de = 1'b1;

	    // first load - we're going to load three to prime the shifter.
	    // We need to do this because the ST turning on and raising the /LOAD signal
	    // gets counted as the first of 4 loads. We'll load 3 more to clear the
	    // counter. This would naturally happen after the first scanline anyway.
	    data = 16'h0;
		repeat (3) begin // 2 loads, 
		    #360
		    load = 1'b0;
		    #120
		    load = 1'b1;
		end
		
		// Do a new scanline to start fresh
		de = 0;
        #1440
        #1440        
        de = 1;
        
		// delay 24 cycles (6 ST cycles) - wakestate 1
		// delay 12 cycles (3 ST cycles) - wakestate 2
		// delay 20 cycles (5 ST cycles) - wakestate 3
		// delay 16 cycles (4 ST cycles) - wakestate 4
		repeat (6) begin
		    #120; // 4 cycles
		end		    
        
        // First load after getting back in sync
        data = 16'haaaa;
	    load = 1'b0;
	    #120
	    load = 1'b1;
	    
	    // Set palette colour 0 to grey
	    /*
	    #120
		data = 16'h0444;
		addr = 5'h0;
        #60
		cs = 1'b0;
		rw = 1'b0;
		#60
		cs = 1'b1;
		rw = 1'b1;
		*/
		
		#240 // in place of palette write
        #120 // 1 load
        data = 16'haaaa;
	    load = 1'b0;
	    #120
	    load = 1'b1;
	    
		
		repeat (10) begin // 2 loads
		    #360
		    load = 1'b0;
		    #120
		    load = 1'b1;
		end		
		
		#1000;
		$display($time, "<< Simulation Complete >>");
		$finish;
	end		
	
endmodule
