module brentkung (
    opa,
    opb,
    out,
    ov
);

input  [15:0] opa;
input  [15:0] opb;
output [15:0] out;
output        ov;


//--------------------------------------------------
// Basic Generate / Propagate
//--------------------------------------------------

wire [15:0] gen;
wire [15:0] prop;

assign prop = opa ^ opb;
assign gen  = opa & opb;


//--------------------------------------------------
// Level 1
// 2-bit Generate / Propagate
//--------------------------------------------------

wire g1_1to0;
wire p1_1to0;

wire g1_3to2;
wire p1_3to2;

wire g1_5to4;
wire p1_5to4;

wire g1_7to6;
wire p1_7to6;

wire g1_9to8;
wire p1_9to8;

wire g1_11to10;
wire p1_11to10;

wire g1_13to12;
wire p1_13to12;

wire g1_15to14;
wire p1_15to14;


// Bit 1:0

assign g1_1to0 = gen[1] | (gen[0] & prop[1]);
assign p1_1to0 = prop[1] & prop[0];


// Remaining 2-bit groups

assign {g1_3to2, p1_3to2} =
       gp2(gen[3:2], prop[3:2]);

assign {g1_5to4, p1_5to4} =
       gp2(gen[5:4], prop[5:4]);

assign {g1_7to6, p1_7to6} =
       gp2(gen[7:6], prop[7:6]);

assign {g1_9to8, p1_9to8} =
       gp2(gen[9:8], prop[9:8]);

assign {g1_11to10, p1_11to10} =
       gp2(gen[11:10], prop[11:10]);

assign {g1_13to12, p1_13to12} =
       gp2(gen[13:12], prop[13:12]);

assign {g1_15to14, p1_15to14} =
       gp2(gen[15:14], prop[15:14]);


//--------------------------------------------------
// Level 2
// 4-bit Generate / Propagate
//--------------------------------------------------

wire g2_3to0;
wire p2_3to0;

wire g2_7to4;
wire p2_7to4;

wire g2_11to8;
wire p2_11to8;

wire g2_15to12;
wire p2_15to12;


assign {g2_3to0, p2_3to0} =
       gp2({g1_3to2, g1_1to0},
           {p1_3to2, p1_1to0});

assign {g2_7to4, p2_7to4} =
       gp2({g1_7to6, g1_5to4},
           {p1_7to6, p1_5to4});

assign {g2_11to8, p2_11to8} =
       gp2({g1_11to10, g1_9to8},
           {p1_11to10, p1_9to8});

assign {g2_15to12, p2_15to12} =
       gp2({g1_15to14, g1_13to12},
           {p1_15to14, p1_13to12});


//--------------------------------------------------
// Level 3
// 8-bit Generate / Propagate
//--------------------------------------------------

wire g3_7to0;
wire p3_7to0;

wire g3_15to8;
wire p3_15to8;


assign {g3_7to0, p3_7to0} =
       gp2({g2_7to4, g2_3to0},
           {p2_7to4, p2_3to0});

assign {g3_15to8, p3_15to8} =
       gp2({g2_15to12, g2_11to8},
           {p2_15to12, p2_11to8});


//--------------------------------------------------
// Level 4
// 16-bit Generate
//--------------------------------------------------

wire g4_15to0;

assign g4_15to0 =
       g3_15to8 | (g3_7to0 & p3_15to8);


//--------------------------------------------------
// Remaining Carry Generation
//--------------------------------------------------

wire g_11to0;
wire g_13to0;
wire g_9to0;
wire g_5to0;

wire g_14to0;
wire g_12to0;
wire g_10to0;
wire g_8to0;
wire g_6to0;
wire g_4to0;
wire g_2to0;


// Carry to bit 12

assign g_11to0 =
       g2_11to8 | (g3_7to0 & p2_11to8);


// Carry to bit 14

assign g_13to0 =
       g1_13to12 | (g_11to0 & p1_13to12);


// Carry to bit 10

assign g_9to0 =
       g1_9to8 | (g3_7to0 & p1_9to8);


// Carry to bit 6

assign g_5to0 =
       g1_5to4 | (g2_3to0 & p1_5to4);


// Individual carries

assign g_14to0 =
       gen[14] | (g_13to0 & prop[14]);

assign g_12to0 =
       gen[12] | (g_11to0 & prop[12]);

assign g_10to0 =
       gen[10] | (g_9to0 & prop[10]);

assign g_8to0 =
       gen[8] | (g3_7to0 & prop[8]);

assign g_6to0 =
       gen[6] | (g_5to0 & prop[6]);

assign g_4to0 =
       gen[4] | (g2_3to0 & prop[4]);

assign g_2to0 =
       gen[2] | (g1_1to0 & prop[2]);


//--------------------------------------------------
// Carry vector
//--------------------------------------------------

wire [15:0] g;
wire [15:0] cry;

assign g = {
    g4_15to0,
    g_14to0,
    g_13to0,
    g_12to0,
    g_11to0,
    g_10to0,
    g_9to0,
    g_8to0,
    g3_7to0,
    g_6to0,
    g_5to0,
    g_4to0,
    g2_3to0,
    g_2to0,
    g1_1to0,
    gen[0]
};

assign cry = g << 1'b1;


//--------------------------------------------------
// Sum
//--------------------------------------------------

assign out = opa ^ opb ^ cry;


//--------------------------------------------------
// Carry-out
//--------------------------------------------------

assign ov = g[15];


//--------------------------------------------------
// 2-bit Generate / Propagate Function
//
// Input : {G1,G0} and {P1,P0}
// Output: {G1:0,P1:0}
//
// G = G1 | (P1 & G0)
// P = P1 & P0
//--------------------------------------------------

function [1:0] gp2;

    input [1:0] gen;
    input [1:0] prop;

    begin
        gp2[1] = gen[1] | (prop[1] & gen[0]);
        gp2[0] = prop[1] & prop[0];
    end

endfunction


endmodule