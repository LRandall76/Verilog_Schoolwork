`timescale 1ns / 1ps

module test;
wire Co;
wire [3:0]S;
reg [3:0] A;
reg [3:0] B;
reg Ci;

CLA4 dut (.Co(Co),.S(S),.A(A),.B(B),.Ci(Ci));


	initial begin
	#0    A=4'b1010;
	#0    B=4'b0010;
	#0    Ci=1'b0;
	#40   A=4'b1010;
	#40   B=4'b0111;
	#80   A=4'b1111;
	#80   B=4'b1111;
	
	
	#160 $finish;
	end

endmodule

`timescale 1ns / 1ps

module CLA4(Co,S, A, B, Ci);
output Co;
output [3:0] S;
input [3:0] A;
input [3:0] B;
input Ci; // 0
wire [3:0] Carries;
wire [3:0] gene, prop; // Used in CLA
wire [3:0] Xprop,Yprop; // To Find Prop

// For Carry Circuits
wire C1; 
wire [1:0] C2;
wire [2:0] C3;
wire [3:0] C4;

// Useless Store
wire [3:0] junk;
FA a(S[0],junk[0],A[0],B[0],Ci);
FA b(S[1],junk[1],A[1],B[1],Carries[0]);
FA c(S[2],junk[2],A[2],B[2],Carries[1]);
FA d(S[3],junk[3],A[3],B[3],Carries[3]);


// This Section Could be Replaced by Half Adders but It Helped to See the Variables
// Generate
and  #2(gene[0],A[0],B[0]);
and  #2(gene[1],A[1],B[1]);
and  #2(gene[2],A[2],B[2]);
and  #2(gene[3],A[3],B[3]);

// Propogate Basically a XOR gate
nand #2(Xprop[0],A[0],B[0]);
or   #2(Yprop[0],A[0],B[0]);
and  #2(prop[0],Xprop[0],Yprop[0]);

nand #2(Xprop[1],A[1],B[1]);
or   #2(Yprop[1],A[1],B[1]);
and  #2(prop[1],Xprop[1],Yprop[1]);

nand #2(Xprop[2],A[2],B[2]);
or   #2(Yprop[2],A[2],B[2]);
and  #2(prop[2],Xprop[2],Yprop[2]);

nand #2(Xprop[3],A[3],B[3]);
or   #2(Yprop[3],A[3],B[3]);
and  #2(prop[3],Xprop[3],Yprop[3]);

// CLA Unit
// C1
and #2(C1,prop[0],Ci);
or  #2(Carries[0],C1,gene[0]);

// C2
and #2(C2[0],prop[1],prop[0],Ci);
and #2(C2[1],prop[1],gene[0]);
or  #2(Carries[1],gene[1],C2[1],C2[0]);

// C3
and #2(C3[0],prop[2],prop[1],prop[0],Ci);
and #2(C3[1],prop[2],prop[1],gene[0]);
and #2(C3[2],prop[2],gene[1]);
or  #2(Carries[2],gene[2],C3[2],C3[1],C3[0]);

// C4
and #2(C4[0],prop[3],prop[2],prop[1],prop[0],Ci);
and #2(C4[1],prop[3],prop[2],prop[1],gene[0]);
and #2(C4[2],prop[3],prop[2],gene[1]);
and #2(C4[3],prop[3],gene[2]);
or  #2(Carries[3],gene[3],C4[3],C4[2],C4[1],C4[0]);

assign Co = Carries[3];

endmodule

`timescale 1ns / 1ps

module FA(Fsum, Cout,U,V,Cin);

output Cout;
output Fsum;
input  Cin;
input  U;
input  V;
wire X,Y,Z;

HA a(X,Y,U,V);
HA b(Fsum,Z,Cin,X);

or #1 (Cout,Z,Y);

endmodule

`timescale 1ns / 1ps


module HA(Sum, Carry, P, Q);

output Sum, Carry;
input P, Q;



and #4(Carry, P, Q);
xor #5(Sum, P, Q);



endmodule
