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

	always begin
		#15 CLOCK_32 = ~CLOCK_32;	
	end
				
	initial
	begin
		$display($time, " << Starting Simulation >> ");
		$dumpfile("dump16.lxt");
		$dumpvars(0, tb);
	 
		CLOCK_32 = 1'b0;
		de = 0;
		cs = 1;
		rw = 1;
		load = 1;
		addr = 0;
		#90

		#30 // test clock skew

		
        // reset! - but don't because it screws up the first shifts
        #30
        de = 0;
        cs = 0;
        load = 0;
        #30
        cs = 1;
        load = 1;
        
		// Set palette colour 0 to black
		#30
		data = 16'h0000;
		addr = 5'h0;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 1
		#30
		data = 16'h0888;
		addr = 5'h1;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 2
		#30
		data = 16'h0111;
		addr = 5'h2;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 3
		#30
        data = 16'h0999;
		addr = 5'h3;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 4
		#30
        data = 16'h0222;
		addr = 5'h4;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 5
		#30
        data = 16'h0aaa;
		addr = 5'h5;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 6
		#30
        data = 16'h0333;
		addr = 5'h6;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 7
		#30
        data = 16'h0bbb;
		addr = 5'h7;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1; 

		// Set palette colour 8
		#30
        data = 16'h0444;
		addr = 5'h8;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1; 

		// Set palette colour 9
		#30
        data = 16'h0ccc;
		addr = 5'h9;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 10
		#30
        data = 16'h0555;
		addr = 5'ha;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 11
		#30
        data = 16'h0ddd;
		addr = 5'hb;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 12
		#30
        data = 16'h0666;
		addr = 5'hc;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 13
		#30
        data = 16'h0eee;
		addr = 5'hd;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 14
		#30
        data = 16'h0777;
		addr = 5'he;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		// Set palette colour 15 to white
		#30
		data = 16'h0fff;
		addr = 5'hf;
		cs = 1'b0;
		rw = 1'b0;
		
		#30
		cs = 1'b1;
		rw = 1'b1;

		data = 16'hz;

		// Set resolution 0
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
		    #120;
		end		    

	repeat (10) begin
		#360
        data = 16'haaaa;
		load = 1'b0;
		#120
		load = 1'b1;

		#360
        data = 16'h6666;
		load = 1'b0;
		#120
		load = 1'b1;

		#360
        data = 16'h1e1e;
		load = 1'b0;
		#120
		load = 1'b1;

		#360
        data = 16'h01fe;
		load = 1'b0;
		#120
		load = 1'b1;
	end           

	#1000;
	$display($time, "<< Simulation Complete >>");
	$finish;
	end		
	
endmodule

/*

Working out what to load into the shifter to get a 1-2-3-4-5-6-7-8-9-a-b-c-d-e-f-0 pattern 

For 16-colour mode:

pixel    0 1 2 3 4 5 6 7 8 9 a b c d e f
plane0   1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0xaaaa
plane1   0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0x6666
plane2   0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0x1e1e
plane3   0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0x01fe

*/






