// Module Name: fpMux
// Description: This module implements a floating-point multiplexer that selects between two input data streams
//              based on their valid signals and outputs the selected data along with a state signal.
// Parameters:
//   WIDTH - The bit width of the input and output data signals (default is 32).

module fpMux4Reg(
    iClk,          // Clock signal
    iRst_n,        // Asynchronous reset (active low)
    
    iDvalA,        // Data valid signal for input A
    iDataA,        // Data input A
    
    iDvalB,        // Data valid signal for input B
    iDataB,        // Data input B
    
    oDval,         // Output data valid signal
    oDataA,        // Output data A
    oDataB,        // Output data B
    oState         // Output state signal
);

parameter WIDTH = 32;               // Parameter for data width

input               iClk;           // Clock signal
input               iRst_n;         // Asynchronous reset (active low)
        
input               iDvalA;         // Data valid signal for input A
input [WIDTH-1:0]   iDataA;         // Data input A

input               iDvalB;         // Data valid signal for input B
input [WIDTH-1:0]   iDataB;         // Data input B

output reg          oDval;          // Output data valid signal
output reg [WIDTH-1:0] oDataA;      // Output data A
output reg [WIDTH-1:0] oDataB;      // Output data B
output  [3:0]          oState;         // Output state signal

reg [3:0] rState;                   // Internal state register
reg [WIDTH-1:0] rTmpDataA[1:0], rTmpDataB[1:0]; // Temporary registers for input data A and B

