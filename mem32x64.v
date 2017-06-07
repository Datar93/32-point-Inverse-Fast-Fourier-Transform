//
// This is a simple memory model for the lcd controller
//
// This memory is a 32x64 that will be used for a single FIFO
//


module mem32x64(input clk,input [4:0] waddr, 
    input [36:0] wdata, input write,
    input [4:0] raddr1,input [4:0] raddr2, output [36:0] rdata1,output [36:0] rdata2);


reg [36:0] mem[0:31];
    
reg [36:0] rdatax1,rdatax2;

wire [36:0] w0,w1,w2,w3,w4,w5,w6,w7;
assign w0=mem[0];
assign w1=mem[1];
assign w2=mem[2];
assign w3=mem[31];
assign w4 =mem[16];
assign rdata1 = rdatax1;
assign rdata2 = rdatax2;

always @(*) begin
  rdatax1 <= mem[raddr1];
  rdatax2 <= mem[raddr2];
end

always @(posedge(clk)) begin
  if(write) begin
    mem[waddr]<= wdata;
  end
end

endmodule
module mem32x64_DP (input clk,input [4:0] waddr1,input [4:0] waddr2,  
    input [36:0] wdata1,input [36:0] wdata2, input write,
    input [4:0] raddr1,input [4:0] raddr2, output [36:0] rdata1,output [36:0] rdata2);
    
reg [36:0] mem[0:31];
    
reg [36:0] rdatax1,rdatax2;

wire [36:0] w0,w1,w2,w3,w4,w5,w6,w7;
assign w0=mem[0];
assign w1=mem[1];
assign w2=mem[2];
assign w3=mem[31];
assign w4 =mem[16];
assign rdata1 = rdatax1;
assign rdata2 = rdatax2;

always @(*) begin
  rdatax1 <= mem[raddr1];
  rdatax2 <= mem[raddr2];
end

always @(posedge(clk)) begin
  if(write) begin
    mem[waddr1]<= wdata1;
    mem[waddr2]<= wdata2;
  end
end
endmodule
module mem32x64_SR (input clk,input [4:0] waddr1,input [4:0] waddr2,  
    input [36:0] wdata1,input [36:0] wdata2, input write,
    input [4:0] raddr1, output [36:0] rdata1);
    
reg [36:0] mem[0:31];
    
reg [36:0] rdatax1,rdatax2;

wire [36:0] w0,w1,w2,w3,w4,w5,w6,w7;
assign w0=mem[0];
assign w1=mem[8];
assign w2=mem[2];
assign w3=mem[31];
assign w4 =mem[20];
assign rdata1 = rdatax1;


always @(*) begin
  rdatax1 <= mem[raddr1];
  
end

always @(posedge(clk)) begin
  if(write) begin
    mem[waddr1]<= wdata1;
    mem[waddr2]<= wdata2;
  end
end
endmodule
