module testbench(
        iClk,
        iRst_n,
        
        oDval,
        ofpData,
        oDataNum,
        oSysRst_n,
        
        iDone
);

parameter CLKFREQ = 2500_0000;

input           iClk;
input           iRst_n;
        
output  reg     oDval;
output  [31:0]  ofpData;
output  reg [15:0]  oDataNum;
output  reg         oSysRst_n;
input iDone;

reg [31:0]  rDataA;
reg [7:0]   rCnt;

reg [3:0]   rState;

reg [31:0] rClkCnt;

always@(posedge iClk or negedge iRst_n) begin
    if(!iRst_n) begin
        rCnt <= 0;
        rDataA <= 32'h3E80_0000;
        oDval <= 0;
        oDataNum <= 0;
        rState <= 0;
        rClkCnt <= 0;
        oSysRst_n <= 1;
    end else begin
        rCnt <= rCnt;
        rDataA <= rDataA;
        oDval <= oDval;
        oDataNum <= oDataNum;
        rState <= rState;
        oSysRst_n <= oSysRst_n;
        case(rState)
            0: begin /* wait 5sec to start*/
                oSysRst_n <= 0;
                if(rClkCnt<=CLKFREQ) begin
                    rClkCnt <= rClkCnt + 1;
                end
                else begin
                    rClkCnt <= 0;
                    if(rCnt >=5) begin
                        rState <= rState+1;
                        rCnt <= 0;
                        oSysRst_n <= 1;
                    end else begin
                        rCnt <= rCnt + 1;
                    end
                end
            end
            1: begin
                if(rCnt < 10) begin
                    rCnt <= rCnt + 1;
                    rDataA <= rDataA + 32'h80_0000;
                    oDval <= 1;
                    oDataNum <= 10;
                end else begin
                    if(iDone) begin
                        rState <= rState+1;
                        rCnt <= 0;
                    end
                    rDataA <= 32'h3E80_0000;
                    oDval <= 0;
                    oDataNum <= oDataNum;
                end
            end
            2: begin
                if(rCnt < 5) begin
                    rCnt <= rCnt + 1;
                    rDataA <= rDataA + 32'h80_0000;
                    oDval <= 1;
                    oDataNum <= 3;
                end else begin
                    if(iDone) begin
                            rState <= rState+1;
                            rCnt <= 0;
                        end
                        rDataA <= 32'h3E80_0000;
                        oDval <= 0;
                        oDataNum <= oDataNum;
                    end
                end
            3: begin
                if(rCnt < 5) begin
                    oSysRst_n <= 0;
                    rCnt <= rCnt +1;
                end else begin
                    oSysRst_n <= 1;
                    rState <= rState +1;
                    rCnt <= 0;
                    rDataA <= 32'h3E80_0000;
                    oDval <= 0;
                    oDataNum <= oDataNum;
                end
            end
            4: begin
                if(rCnt < 1) begin
                    oDataNum <= 0;
                    oDval <= 1;
                    rDataA <= 32'h3E80_0000;
                    rCnt <= rCnt +1;
                end else begin
                    rState <= rState +1;
                    rCnt <= 0;
                    oDval <= 0;
                end
            end
            5: begin
            
            
            end
        endcase
    end
end

assign ofpData = rDataA;

endmodule
