TARGETS=shifter tb 

all: $(TARGETS)
clean:
	$(RM) $(TARGETS) dump.lxt

shifter: shifter.v
	iverilog -o $@ $^

tb: tb.v shifter.v
	iverilog -o $@ $^

tb16: tb16.v shifter.v
	iverilog -o $@ $^

%: %.v
	iverilog -o $@ $^

wave: tb tb16
	vvp tb -lxt2
	vvp tb16 -lxt2
