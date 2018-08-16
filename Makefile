TARGETS=shifter pal_ram tb 

all: $(TARGETS)
clean:
	$(RM) $(TARGETS) dump.lxt

shifter: shifter.v pal_ram.v
	iverilog -o $@ $^

tb: tb.v shifter.v pal_ram.v
	iverilog -o $@ $^

%: %.v
	iverilog -o $@ $^

wave: tb
	vvp tb -lxt2
