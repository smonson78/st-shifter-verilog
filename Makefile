TARGETS=shifter tb 

all: $(TARGETS)
clean:
	$(RM) $(TARGETS) dump.lxt

shifter: shifter.v
	iverilog -o $@ $^

tb: tb.v shifter.v
	iverilog -o $@ $^

wave: tb
	vvp tb -lxt2
