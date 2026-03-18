module traffic_light_fsm (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,

    // Street A lights
    output logic AG,
    output logic AY,
    output logic AR,

    // Street B lights
    output logic BG,
    output logic BY,
    output logic BR
);

    // 5 time units for yellow delay
    localparam int YELLOW_DELAY = 5;
    localparam int TIMER_W      = $clog2(YELLOW_DELAY + 1);

    typedef enum logic [1:0] {
        S0 = 2'b00, // A green,  B red
        S1 = 2'b01, // A yellow, B red
        S2 = 2'b10, // A red,    B green
        S3 = 2'b11  // A red,    B yellow
    } state_t;

    state_t state, next_state;
    logic [TIMER_W-1:0] timer;

    //========================================================
    // 1) State register + timer register
    //========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= '0;
        end
        else begin
            state <= next_state;

            // Entering yellow states: start counter from 1
            if ((state != S1 && next_state == S1) ||
                (state != S3 && next_state == S3)) begin
                timer <= 1;
            end
            // Staying in yellow states: keep counting up to 5
            else if ((state == S1 || state == S3) && (timer < YELLOW_DELAY)) begin
                timer <= timer + 1;
            end
            // Otherwise reset timer
            else begin
                timer <= '0;
            end
        end
    end

    //========================================================
    // 2) Next-state logic
    //========================================================
    always_comb begin
        next_state = state;

        case (state)
            S0: begin
                // Stay while TAORB = 1
                // When ~TAORB = 1, go to yellow for A
                if (TAORB)
                    next_state = S0;
                else
                    next_state = S1;
            end

            S1: begin
                // Hold yellow for 5 clock cycles
                if (timer == YELLOW_DELAY)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2: begin
                // Stay while ~TAORB = 1
                // When TAORB = 1, go to yellow for B
                if (!TAORB)
                    next_state = S2;
                else
                    next_state = S3;
            end

            S3: begin
                // Hold yellow for 5 clock cycles
                if (timer == YELLOW_DELAY)
                    next_state = S0;
                else
                    next_state = S3;
            end

            default: begin
                next_state = S0;
            end
        endcase
    end

    //========================================================
    // 3) Output logic
    //========================================================
    always_comb begin
        // Default all off
        AG = 1'b0; AY = 1'b0; AR = 1'b0;
        BG = 1'b0; BY = 1'b0; BR = 1'b0;

        case (state)
            S0: begin
                AG = 1'b1;
                BR = 1'b1;
            end

            S1: begin
                AY = 1'b1;
                BR = 1'b1;
            end

            S2: begin
                AR = 1'b1;
                BG = 1'b1;
            end

            S3: begin
                AR = 1'b1;
                BY = 1'b1;
            end

            default: begin
                AG = 1'b1;
                BR = 1'b1;
            end
        endcase
    end

endmodule
