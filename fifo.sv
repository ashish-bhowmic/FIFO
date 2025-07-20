module FIFO (
    input logic clk,
    input logic rst,
    input logic read_data,
    input logic write_data,
    input logic [7:0] data_input,
    output logic [7:0] data_output,
    output logic full, // memory full flag
    output logic empty // memory empty flag
);

parameter DEPTH = 16;
parameter add_ptr = ($clog2(DEPTH));
reg [7:0] mem [0:DEPTH-1]; // location start from 0 and end 15, each locations are capable to store 8 bit
reg [add_ptr-1: 0]read_ptr;
reg [add_ptr-1: 0]write_ptr;
reg [DEPTH :0] counter; // counter to count 0 to 16. One bit more to write at 15th location.

// combination logic for flag update;
assign full = (counter == DEPTH);
assign empty = (counter == 0);

//sequencial block

always_ff @( posedge clk ) begin 
    if (rst) begin
        for (int i =0 ;i<DEPTH;i++ ) begin
            mem[i] <= 0;
        end
        read_ptr <= 0;
        write_ptr <= 0;
        counter <= 0;
        data_output <= 0;
    end else begin
        if (write_data && !full) begin
            mem[write_ptr] <= data_input;
            write_ptr <= write_ptr +1;
            counter <= counter+1;
        end else if (read_data && !empty) begin
            data_output <= mem[read_ptr];
            read_ptr <= read_ptr + 1;
            counter <= counter -1;
        end
    end
end
    
endmodule