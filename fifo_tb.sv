`timescale 1ns/1ps
`include "fifo.sv"
module tb;

    logic clk;
    logic rst;
    logic read_data;
    logic write_data;
    logic [7:0] data_input;
    logic [7:0] data_output;
    logic full; // memory full flag
    logic empty;
    parameter PERIOD = 10;
FIFO DUT (
    .clk(clk),
    .rst (rst),
    .write_data(write_data),
    .read_data(read_data),
    .data_input(data_input),
    .data_output(data_output),
    .full(full),
    .empty(empty)
);

function void show();
$display("%0d  | %b   | %b   | %b  | %b  | %d       | %d        | %b    | %b     | %0d",
                 $time, clk, rst, write_data, read_data, data_input, data_output, full, empty, DUT.counter); // Display initial state
    
endfunction
function void title();
    $display("------------------------------------------------------------------------------------------------------------------");
    $display("Time   | clk | rst | WR | RD | Data In   | Data Out   | Full | Empty | FIFO_Count");
    $display("------------------------------------------------------------------------------------------------------------------");

endfunction

initial begin
    clk = 0;
    forever #(PERIOD/2) clk = ~clk;
end

initial begin
    rst = 1;
    read_data =0;
    write_data =0;
    data_input ='0;
    // Display header for console output
    title();
    @(posedge clk);
    #1;
    show();
    rst = 0; // Release reset
    $display("[%0t] Reset released.", $time);

     // --- Scenario 1: Write multiple items into the FIFO ---
    $display("\n--- Scenario 1: Writing data into FIFO ---");
    title();
    repeat (DUT.DEPTH/2) begin
      @(posedge clk);
      #1;
        write_data =1;
        read_data =0;
        data_input = $urandom_range (255,1);
        show();
    end
    // --- Scenario 2: Read some data from the FIFO ---
    $display("\n--- Scenario 2: Reading data from FIFO ---");
    title();
    repeat (DUT.DEPTH/4) begin
        @(posedge clk);
        #1;
        read_data =1;
        write_data =0;
        data_input = '0;
        show();

    end
    $display("-----Reading data disable-----");
    @(posedge clk);
    #1;
    read_data = 0;
    title();
    show();
    #(PERIOD);
    // --- Scenario 3: Fill the FIFO completely and check 'full' flag ---
    $display("\n--- Scenario 3: Filling FIFO to FULL ---");
    title();
    repeat (DUT.DEPTH +2) begin
        @(posedge clk);
        #1;
        write_data =1;
        read_data =0;
        data_input = $urandom_range (255,1);
        show();
        if (write_data && full) begin
            $display("[%0d] **INFO: FIFO is FULL. Subsequent writes should be ignored by DUT.**", $time);
        end
    end
    $display("-----Writing data disable-----");
    @(posedge clk);
    #1;
    write_data = 0;
    title();
    show();
    #(PERIOD);





    // --- Scenario 4: Empty the FIFO completely and check 'empty' flag ---
    $display("\n--- Scenario 4: Emptying FIFO to EMPTY ---");
    title();
    repeat (DUT.DEPTH +2) begin // read to 2 more
        @(posedge clk);
        #1;
        read_data =1;
        write_data =0;
        data_input = '0;
        show();
        if (read_data && empty) begin
            $display("[%0d] **INFO: FIFO is EMPTY. Subsequent READS should be ignored by DUT.**", $time);
        end

    end

    $display("-----Reading data disable-----");
    @(posedge clk);
    #1;
    read_data = 0;
    title();
    show();
    #(PERIOD*5);// final delay

    $display("[%0d] Testbench: Simulation complete.", $time);
    $finish; // End the simulation

    end


initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end


endmodule