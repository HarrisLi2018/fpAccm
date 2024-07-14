// Module Name: fpMux
// Description: 本模組實現將乘法器輸出的單比資料，轉換兩筆資料後輸出給後端加法器使用.
// Parameters:
//   WIDTH - The bit width of the input and output data signals (default is 32).

module fpMux(
    iClk,          // Clock signal
    iRst_n,        // Asynchronous reset (active low)
    
    iDvalA,        // Data valid signal for input A
    iDataA,        // Data input A
    
    iDvalB,        // Data valid signal for input B
    iDataB,        // Data input B
    
    oDval,         // Output data valid signal
    oDataA,        // Output data A
    oDataB,        // Output data B
    oRegState          
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
output              oRegState;         // Output state signal

reg                 rRegState;                   // Internal state register
reg [WIDTH-1:0]     rTmpData; // Temporary registers for input data A and B

// Always block triggered on the positive edge of the clock or the negative edge of the reset signal
always @(posedge iClk or negedge iRst_n) begin
    if (!iRst_n) begin  // If reset is active (low)
        rRegState <= 0;  // Reset state
        rTmpData <= 0;  // Reset temporary data A0
        oDataA <= 0;        // Reset output data A
        oDataB <= 0;        // Reset output data B
        oDval <= 0;         // Reset output data valid
    end else begin  // If not in reset state
        rRegState <= rRegState;  // Reset state
        rTmpData <= rTmpData;
        oDataA <= 0;        // Reset output data A
        oDataB <= 0;        // Reset output data B
        oDval <= 0;         // Reset output data valid
        case ({rRegState, iDvalB, iDvalA})  // Combine valid signals to form a control signal
            3'b000, 3'b100: begin /* hold value*/
                        rRegState <= rRegState;  // Reset state
                        oDataA <= 0;        // Reset output data A
                        oDataB <= 0;        // Reset output data B
                        oDval <= 0;         // Reset output data valid
                end
            3'b001: begin
                        rRegState <= 1;  // Reset state
                        rTmpData <= iDataA;
                end
            3'b010: begin
                        rRegState <= 1;  // Reset state
                        rTmpData <= iDataB;
                end
            3'b011: begin
                        oDataA <= iDataA;        // Reset output data A
                        oDataB <= iDataB;        // Reset output data B
                        oDval <= 1;         // Reset output data valid
                end
            3'b101: begin
                        rRegState <= 0;  // Reset state
                        oDataA <= iDataA;        // Reset output data A
                        oDataB <= rTmpData;        // Reset output data B
                        oDval <= 1;         // Reset output data valid
                end
            3'b110: begin
                        rRegState <= 0;  // Reset state
                        oDataA <= iDataB;        // Reset output data A
                        oDataB <= rTmpData;        // Reset output data B
                        oDval <= 1;         // Reset output data valid
                end
            3'b111: begin
                        rRegState <= rRegState;  // Reset state
                        oDataA <= iDataA;        // Reset output data A
                        oDataB <= iDataB;        // Reset output data B
                        oDval <= 1;         // Reset output data valid
                end
        endcase
    end
end

assign oRegState = rRegState;

endmodule
