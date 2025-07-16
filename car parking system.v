module CarParkingSystem (
    input clk,                // Clock signal
    input reset,              // Reset signal
    input car_request,        // Signal when a car requests entry
    input car_exit,           // Signal when a car exits
    input [3:0] entered_pass, // Entered password (4 bits for simplicity)
    output reg [3:0] available_spots, // Number of available spots (4 bits for up to 15 spots)
    output reg access_granted // Signal to grant access when the password is correct
);

    parameter TOTAL_SPOTS = 10; // Total number of parking spots
    parameter CORRECT_PASS = 4'b1010; // Correct password (10 in binary)
    
    // State declaration using parameters
    parameter IDLE = 2'b00,
              WAIT_PASS = 2'b01,
              CHECK_PASS = 2'b10,
              GRANT_ACCESS = 2'b11;
              
    reg [1:0] current_state, next_state;

    initial begin
        available_spots = TOTAL_SPOTS;
        current_state = IDLE;
        access_granted = 0;
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            available_spots <= TOTAL_SPOTS;
            access_granted <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic and outputs
    always @(*) begin
        next_state = current_state;
        access_granted = 0;

        case (current_state)
            IDLE: begin
                if (car_request) begin
                    next_state = WAIT_PASS;
                end
            end

            WAIT_PASS: begin
                next_state = CHECK_PASS;
            end

            CHECK_PASS: begin
                if (entered_pass == CORRECT_PASS && available_spots > 0) begin
                    next_state = GRANT_ACCESS;
                end else begin
                    next_state = IDLE;
                end
            end

            GRANT_ACCESS: begin
                access_granted = 1;
                next_state = IDLE;
                if (available_spots > 0) begin
                    available_spots = available_spots - 1; // Decrease available spots
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Car exit logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            available_spots <= TOTAL_SPOTS;
        end else if (car_exit && available_spots < TOTAL_SPOTS) begin
            available_spots <= available_spots + 1; // Increase available spots
        end
    end
endmodule