
module hancarlson (
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
// Adjacent bit pairs
// Odd indices combine with preceding even indices
//--------------------------------------------------

wire [15:0] g1;
wire [15:0] p1;

genvar i;

generate
    for (i = 0; i < 16; i = i + 1) begin : level1

        if ((i % 2) == 1) begin
            assign g1[i] =
                gen[i] | (prop[i] & gen[i-1]);

            assign p1[i] =
                prop[i] & prop[i-1];
        end
        else begin
            assign g1[i] = gen[i];
            assign p1[i] = prop[i];
        end

    end
endgenerate


//--------------------------------------------------
// Level 2
// Prefix distance = 2
// First expanded prefix: bit 3
//--------------------------------------------------

wire [15:0] g2;
wire [15:0] p2;

generate
    for (i = 0; i < 16; i = i + 1) begin : level2

        if ((i >= 3) && ((i % 2) == 1)) begin
            assign g2[i] =
                g1[i] | (p1[i] & g1[i-2]);

            assign p2[i] =
                p1[i] & p1[i-2];
        end
        else begin
            assign g2[i] = g1[i];
            assign p2[i] = p1[i];
        end

    end
endgenerate


//--------------------------------------------------
// Level 3
// Prefix distance = 4
// First expanded prefix: bit 5
//--------------------------------------------------

wire [15:0] g3;
wire [15:0] p3;

generate
    for (i = 0; i < 16; i = i + 1) begin : level3

        if ((i >= 5) && ((i % 2) == 1)) begin
            assign g3[i] =
                g2[i] | (p2[i] & g2[i-4]);

            assign p3[i] =
                p2[i] & p2[i-4];
        end
        else begin
            assign g3[i] = g2[i];
            assign p3[i] = p2[i];
        end

    end
endgenerate


//--------------------------------------------------
// Level 4
// Prefix distance = 8
// First expanded prefix: bit 9
//--------------------------------------------------

wire [15:0] g4;
wire [15:0] p4;

generate
    for (i = 0; i < 16; i = i + 1) begin : level4

        if ((i >= 9) && ((i % 2) == 1)) begin
            assign g4[i] =
                g3[i] | (p3[i] & g3[i-8]);

            assign p4[i] =
                p3[i] & p3[i-8];
        end
        else begin
            assign g4[i] = g3[i];
            assign p4[i] = p3[i];
        end

    end
endgenerate


//--------------------------------------------------
// Final Carry Generation
// Odd indices: prefix carries
// Even indices: combine bit with preceding prefix
//--------------------------------------------------

wire [15:0] g;
wire [15:0] cry;

assign g[0] = gen[0];

generate
    for (i = 1; i < 16; i = i + 1) begin : carry_gen

        if ((i % 2) == 1) begin
            assign g[i] = g4[i];
        end
        else begin
            assign g[i] =
                gen[i] | (prop[i] & g4[i-1]);
        end

    end
endgenerate


//--------------------------------------------------
// Carry Vector
// cry[i] = carry into bit i
//--------------------------------------------------

assign cry = {g[14:0], 1'b0};


//--------------------------------------------------
// Sum
//--------------------------------------------------

assign out = prop ^ cry;


//--------------------------------------------------
// Carry-out
//--------------------------------------------------

assign ov = g[15];


endmodule