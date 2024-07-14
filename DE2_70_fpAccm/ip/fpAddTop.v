module fpAddTop(
    iClk,          // Clock signal
    iRst_n,        // Asynchronous reset (active low)
    
    iDval, 
    iDataA,        // Data input A
    iDataB,        // Data input B

    oErrorflag,
    oRegState,
    oDval,         // Output data valid signal
    oSum           // Output data valid signal
);
parameter WIDTH = 32;
parameter ADDLATENCY = 7;

input                       iClk;          // Clock signal
input                       iRst_n;        // Asynchronous reset (active low)
    
input                       iDval; 

input [WIDTH-1:0]           iDataA;        // Data input A
input [WIDTH-1:0]           iDataB;        // Data input B

output                      oDval;         // Output data valid signal
output  [WIDTH-1:0]         oSum;          // Output data valid signal
output  [ADDLATENCY-1:0]    oRegState;
output                      oErrorflag;

wire    wnan, woverflow, wunderflow, wzero;
reg [ADDLATENCY-1:0] rDly;

always@(posedge iClk or negedge iRst_n) begin
    if(!iRst_n)begin
        rDly <= 0;
    end
    else begin
        rDly <= {rDly[ADDLATENCY-2:0],iDval};
    end
end
assign oDval = rDly[ADDLATENCY-1];
assign oRegState = rDly;
fpadd fpadd(
    .aclr       (~iRst_n),
    .clock      (iClk),
    .dataa      (iDataA),
    .datab      (iDataB),
    .nan        (wnan),
    .overflow   (woverflow),
    .result     (oSum),
    .underflow  (wunderflow),
    .zero       (wzero)
    );

assign oErrorflag = wnan | woverflow | wunderflow;
endmodule
