`timescale 1ns/1ps

module tb_traffic_light_fsm;

    logic clk;
    logic reset;
    logic TAORB;

    logic AG, AY, AR;
    logic BG, BY, BR;

    // DUT
    traffic_light_fsm dut (
        .clk   (clk),
        .reset (reset),
        .TAORB (TAORB),
        .AG    (AG),
        .AY    (AY),
        .AR    (AR),
        .BG    (BG),
        .BY    (BY),
        .BR    (BR)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        
        reset = 1;
        TAORB = 1;

        
        #20;
        reset = 0;

      
        #40;

       
        TAORB = 0;
        #80;

       
        #40;

       
        TAORB = 1;
        #80;

       
        #40;

        $finish;
    end

    // Monitor
    initial begin
        $display("time\tclk\treset\tTAORB\tstate\ttimer\tAG AY AR\tBG BY BR");
        $monitor("%0t\t%b\t%b\t%b\t%0d\t%0d\t%b  %b  %b\t%b  %b  %b",
                 $time, clk, reset, TAORB, dut.state, dut.timer,
                 AG, AY, AR, BG, BY, BR);
    end

endmodule