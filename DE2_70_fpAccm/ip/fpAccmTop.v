/*
本模組是浮點數乘加器，做浮點數相加
1.reset後在第一次iDval進來前，iDataNum都能修改，
2.再計算累加值時需注意iDataNum需保持不變，直到oDone訊號起來後，才能修改iDataNum值，此時會再重新計算累加值，





*/

module fpAccmTop(
        iClk,    /* sync clock */
        iRst_n,  /* async reset_n */
        
        iDataNum,/* Total data number to accumlate */
        iDval,   /* input data valid */
        ifpData, /* input float data */
        

        oDval,   /* output data valid */
        ofpAccmResult, /* output data */
        oError,
        oDone,  /* when done is set to 1, the fpAccmTop is need to reset */
        
        /* for debug */
        oErrInpuGTNum, /* input data number > DataNum */

);

parameter ADDLATENCY = 7;

input           iClk;
input           iRst_n;

input   [15:0]  iDataNum;/* 0~65535 */
input           iDval;
input   [31:0]  ifpData;

output reg         oDval;
output reg [31:0]  ofpAccmResult;
output reg         oDone;
output reg         oErrInpuGTNum;

output            oError;

wire            wfpMuxDval;
wire    [31:0]  wfpMuxDataA, wfpMuxDataB;

reg             rFinal;
reg [15:0]      rDataNumCnt;

reg             rDlyInDval;
reg [31:0]      rDlyInfpData;

reg             rPipelineDval;
reg [31:0]      rPipelineData;
reg [15:0]      rDataNum;

always@(posedge iClk or negedge iRst_n)begin
    if(!iRst_n)begin
        rPipelineDval <= 0;
        rPipelineData <= 0;
    end else begin
        rPipelineDval <= iDval;
        rPipelineData <= ifpData;
        if (iDval) begin
            if(ifpData == 0) begin
                rPipelineDval <= 0;
            end else begin
                rPipelineDval <= 1;
            end
        end else begin
            rPipelineDval <= 0;
            rPipelineData <= 0;
        end
    end
end

always@(posedge iClk or negedge iRst_n)begin
    if(!iRst_n)begin
        rFinal <= 0;
        rDataNumCnt <= 0;
        oErrInpuGTNum <= 0;
    end else begin
        oErrInpuGTNum <= oErrInpuGTNum;
        rFinal <= rFinal;
        rDataNumCnt <= rDataNumCnt;
        if(rPipelineDval)begin
            rDataNum <= iDataNum-1;
            if(iDataNum == 0) begin
                oErrInpuGTNum <= 1;
                rFinal <= 0;
                rDataNumCnt <= 0;
            end else if(rDataNumCnt >= iDataNum-1) begin
                rFinal <= 1;
                rDataNumCnt <= rDataNumCnt;
            end else begin
                rFinal <= 0;
                rDataNumCnt <= rDataNumCnt +1;
            end
            
            if(rFinal) begin
                oErrInpuGTNum <= 1;
            end else if(rDataNum == 0) begin
                oErrInpuGTNum <= 1;
            end else if(rDataNumCnt >= rDataNum-1) begin
                oErrInpuGTNum <= 0;
            end
        end else if(oDone) begin
            rFinal <= 0;
            rDataNumCnt <= 0;
        end
    end
end
wire            wDval;
wire    [31:0]  wData;
assign wDval = rFinal? 0 : rPipelineDval;
assign wData = rFinal? 0 : rPipelineData;

wire        wfpMuxRegState;

fpMux fpMux(
    .iClk   (iClk),          // Clock signal
    .iRst_n (iRst_n& ~oDone),        // Asynchronous reset (active low)
    
    .iDvalA (wDval),        // Data valid signal for input A
    .iDataA (wData),        // Data input A
    
    .iDvalB (wfpAddTopDval),        // Data valid signal for input B
    .iDataB (wfpAddoSum),        // Data input B
    
    .oDval  (wfpMuxDval),         // Output data valid signal
    .oDataA (wfpMuxDataA),        // Output data A
    .oDataB (wfpMuxDataB),        // Output data B
    .oRegState(wfpMuxRegState)          
);

wire                        wfpAddTopDval;
wire    [31:0]              wfpAddoSum;
wire    [ADDLATENCY-1:0]    wfpAddRegState;

fpAddTop fpAddTop(
    .iClk   (iClk),          // Clock signal
    .iRst_n (iRst_n ),        // Asynchronous reset (active low)
    
    .iDval  (wfpMuxDval), 
    .iDataA (wfpMuxDataA),        // Data input A
    .iDataB (wfpMuxDataB),        // Data input B

    .oErrorflag (wfpAddError),
    .oRegState  (wfpAddRegState),
    .oDval      (wfpAddTopDval),       // Output data valid signal
    .oSum       (wfpAddoSum)           // Output data valid signal
);
wire        wfpAddError;
assign oError = wfpAddError | oErrInpuGTNum;

always@(posedge iClk or negedge iRst_n)begin
    if(!iRst_n)begin
        oDval <= 0;
        ofpAccmResult <= 0;
        oDone <= 0;
    end else begin
        oDval <= 0;
        ofpAccmResult <= 0;
        oDone <= 0;
        if(oDone)begin
            oDval <= 0;
            ofpAccmResult <= 0;
            oDone <= 0;
        end else if(iDval && (iDataNum <= 1))begin /* iDataNum <= 1*/
            oDval <= 1;
            ofpAccmResult <= ifpData;
            oDone <= 1;
        end else if(rFinal && (!wfpAddRegState)&&(wfpMuxRegState))begin
            oDval <= rDlyDval;
            ofpAccmResult <= rDlyResult;
            oDone <= 1;
        end
    end
end

reg    [31:0]   rDlyResult;
reg             rDlyDval;
always@(posedge iClk or negedge iRst_n)begin
    if(!iRst_n)begin
        rDlyResult <= 0;
        rDlyDval <= 0;
    end else begin
        rDlyResult <= wfpAddoSum;
        rDlyDval <= wfpAddTopDval;
    end
end


endmodule
