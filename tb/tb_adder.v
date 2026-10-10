
`timescale 1ns/1ps

module tb_adder;

    //--------------------------------------------------
    // Inputs
    //--------------------------------------------------

    reg [15:0] opa;
    reg [15:0] opb;

    //--------------------------------------------------
    // Brent-Kung outputs
    //--------------------------------------------------

    wire [15:0] bk_out;
    wire        bk_ov;

    //--------------------------------------------------
    // Kogge-Stone outputs
    //--------------------------------------------------

    wire [15:0] ks_out;
    wire        ks_ov;

    //--------------------------------------------------
    // Han-Carlson outputs
    //--------------------------------------------------

    wire [15:0] hc_out;
    wire        hc_ov;

    //--------------------------------------------------
    // Reference result and counters
    //--------------------------------------------------

    reg [16:0] expected;

    integer i;
    integer tests;
    integer failures;

    //--------------------------------------------------
    // DUT instantiations
    //--------------------------------------------------

    brentkung u_bk (
        .opa (opa),
        .opb (opb),
        .out (bk_out),
        .ov  (bk_ov)
    );

    koggestone u_ks (
        .opa (opa),
        .opb (opb),
        .out (ks_out),
        .ov  (ks_ov)
    );

    hancarlson u_hc (
        .opa (opa),
        .opb (opb),
        .out (hc_out),
        .ov  (hc_ov)
    );

    //--------------------------------------------------
    // Self-checking task
    //--------------------------------------------------

    task check_adders;

        input [15:0] a;
        input [15:0] b;

        begin

            opa = a;
            opb = b;

            // Allow combinational logic to settle
            #1;

            expected = {1'b0, a} + {1'b0, b};

            tests = tests + 1;

            // Brent-Kung check
            if ({bk_ov, bk_out} !== expected) begin
                failures = failures + 1;

                $display(
                    "FAIL Brent-Kung: A=%h B=%h Got=%h Expected=%h",
                    a, b, {bk_ov, bk_out}, expected
                );
            end

            // Kogge-Stone check
            if ({ks_ov, ks_out} !== expected) begin
                failures = failures + 1;

                $display(
                    "FAIL Kogge-Stone: A=%h B=%h Got=%h Expected=%h",
                    a, b, {ks_ov, ks_out}, expected
                );
            end

            // Han-Carlson check
            if ({hc_ov, hc_out} !== expected) begin
                failures = failures + 1;

                $display(
                    "FAIL Han-Carlson: A=%h B=%h Got=%h Expected=%h",
                    a, b, {hc_ov, hc_out}, expected
                );
            end

        end

    endtask

    //--------------------------------------------------
    // Test sequence
    //--------------------------------------------------

    initial begin

        tests    = 0;
        failures = 0;

        $display("----------------------------------------");
        $display("Testing 16-bit parallel-prefix adders");
        $display("----------------------------------------");

        //--------------------------------------------------
        // Directed test cases
        //--------------------------------------------------

        $display("Running directed tests...");

        check_adders(16'h0000, 16'h0000);
        check_adders(16'h0000, 16'h0001);
        check_adders(16'h0001, 16'h0001);

        // Carry propagation
        check_adders(16'h000F, 16'h0001);
        check_adders(16'h00FF, 16'h0001);
        check_adders(16'h0FFF, 16'h0001);
        check_adders(16'h7FFF, 16'h0001);

        // Carry-out cases
        check_adders(16'hFFFF, 16'h0001);
        check_adders(16'hFFFF, 16'hFFFF);
        check_adders(16'h8000, 16'h8000);
        check_adders(16'hFFFF, 16'h0000);

        // Alternating bit patterns
        check_adders(16'hAAAA, 16'h5555);
        check_adders(16'h5555, 16'hAAAA);
        check_adders(16'hAAAA, 16'hAAAA);
        check_adders(16'h5555, 16'h5555);

        // Additional patterns
        check_adders(16'h1234, 16'h5678);
        check_adders(16'hFEDC, 16'hBA98);
        check_adders(16'h00FF, 16'hFF00);
        check_adders(16'h0101, 16'h0101);

        //--------------------------------------------------
        // Randomized tests
        //--------------------------------------------------

        $display("Running 100000 randomized tests...");

        for (i = 0; i < 100000; i = i + 1) begin

            check_adders($random, $random);

        end

        //--------------------------------------------------
        // Summary
        //--------------------------------------------------

        $display("----------------------------------------");
        $display("Total input pairs : %0d", tests);
        $display("Total failures    : %0d", failures);

        if (failures == 0) begin
            $display("RESULT: ALL ADDERS PASSED");
        end
        else begin
            $display("RESULT: TEST FAILED");
        end

        $display("----------------------------------------");

        $finish;

    end

endmodule