// Always block triggered on the positive edge of the clock or the negative edge of the reset signal
always @(posedge iClk or negedge iRst_n) begin
    if (!iRst_n) begin  // If reset is active (low)
        rState <= 4'b0000;  // Reset state
        rTmpDataA[0] <= 0;  // Reset temporary data A0
        rTmpDataA[1] <= 0;  // Reset temporary data A1
        rTmpDataB[0] <= 0;  // Reset temporary data B0
        rTmpDataB[1] <= 0;  // Reset temporary data B1
        oDataA <= 0;        // Reset output data A
        oDataB <= 0;        // Reset output data B
        oDval <= 0;         // Reset output data valid
    end else begin  // If not in reset state
        rState <= rState;  // Reset state
        rTmpDataA[0] <= rTmpDataA[0];  // Reset temporary data A0
        rTmpDataA[1] <= rTmpDataA[1];  // Reset temporary data A1
        rTmpDataB[0] <= rTmpDataB[0];  // Reset temporary data B0
        rTmpDataB[1] <= rTmpDataB[1];  // Reset temporary data B1
        oDataA <= oDataA;        // Reset output data A
        oDataB <= oDataB;        // Reset output data B
        oDval <= oDval;         // Reset output data valid
        case ({iDvalB, iDvalA})  // Combine valid signals to form a control signal
            2'b00: begin  // Both inputs are invalid
                oDval <= 1;  // Set output data valid signal
                case(rState)  // Check the current state
                    4'b0000: begin  // Initial state
                        rState <= 4'b0000;  // Remain in initial state
                        rTmpDataA[0] <= 0;  // Clear temporary data A[0]
                        rTmpDataA[1] <= 0;  // Clear temporary data A[1]
                        rTmpDataB[0] <= 0;  // Clear temporary data B[0]
                        rTmpDataB[1] <= 0;  // Clear temporary data B[1]
                        oDataA <= 0;  // Clear output data A
                        oDataB <= 0;  // Clear output data B
                        oDval <= 0;  // Clear output data valid signal
                    end 
                    4'b0001, 4'b0010, 4'b0100, 4'b1000: begin  // Intermediate states
                        rState <= rState;  // Remain in the current state
                        oDval <= 0;  // Clear output data valid signal
                    end 
                    4'b0011: begin  // State 3
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataA[1];  // Set output data B from temporary data A[1]
                    end
                    4'b0101: begin  // State 5
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end 
                    4'b0110: begin  // State 6 - OK
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataA[1];  // Set output data A from temporary data A[1]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                        oDval <= 1;  // Set output data valid signal
                    end 
                    4'b0111: begin  // State 7 - OK
                        rState <= 4'b0010;  // Move to state 2
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end
                    4'b1001: begin  // State 9 - OK
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataB[1];  // Set output data B from temporary data B[1]
                    end 
                    4'b1010: begin  // State 10 - OK
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataA[1];  // Set output data A from temporary data A[1]
                        oDataB <= rTmpDataB[1];  // Set output data B from temporary data B[1]
                    end 
                    4'b1011: begin  // State 11 - OK
                        rState <= 4'b0010;  // Move to state 2
                        oDataA <= rTmpDataB[0];  // Set output data A from temporary data B[0]
                        oDataB <= rTmpDataB[1];  // Set output data B from temporary data B[1]
                    end
                    4'b1100: begin  // State 12 - OK
                        rState <= 4'b0000;  // Reset to initial state
                        oDataA <= rTmpDataB[1];  // Set output data A from temporary data B[1]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end 
                    4'b1101: begin  // State 13 - OK
                        rState <= 4'b1000;  // Move to state 8
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end 
                    4'b1110: begin  // State 14 - OK
                        rState <= 4'b1000;  // Move to state 8
                        oDataA <= rTmpDataA[1];  // Set output data A from temporary data A[1]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end 
                    4'b1111: begin  // State 15 - OK
                        rState <= 4'b1010;  // Move to state 10
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary data A[0]
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary data B[0]
                    end
                endcase
            end

            2'b01: begin  // Only input A is valid
                oDval <= 1;  // Set output data valid signal
                case(rState)  // Check the current state
                    4'b0000: begin 
                        rState <= 4'b0001;  // Move to state 1
                        rTmpDataA[0] <= iDataA;  // Store input data A in temporary register
                        oDataA <= 0;  // Clear output data A
                        oDataB <= 0;  // Clear output data B
                        oDval <= 0;  // Clear output data valid signal
                    end 
                    4'b0001: begin 
                        rState <= 4'b0000;  // Reset to state 0
                        oDataA <= rTmpDataA[0];  // Set output data A from temporary register
                        oDataB <= iDataA;  // Set output data B from input data A
                    end 
                    4'b0010: begin 
                        rState <= 4'b0000;  // Reset to state 0
                        oDataA <= rTmpDataA[1];  // Set output data A from temporary register
                        oDataB <= iDataA;  // Set output data B from input data A
                    end 
                    4'b0011: begin 
                        rState <= 4'b0001;  // Move to state 1
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataA[1];  // Set output data B from temporary register
                    end
                    4'b0100: begin 
                        rState <= 4'b0000;  // Reset to state 0
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b0101: begin 
                        rState <= 4'b0001;  // Move to state 1
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b0110: begin  // OK
                        rState <= 4'b0010;  // Move to state 2
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b0111: begin // OK
                        rState <= 4'b0011;  // Move to state 3
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end
                    4'b1000: begin // OK
                        rState <= 4'b0000;  // Reset to state 0
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[1];  // Set output data B from temporary register
                    end 
                    4'b1001: begin // OK
                        rState <= 4'b0001;  // Move to state 1
                        oDataA <= rTmpDataB[1];  // Set output data A from temporary register
                        oDataB <= iDataA;  // Set output data B from input data A
                    end 
                    4'b1010: begin // OK
                        rState <= 4'b0010;  // Move to state 2
                        oDataA <= rTmpDataB[1];  // Set output data A from temporary register
                        oDataB <= iDataA;  // Set output data B from input data A
                    end 
                    4'b1011: begin // OK
                        rState <= 4'b0011;  // Move to state 3
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[1];  // Set output data B from temporary register
                    end
                    4'b1100: begin // OK
                        rState <= 4'b1000;  // Move to state 8
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b1101: begin // OK
                        rState <= 4'b1001;  // Move to state 9
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b1110: begin  // OK
                        rState <= 4'b1010;  // Move to state 10
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end 
                    4'b1111: begin // OK
                        rState <= 4'b1011;  // Move to state 11
                        oDataA <= iDataA;  // Set output data A from input data A
                        oDataB <= rTmpDataB[0];  // Set output data B from temporary register
                    end
                endcase
            end

            2'b10: begin
                oDval <= 1;
                case(rState)
                    4'b0000: begin 
                            rState <= 4'b0100;
                            rTmpDataB[0] <= iDataB;
                            oDataA <= 0; 
                            oDataB <= 0;
                            oDval <= 0;
                        end 
                    4'b0001: begin 
                            rState <= 4'b0000;
                            oDataA <= rTmpDataA[0]; 
                            oDataB <= iDataB;
                        end 
                    4'b0010:begin 
                            rState <= 4'b0000;
                            oDataA <= rTmpDataA[1]; 
                            oDataB <= iDataB;
                        end 
                    4'b0011:begin 
                            rState <= 4'b0001;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[1];
                        end
                    4'b0100: begin 
                            rState <= 4'b0000;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataB[0];
                        end 
                    4'b0101: begin 
                            rState <= 4'b0100;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[0];
                        end 
                    4'b0110:begin  // OK
                            rState <= 4'b0100;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[1];
                        end 
                    4'b0111:begin // OK
                            rState <= 4'b0110;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[0];
                        end
                    4'b1000: begin //OK
                            rState <= 4'b0000;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataB[1];
                        end 
                    4'b1001: begin //OK
                            rState <= 4'b1000;
                            oDataA <= rTmpDataA[0]; 
                            oDataB <= iDataB;
                        end 
                    4'b1010:begin //OK
                            rState <= 4'b1000;
                            oDataA <= rTmpDataA[1]; 
                            oDataB <= iDataB;
                        end 
                    4'b1011:begin //OK
                            rState <= 4'b0010;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[0];
                        end
                    4'b1100: begin //OK
                            rState <= 4'b1000;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataB[0];
                        end 
                    4'b1101: begin //OK
                            rState <= 4'b1001;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataB[0];
                        end 
                    4'b1110:begin  // OK
                            rState <= 4'b1010;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataB[0];
                        end 
                    4'b1111:begin // OK
                            rState <= 4'b1110;
                            oDataA <= iDataB; 
                            oDataB <= rTmpDataA[0];
                        end
                endcase
            end
            2'b11: begin
                oDval <= 1;
                rState <= rState;
                oDataA <= iDataA; 
                oDataB <= iDataB;
            end
        endcase
    end
end

assign oState = rState;

endmodule
