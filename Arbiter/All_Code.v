// ariter
`timescale 1ns / 1ps

module arbiter(grant, req, reset, bus,  clk);
input [3:0] req;
input reset;
input clk;
output [3:0] grant;
output [1:0] bus;

// Decode
wire [1:0] B;

// Flip Flop
wire [11:0] din;
wire [3:0] rin;
wire [11:0] Qout;

// Clock
wire enable;
wire checkz;


// Get Bus Value
decoder_4to2 decode(B,req);

// Used for Holding Value if All are 0000
assign checkz =  req[0] | req[1] | req[2] | req[3];
assign enable = clk && checkz;


// Send Bus Value And other Signals into Flip Flop
assign din[1:0] = B[1:0];
assign din[2] = 1'b1;
assign rin[0] = req[3] | req[2] | req[1]; 
d_flip_flop dff0(Qout[2:0],din[2:0],rin[0],enable);

assign din[4:3] = B[1:0];
assign din[5] = 1'b1;
assign rin[1] = req[3] | req[2] |  (~req[1] & req[0]);
d_flip_flop dff1(Qout[5:3],din[5:3],rin[1],enable);

assign din[7:6] = B[1:0];
assign din[8] = 1'b1;
assign rin[2] = req[3] | (~req[2] & (req[1] | req[0]));
d_flip_flop dff2(Qout[8:6],din[8:6],rin[2],enable);

assign din[10:9] = B[1:0];
assign din[11] = 1'b1;
assign rin[3] = ~req[3] & (req[2] |  req[1] | req[0]);
d_flip_flop dff13(Qout[11:9],din[11:9],rin[3],enable);

// Reset All Outputs
and (grant[0],Qout[2],~reset);
and (grant[1],Qout[5],~reset);
and (grant[2],Qout[8],~reset);
and (grant[3],Qout[11],~reset);

assign bus[0] = (Qout[0] | Qout[3] | Qout[6] | Qout[9]) & ~reset;
assign bus[1] = (Qout[1] | Qout[4] | Qout[7] | Qout[10]) & ~reset;

endmodule

//decoder
`timescale 1ns / 1ps


module decoder_4to2(O,I);
input [3:0] I;
output [1:0] O;

wire X;
wire [1:0] Q;

// Makes Input Off Highest Bit
assign X = I[1] & ~I[2];
assign O[0] = X | I[3];
assign O[1] = I[2] | I[3];


endmodule

// Flip Flop
`timescale 1ns / 1ps


module d_flip_flop(Q, D, R, CLK);
input [2:0]D;
input R, CLK;
output reg [2:0] Q;
 always @(posedge CLK)
 if (R == 1'b1)
 begin
 Q <= 1'b000;
 end else
 begin
 Q <= D;
 end 

endmodule


// Test bench
`timescale 1ns / 1ps


module tb_arbiter;
wire [3:0]  grant;
wire [1:0] bus;
reg reset;
reg clk;
reg [3:0] req;

arbiter dut (.grant(grant), .bus(bus), .req(req),.reset(reset), .clk(clk));

    initial begin
     #0
     reset = 1'b1;
     req = 4'b0000;
     clk= 1'b0;
     #10 
     clk= 1'b1;
     #10 
     reset =1'b0;
     req = 4'b0001; 
     #10
     clk= 1'b1;
     #10
     clk= 1'b0;
     #10
     req = 4'b0011;
     #10
     clk= 1'b1;
     #10
     req = 4'b0011;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     req = 4'b0111;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     req = 4'b1111;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     req = 4'b0000;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     req = 4'b0101;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #10
     req = 4'b0000;
     #10
     clk= 1'b0;
     #10
     reset = 1'b1;
     #10
     clk= 1'b1;
     #10
     clk= 1'b0;
     #10
     clk= 1'b1;
     #40
     $finish;
    end

endmodule

