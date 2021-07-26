`timescale 1ns / 1ps

module xorb(Y, U, V);
input U,V;
output reg Y;

always @ (U or V) begin
    if (U == 1'b1 & V == 1'b1)
    begin
    #10 Y <= 1'b0;
    end else if (U == 1'b0 & V == 1'b0)begin
    #10 Y <= 1'b0;
    end else begin
    #10 Y <= 1'b1;
    end
   
end

endmodule


`timescale 1ns / 1ps


module mux8(Muxout, D1, D2, sel);
input [7:0] D1;
input [7:0] D2;
input sel;
output reg [7:0] Muxout;


always @ (D1 or D2 or sel) begin
if (sel == 1'b0)
begin
#10 Muxout <= D1;
end else
begin
#10 Muxout <= D2;
end
end

endmodule


`timescale 1ns / 1ps

module cla8(Sum, Cout, F,G,Ci,Operate);
input [7:0] F;
input [7:0] G;
input Operate;
input Ci;
output reg [7:0] Sum;
output reg Cout;
reg [8:0] t;
reg [7:0] inv;

always @ (posedge Operate) begin
if(Ci) begin
inv = -F;
t <= inv + G;
end 
else begin
t <= F + G;
end
#25 Sum <= t[7:0];
#25 Cout <= t[8];
end

endmodule


`timescale 1ns / 1ps


module asr17(F,G, Multi, Cell, Product, I, StartI, Load, Shift, Reset);

input [7:0] I; // Input From Adder
input [7:0] StartI; // Used To Fill Multiplier Initially
input Load;
input Shift;
input Reset;


output reg F; // bi - 1
output reg G; // bi
output reg [7:0] Cell; // Output of Adder Goes Here
output reg [7:0] Multi; // Holds Multiplier
output reg [16:0] Product;
always @ (posedge Shift or posedge Load) begin

    if(Reset == 1'b1) begin
    Multi <= 8'b00000000;   // Set Multiplier
    Cell <= 8'b00000000;// Reset Cell
    F <= 1'b0; // Reset F
    G <= 1'b0;    
    
    Product[16] <= 1'b0;
    Product[15:8] <= 8'b00000000;
    Product[7:0]  <= 8'b00000000;
    #5;
    end else if(Load == 1'b1 & Shift == 1'b0)  begin
    Multi <= StartI;   // Set Multiplier
    Cell <= 8'b00000000;// Reset Cell
    F <= 1'b0; // Reset F
    G <= StartI[0];
    #5;
    end else begin
    Cell[6:0] <= I[7:1];
    Cell[7] <= I[7];
    F <= Multi[0];
    G <= Multi[1];
    Multi[6:0] <= Multi[7:1];
    Multi[7] <= I[0];
    
    
    Product[16] <= Cell[7];
    Product[15:8] <= Cell;
    Product[7:0]  <= Multi;
    #5;
    end
    
    
end


endmodule


`timescale 1ns / 1ps


module controlunit(Ready, Load, Operate, Shift, Start, clk, Reset);

input Start;
input clk;
input Reset;

reg [4:0] done; // Counter Used For Indexing and Knowing When Done
reg latch;
reg go;

output reg Ready;
output reg Load;
output reg Operate;
output reg Shift;

always @ (posedge clk) begin

    if(latch !== 1'b1) begin
    done <= 5'b00000;
    end
    if(clk) begin
    latch <= "1";
    end
    
    if(Reset == 1'b1 & go == 1'b1)begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end else if(done >= 5'b01000)begin // Signals that Values have been Flushed
    go <= "1";
   end else if (Ready !== 1'b1) begin           // Flushes Values Of High Impedance Out Of Registers
        if(done[0] == 1'b1) begin
        Shift <= "0";
        Operate <= "0";
        Load <= "1";
        end else begin
        Load <= "0";
        Shift <= "0";
        Operate <= "1";
        end  
        done = done + clk; // Counts How Many Times Loop has Been Done  
        go <= "0";
   end
   
           
    if(Reset == 1'b1 & go == 1'b1)begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end else if (Start == 1'b1 & go == 1'b1 & Ready !== 1'b1) begin // Multiplication Can Begin
        if(done[0] == 1'b1) begin
        Load <= "0";
        Operate <= "0";
        Shift <= "1";
        end else begin  
        Load <= "0";
        Shift <= "0";
        Operate <= "1";
        end  
        done = done + clk; // Counts How Many Times Loop has Been Done        
    end
    
    if(Reset == 1'b1 & go == 1'b1)begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end else if(done >= 5'b11011)begin // Signals that Multiplication is Done
    Ready <= "1";
    end 
    
        
end


endmodule



`timescale 1ns / 1ps

module multiplier(Product, M, N, Reset, Load, Operate, Shift);

input [7:0] M; // Multiplicand
input [7:0] N; // Multiplier

input Reset; // From User

input Load;   // From CU
input Operate;
input Shift;

output [16:0] Product; // Output

wire [7:0] muxout;
wire [7:0] sumout;
wire [7:0] multiout;
wire [7:0] cellout;
wire [16:0] productout;
wire xorout;

wire cout; // Deadwire
wire F; // bi-1
wire G; // bi
wire [7:0] z; // Zeros

assign z = 8'b00000000;
asr17 a(F, G, multiout, cellout, productout, sumout, N, Load, Shift, Reset); // Produces F, G, Cellout and Takes in Sumout, The Multiplier, Start Signal
xorb  x(xorout,F,G); // Chooses for Multiplexer
mux8  m(muxout,z, M, xorout); // Uses Multiplicand, 0000-0000, and xorout
cla8  c(sumout, cout, muxout, cellout, G, Operate); // Produces the Sum, Cout, and Takes in Muxout, Cellout, G as add or Sub

assign Product = productout; 

endmodule



`timescale 1ns / 1ps

module top_multiplier(Product, Ready, N, M, Start, Reset, clk);
input  [7:0]N; // Multiplicand
input  [7:0]M; // Multiplier

input Start;   // User Controlled Values
input Reset;

input clk;     // System Clock

output [16:0]Product; // Output
output Ready;         // Tells When Output Should be Observed

wire Ready, Load, Operate, Shift; // Internal Signals

controlunit cu(Ready, Load, Operate, Shift, Start,clk, Reset);
multiplier mlti(Product, M, N, Reset, Load, Operate, Shift);


endmodule


`timescale 1ns / 1ps


module top_multiplier_tb;

reg [7:0] M; // Multiplicand
reg [7:0] N; // Multiplier
reg Start;
reg Reset; // From User
reg clk;
wire [16:0] Product; // Output
wire Ready;         // Tells When Output Should be Observed

top_multiplier dut(.Product(Product), .Ready(Ready), .M(M), .N(N), .Start(Start), .Reset(Reset), .clk(clk));

initial begin
#0 Reset = 1'b1;
#0 clk = 1'b0;
#1 N = 8'b10011101; // B = -99
#1 M = 8'b01100100; // A = 100

repeat(8) #50 clk = ~clk;
#10 Reset = 1'b0;
#0 Start = 1'b1;             
repeat(60) #50 clk = ~clk;#50 clk = 1'b1;
$finish;
end

endmodule
