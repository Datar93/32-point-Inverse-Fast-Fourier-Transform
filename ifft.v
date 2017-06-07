/*
    `include "twidTHRTWO.v"
    `include "mem32x64.v"
    `include "DW02_mult_4_stage.v"*/

module ifft (clk,rst,pushin,dir,dii,pushout,dor,doi);
parameter WIDTH = 37;
parameter ADR = 5;
input clk,rst;
input pushin;//flag for data

input [27:0] dir,dii;//input for ifft

output [27:0] dor,doi;//output for ifft
output pushout;
wire fifo_in_write_r,fifo_in_write_i;//input to fifo module
wire [(WIDTH-1):0]fifo_in_wdata_r,fifo_in_rdata1_r,fifo_in_rdata2_r,fifo_in_wdata_i,fifo_in_rdata1_i,fifo_in_rdata2_i;//input to real fifo module
wire [(ADR-1):0]fifo_in_waddr_r,fifo_in_waddr_i;//input to imaginary  fifo module
reg [(ADR-1):0]fifo_in_raddr_r,fifo_in_raddr_i,fifo_in_raddr_r2,fifo_in_raddr_i2;
wire [(ADR-1):0]fifo_in_raddr_r_wire,fifo_in_raddr_i_wire,fifo_in_raddr_r2_wire,fifo_in_raddr_i2_wire;
reg [(ADR-1):0] in_wrptr,in_rdptr,in_wrptr_2,in_rdptr_2;//same pointers for real and imaginary
reg [(WIDTH-1):0] f_in_wdata_r,f_in_rdata_r,f_in_wdata_i,f_in_rdata_i;
reg f_in_write_r,f_in_write_i;
reg [4:0] f_cnt;
wire empty_in_r,empty_in_i, full_in_r, full_in_i,STG_EN;
wire dat_rdy;
reg dat_rdy_reg;
//STAGE1
reg [(ADR-1):0]stg1_mem_wr_ptr,stg1_mem_rd_ptr;
//STAGE2
reg [(ADR-1):0]stg2_mem_wr_ptr,stg2_mem_rd_ptr;
//STAGE3
reg [(ADR-1):0]stg3_mem_wr_ptr,stg3_mem_rd_ptr;
//STAGE4
reg [(ADR-1):0]stg4_mem_wr_ptr,stg4_mem_rd_ptr;
//STAGE5
reg [(ADR-1):0]stg5_mem_wr_ptr,stg5_mem_rd_ptr;
reg [(WIDTH-1):0] _dat_in_r1,_dat_in_r2,_dat_in_i1,_dat_in_i2,dat_in_r1,dat_in_r2,dat_in_i1,dat_in_i2,_dor,_doi;
reg fcnt_rdy;
wire [(WIDTH+36)-1:0]dat_out_i2,dat_out_r2;
reg [(WIDTH+36)-1:0]stg5_wdata1_r2_1,stg5_wdata1_i2_1,_stg5_wdata1_r2,_stg5_wdata1_i2;
wire[(WIDTH-1):0]dat_out_i1,dat_out_r1;
reg[(ADR-1):0]stg1_mem_wr_ptr_wire,stg1_mem_rd_ptr_wire,stg2_mem_wr_ptr_wire,stg2_mem_rd_ptr_wire,stg3_mem_wr_ptr_wire,stg3_mem_rd_ptr_wire,stg5_mem_wr_ptr_wire,stg5_mem_rd_ptr_wire,stg4_mem_wr_ptr_wire,stg4_mem_rd_ptr_wire,stg1_mem_wr_ptr2_wire,stg1_mem_rd_ptr2_wire,stg2_mem_wr_ptr2_wire,stg2_mem_rd_ptr2_wire,stg3_mem_wr_ptr2_wire,stg3_mem_rd_ptr2_wire,stg5_mem_wr_ptr2_wire,stg5_mem_rd_ptr2_wire,stg4_mem_wr_ptr2_wire,stg4_mem_rd_ptr2_wire;
wire[(ADR-1):0]stg1_mem_wr_ptr_wire2,stg1_mem_rd_ptr_wire2,stg2_mem_wr_ptr_wire2,stg2_mem_rd_ptr_wire2,stg3_mem_wr_ptr_wire2,stg3_mem_rd_ptr_wire2,stg5_mem_wr_ptr_wire2,stg5_mem_rd_ptr_wire2,stg4_mem_wr_ptr_wire2,stg4_mem_rd_ptr_wire2,stg1_mem_wr_ptr2_wire2,stg1_mem_rd_ptr2_wire2,stg2_mem_wr_ptr2_wire2,stg2_mem_rd_ptr2_wire2,stg3_mem_wr_ptr2_wire2,stg3_mem_rd_ptr2_wire2,stg5_mem_wr_ptr2_wire2,stg5_mem_rd_ptr2_wire2,stg4_mem_wr_ptr2_wire2,stg4_mem_rd_ptr2_wire2;
//STAGE1
reg [(WIDTH-1):0]stg1_wdata1_r1,stg1_wdata1_r2,stg1_wdata1_i2,stg1_wdata1_i1;
wire[(WIDTH-1):0]stg1_wdata1_r1_wire,stg1_wdata1_r2_wire,stg1_wdata1_i2_wire,stg1_wdata1_i1_wire;
wire[(WIDTH-1):0]stg1_rdata1_r1,stg1_rdata1_r2,stg1_rdata1_i2,stg1_rdata1_i1;
//STAGE2
reg [(WIDTH-1):0]stg2_wdata1_r1,stg2_wdata1_r2,stg2_wdata1_i2,stg2_wdata1_i1;
wire [(WIDTH-1):0]stg2_wdata1_r1_wire,stg2_wdata1_r2_wire,stg2_wdata1_i2_wire,stg2_wdata1_i1_wire;
wire[(WIDTH-1):0]stg2_rdata1_r1,stg2_rdata1_r2,stg2_rdata1_i2,stg2_rdata1_i1;
//STAGE3
reg [(WIDTH-1):0]stg3_wdata1_r1,stg3_wdata1_r2,stg3_wdata1_i2,stg3_wdata1_i1;
wire [(WIDTH-1):0]stg3_wdata1_r1_wire,stg3_wdata1_r2_wire,stg3_wdata1_i2_wire,stg3_wdata1_i1_wire;
wire[(WIDTH-1):0]stg3_rdata1_r1,stg3_rdata1_r2,stg3_rdata1_i2,stg3_rdata1_i1;
//STAGE4
reg [(WIDTH-1):0]stg4_wdata1_r1,stg4_wdata1_r2,stg4_wdata1_i2,stg4_wdata1_i1;
wire [(WIDTH-1):0]stg4_wdata1_r1_wire,stg4_wdata1_r2_wire,stg4_wdata1_i2_wire,stg4_wdata1_i1_wire;
wire[(WIDTH-1):0]stg4_rdata1_r1,stg4_rdata1_r2,stg4_rdata1_i2,stg4_rdata1_i1;
//STAGE5
reg [(WIDTH-1):0]stg5_wdata1_r1,stg5_wdata1_r2,stg5_wdata1_i2,stg5_wdata1_i1,_stg5_wdata1_r1,_stg5_wdata1_i1,stg5_wdata1_r1_1,stg5_wdata1_i1_1;
wire[(WIDTH-1):0]stg5_wdata1_r1_wire,stg5_wdata1_r2_wire,stg5_wdata1_i2_wire,stg5_wdata1_i1_wire;
wire[(WIDTH-1):0]stg5_rdata1_r1,stg5_rdata1_r2,stg5_rdata1_i2,stg5_rdata1_i1;
reg STG_SIG;
reg[(ADR-2):0]twid_ct,final_cnt,stg4_cnt;
//reg dat_rdy_reg;
reg [27 :0]dor_reg,doi_reg;
reg OUT_RDY,_pushout;

reg [27:0] temp1,temp2;
assign empty_in_r =(fifo_in_waddr_r+8 == fifo_in_raddr_r+8)?1:0;
assign empty_in_i= (fifo_in_waddr_i+8 == fifo_in_raddr_i+8)?1:0;
assign full_in_r = (fifo_in_waddr_r + 1 == fifo_in_raddr_r)? 1 : 0;
assign full_in_i = (fifo_in_waddr_i + 1 == fifo_in_raddr_i)? 1 : 0;
assign fifo_in_waddr_r = in_wrptr;
assign fifo_in_waddr_i = in_wrptr;
assign fifo_in_wdata_r = f_in_wdata_r;
assign fifo_in_wdata_i = f_in_wdata_i;
assign fifo_in_write_r = f_in_write_r;
assign fifo_in_write_i = f_in_write_i;
assign fifo_in_raddr_r_wire = fifo_in_raddr_r;
assign fifo_in_raddr_i_wire = fifo_in_raddr_i;
assign fifo_in_raddr_r2_wire = fifo_in_raddr_r2;
assign fifo_in_raddr_i2_wire = fifo_in_raddr_i2;
//FINAL OUTPUTS
assign pushout = _pushout;
assign dor=dor_reg;
assign doi=doi_reg;
//STAGE1
assign stg1_wdata1_r1_wire =stg1_wdata1_r1;
assign stg1_wdata1_r2_wire =stg1_wdata1_r2;
assign stg1_wdata1_i1_wire =stg1_wdata1_i1;
assign stg1_wdata1_i2_wire =stg1_wdata1_i2;
//STAGE2
assign stg2_wdata1_r1_wire =stg2_wdata1_r1;
assign stg2_wdata1_r2_wire =stg2_wdata1_r2;
assign stg2_wdata1_i1_wire =stg2_wdata1_i1;
assign stg2_wdata1_i2_wire =stg2_wdata1_i2;
//STAGE3
assign stg3_wdata1_r1_wire =stg3_wdata1_r1;
assign stg3_wdata1_r2_wire =stg3_wdata1_r2;
assign stg3_wdata1_i1_wire =stg3_wdata1_i1;
assign stg3_wdata1_i2_wire =stg3_wdata1_i2;
//STAGE4
assign stg4_wdata1_r1_wire =stg4_wdata1_r1;
assign stg4_wdata1_r2_wire =stg4_wdata1_r2;
assign stg4_wdata1_i1_wire =stg4_wdata1_i1;
assign stg4_wdata1_i2_wire =stg4_wdata1_i2;
//STAGE5
assign stg5_wdata1_r1_wire =stg5_wdata1_r1;
assign stg5_wdata1_r2_wire =stg5_wdata1_r2;
assign stg5_wdata1_i1_wire =stg5_wdata1_i1;
assign stg5_wdata1_i2_wire =stg5_wdata1_i2;

assign dat_rdy = dat_rdy_reg;

//STAGE1
assign stg1_mem_wr_ptr_wire2=stg1_mem_wr_ptr_wire;
assign stg1_mem_rd_ptr_wire2 =stg1_mem_rd_ptr_wire;
assign stg1_mem_wr_ptr2_wire2=stg1_mem_wr_ptr2_wire;
assign stg1_mem_rd_ptr2_wire2 =stg1_mem_rd_ptr2_wire;
//STAGE2
assign stg2_mem_wr_ptr_wire2=stg2_mem_wr_ptr_wire;
assign stg2_mem_rd_ptr_wire2 =stg2_mem_rd_ptr_wire;
assign stg2_mem_wr_ptr2_wire2=stg2_mem_wr_ptr2_wire;
assign stg2_mem_rd_ptr2_wire2 =stg2_mem_rd_ptr2_wire;
//STAGE3
assign stg3_mem_wr_ptr_wire2=stg3_mem_wr_ptr_wire;
assign stg3_mem_rd_ptr_wire2 =stg3_mem_rd_ptr_wire;
assign stg3_mem_wr_ptr2_wire2=stg3_mem_wr_ptr2_wire;
assign stg3_mem_rd_ptr2_wire2 =stg3_mem_rd_ptr2_wire;
//STAGE4
assign stg4_mem_wr_ptr_wire2 = stg4_mem_wr_ptr_wire;
assign stg4_mem_rd_ptr_wire2 = stg4_mem_rd_ptr_wire;
assign stg4_mem_wr_ptr2_wire2 = stg4_mem_wr_ptr2_wire;
assign stg4_mem_rd_ptr2_wire2 = stg4_mem_rd_ptr2_wire;
//STAGE5
assign stg5_mem_wr_ptr_wire2=stg5_mem_wr_ptr_wire;
assign stg5_mem_rd_ptr_wire2 =stg5_mem_rd_ptr_wire;
assign stg5_mem_wr_ptr2_wire2=stg5_mem_wr_ptr2_wire;

//assign fifo_in_raddr_r = 
mem32x64 Real (.clk(clk),.waddr(fifo_in_waddr_r),.wdata(fifo_in_wdata_r),.write(fifo_in_write_r),.raddr1(fifo_in_raddr_r_wire),.raddr2(fifo_in_raddr_r2_wire),.rdata1(fifo_in_rdata1_r),.rdata2(fifo_in_rdata2_r));//Fifo for real numbers
mem32x64 Imaginary (.clk(clk),.waddr(fifo_in_waddr_i),.wdata(fifo_in_wdata_i),.write(fifo_in_write_i),.raddr1(fifo_in_raddr_i_wire),.raddr2(fifo_in_raddr_i2_wire),.rdata1(fifo_in_rdata1_i),.rdata2(fifo_in_rdata2_i));// Fifo for imaginary numbers
//STAGE1 memory
mem32x64_DP ST1MEM_REAL (.clk(clk),.waddr1(stg1_mem_wr_ptr_wire2),.wdata1(stg1_wdata1_r1_wire),.waddr2(stg1_mem_wr_ptr2_wire2),.wdata2(stg1_wdata1_r2_wire),.write(dat_rdy),.raddr1(stg1_mem_rd_ptr_wire2),.raddr2(stg1_mem_rd_ptr2_wire2),.rdata1(stg1_rdata1_r1),.rdata2(stg1_rdata1_r2));
mem32x64_DP ST1MEM_IMG (.clk(clk),.waddr1(stg1_mem_wr_ptr_wire2),.wdata1(stg1_wdata1_i1_wire),.waddr2(stg1_mem_wr_ptr2_wire2),.wdata2(stg1_wdata1_i2_wire),.write(dat_rdy),.raddr1(stg1_mem_rd_ptr_wire2),.raddr2(stg1_mem_rd_ptr2_wire2),.rdata1(stg1_rdata1_i1),.rdata2(stg1_rdata1_i2));
//STAGE 2 MEMORY
mem32x64_DP ST2MEM_REAL (.clk(clk),.waddr1(stg2_mem_wr_ptr_wire2),.wdata1(stg2_wdata1_r1_wire),.waddr2(stg2_mem_wr_ptr2_wire2),.wdata2(stg2_wdata1_r2_wire),.write(dat_rdy),.raddr1(stg2_mem_rd_ptr_wire2),.raddr2(stg2_mem_rd_ptr2_wire2),.rdata1(stg2_rdata1_r1),.rdata2(stg2_rdata1_r2));
mem32x64_DP ST2MEM_IMG (.clk(clk),.waddr1(stg2_mem_wr_ptr_wire2),.wdata1(stg2_wdata1_i1_wire),.waddr2(stg2_mem_wr_ptr2_wire2),.wdata2(stg2_wdata1_i2_wire),.write(dat_rdy),.raddr1(stg2_mem_rd_ptr_wire2),.raddr2(stg2_mem_rd_ptr2_wire2),.rdata1(stg2_rdata1_i1),.rdata2(stg2_rdata1_i2));
//STAGE3
mem32x64_DP ST3MEM_REAL (.clk(clk),.waddr1(stg3_mem_wr_ptr_wire2),.wdata1(stg3_wdata1_r1_wire),.waddr2(stg3_mem_wr_ptr2_wire2),.wdata2(stg3_wdata1_r2_wire),.write(dat_rdy),.raddr1(stg3_mem_rd_ptr_wire2),.raddr2(stg3_mem_rd_ptr2_wire2),.rdata1(stg3_rdata1_r1),.rdata2(stg3_rdata1_r2));
mem32x64_DP ST3MEM_IMG (.clk(clk),.waddr1(stg3_mem_wr_ptr_wire2),.wdata1(stg3_wdata1_i1_wire),.waddr2(stg3_mem_wr_ptr2_wire2),.wdata2(stg3_wdata1_i2_wire),.write(dat_rdy),.raddr1(stg3_mem_rd_ptr_wire2),.raddr2(stg3_mem_rd_ptr2_wire2),.rdata1(stg3_rdata1_i1),.rdata2(stg3_rdata1_i2));
//STAGE4
mem32x64_DP ST4MEM_REAL (.clk(clk),.waddr1(stg4_mem_wr_ptr_wire2),.wdata1(stg4_wdata1_r1_wire),.waddr2(stg4_mem_wr_ptr2_wire2),.wdata2(stg4_wdata1_r2_wire),.write(dat_rdy),.raddr1(stg4_mem_rd_ptr_wire2),.raddr2(stg4_mem_rd_ptr2_wire2),.rdata1(stg4_rdata1_r1),.rdata2(stg4_rdata1_r2));
mem32x64_DP ST4MEM_IMG (.clk(clk),.waddr1(stg4_mem_wr_ptr_wire2),.wdata1(stg4_wdata1_i1_wire),.waddr2(stg4_mem_wr_ptr2_wire2),.wdata2(stg4_wdata1_i2_wire),.write(dat_rdy),.raddr1(stg4_mem_rd_ptr_wire2),.raddr2(stg4_mem_rd_ptr2_wire2),.rdata1(stg4_rdata1_i1),.rdata2(stg4_rdata1_i2));
//STAGE5
mem32x64_SR ST5OUT_REAL (.clk(clk),.waddr1(stg5_mem_wr_ptr_wire2),.wdata1(stg5_wdata1_r1_wire),.waddr2(stg5_mem_wr_ptr2_wire2),.wdata2(stg5_wdata1_r2_wire),.write(dat_rdy),.raddr1(stg5_mem_rd_ptr_wire2),.rdata1(stg5_rdata1_r1));
mem32x64_SR ST5OUT_IMG (.clk(clk),.waddr1(stg5_mem_wr_ptr_wire2),.wdata1(stg5_wdata1_i1_wire),.waddr2(stg5_mem_wr_ptr2_wire),.wdata2(stg5_wdata1_i2_wire),.write(dat_rdy),.raddr1(stg5_mem_rd_ptr_wire),.rdata1(stg5_rdata1_i1));
parameter ADSB= 4'b0001,
          MUL = 4'b0010;
parameter STAGE1=3'b001,
          STAGE2=3'b010,
          STAGE3=3'b011,
          STAGE4=3'b100,
          STAGE5=3'b101;                        
reg [2:0]NXT_STAGE;
always @ (*) begin

 fifo_in_raddr_r <= in_rdptr_2;
 fifo_in_raddr_r2 <= in_rdptr_2+16;
 fifo_in_raddr_i <= in_rdptr_2;
 fifo_in_raddr_i2 <= in_rdptr_2+16;
 stg1_mem_wr_ptr_wire<=stg1_mem_wr_ptr;
 stg1_mem_rd_ptr_wire <=stg1_mem_rd_ptr;
 stg1_mem_wr_ptr2_wire<=stg1_mem_wr_ptr+16;
 stg1_mem_rd_ptr2_wire <=stg1_mem_rd_ptr+8;
//STAGE2
 stg2_mem_wr_ptr_wire<=stg2_mem_wr_ptr;
 stg2_mem_rd_ptr_wire <=stg2_mem_rd_ptr;
 stg2_mem_wr_ptr2_wire<=stg2_mem_wr_ptr+8;
 stg2_mem_rd_ptr2_wire <=stg2_mem_rd_ptr+4;
//STAGE3
 stg3_mem_wr_ptr_wire<=stg3_mem_wr_ptr;
 stg3_mem_rd_ptr_wire <=stg3_mem_rd_ptr;
 stg3_mem_wr_ptr2_wire<=stg3_mem_wr_ptr+4;
 stg3_mem_rd_ptr2_wire <=stg3_mem_rd_ptr+2;
//STAGE4
 stg4_mem_wr_ptr_wire <= stg4_mem_wr_ptr;
 stg4_mem_rd_ptr_wire <= stg4_mem_rd_ptr;
 stg4_mem_wr_ptr2_wire <= stg4_mem_wr_ptr+2;
 stg4_mem_rd_ptr2_wire <= stg4_mem_rd_ptr+1;
//STAGE5
 stg5_mem_wr_ptr_wire<=stg5_mem_wr_ptr;
 stg5_mem_rd_ptr_wire <=stg5_mem_rd_ptr;
 stg5_mem_wr_ptr2_wire<=stg5_mem_wr_ptr+16;
    if(f_cnt < 32)begin
            if(pushin) begin
                if(dir[27]==1) begin
                    f_in_wdata_r <= {5'h1F, dir,4'b0};
                end else begin
                    f_in_wdata_r <= {5'h0, dir,4'b0};
                end
                if(dii[27] ==1) begin
                    f_in_wdata_i <= {5'h1F,dii,4'b0};
                end else begin
                    f_in_wdata_i <= {5'h0,dii,4'b0};
                end
                
                
            end else begin
                f_in_wdata_r<=0;
                f_in_wdata_i<=0;
                
                
            end
    end else begin
        f_in_wdata_r<=0;
        f_in_wdata_i<=0;
        
    end
        
    f_in_write_r<=pushin;
    f_in_write_i<=pushin;
    case (NXT_STAGE) 
        STAGE1: begin
                    if(fcnt_rdy)begin
                         
                         _dat_in_r1<=fifo_in_rdata1_r;
                         _dat_in_r2<=fifo_in_rdata2_r;
                         _dat_in_i1<=fifo_in_rdata1_i;
                          _dat_in_i2<=fifo_in_rdata2_i;
                    end else begin
                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;
                        
                    end
           
                end  
        STAGE2: begin
                    if(fcnt_rdy)begin
//                          if(stg1_mem_rd_ptr > 5'd4 ) begin
//                                 STG_SIG<=1;
//                             end else begin
//                                 STG_SIG<=0;
//                             end
                        // in_rdptr<=in_rdptr_2;
                         _dat_in_r1<=stg1_rdata1_r1;
                         _dat_in_r2<=stg1_rdata1_r2;
                         _dat_in_i1<=stg1_rdata1_i1;
                         _dat_in_i2<=stg1_rdata1_i2;
                    end else begin
                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;
                        
                    end
           
                end 
        STAGE3: begin
                    if(fcnt_rdy)begin

                         _dat_in_r1<=stg2_rdata1_r1;
                         _dat_in_r2<=stg2_rdata1_r2;
                         _dat_in_i1<=stg2_rdata1_i1;
                         _dat_in_i2<=stg2_rdata1_i2;
                    end else begin
                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;
                        
                    end
           
                end
                
        STAGE4: begin
                    if(fcnt_rdy)begin

                         _dat_in_r1<=stg3_rdata1_r1;
                         _dat_in_r2<=stg3_rdata1_r2;
                         _dat_in_i1<=stg3_rdata1_i1;
                         _dat_in_i2<=stg3_rdata1_i2;
                    end else begin
                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;
                        
                    end
           
                end
        STAGE5: begin
                    if(fcnt_rdy)begin
//                         
                         _dat_in_r1<=stg4_rdata1_r1;
                         _dat_in_r2<=stg4_rdata1_r2;
                         _dat_in_i1<=stg4_rdata1_i1;
                         _dat_in_i2<=stg4_rdata1_i2;
                         
                            _stg5_wdata1_r1<= dat_out_r1 ;
                            _stg5_wdata1_r2<= dat_out_r2 ;
                            _stg5_wdata1_i1<= dat_out_i1 ;
                            _stg5_wdata1_i2<= dat_out_i2;
                        
                    end else begin
                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;

                    end
                        
           
                end
            
        default: begin

                        _dat_in_r1<=0;
                        _dat_in_r2<=0;
                        _dat_in_i1<=0;
                        _dat_in_i2<=0;
                end
                        
    endcase

        
end
Butstruc bs1 (clk, rst, dat_in_r1,dat_in_r2, dat_in_i1, dat_in_i2, twid_ct,dat_out_r1, dat_out_i1,dat_out_r2, dat_out_i2);
always @ (posedge clk or posedge rst) begin
    if(rst) begin
       
        //in_rdptr<=0;
        OUT_RDY<=0;
        in_wrptr<=0;
         in_rdptr_2<=0;
        in_wrptr_2<=0;
        f_cnt<=0;

        final_cnt<=0;
        twid_ct<=0;
        fcnt_rdy<=0;
        stg1_mem_wr_ptr<=0;
        stg1_mem_rd_ptr<=0;
        stg2_mem_wr_ptr<=0;
        stg2_mem_rd_ptr<=0;
        stg3_mem_wr_ptr<=0;
        stg3_mem_rd_ptr<=0;
        stg4_mem_wr_ptr<=0;
        stg4_mem_rd_ptr<=0;
        stg5_mem_wr_ptr<=0;
        stg5_mem_rd_ptr<=0;
        dor_reg <=0;
        doi_reg <=0;
        dat_rdy_reg<=0;
        temp1<=28'hf800000;
        temp2<=28'hf700000;
        dat_in_r1<=0;
        dat_in_r2<=0;
        dat_in_i1<=0;
        dat_in_i2<=0;
        stg1_wdata1_r1<=0;
        stg1_wdata1_r2<=0;
        stg1_wdata1_i1<=0;
        stg1_wdata1_i2<=0;
        stg2_wdata1_r1<=0;
        stg2_wdata1_r2<=0;
        stg2_wdata1_i1<=0;
        stg2_wdata1_i2<=0;
        stg3_wdata1_r1<=0;
        stg3_wdata1_r2<=0;
        stg3_wdata1_i1<=0;
        stg3_wdata1_i2<=0;
        stg4_wdata1_r1<=0;
        stg4_wdata1_r2<=0;
        stg4_wdata1_i1<=0;
        stg4_wdata1_i2<=0;
        stg5_wdata1_r1<=0;
        stg5_wdata1_r2<=0;
        stg5_wdata1_i1<=0;
        stg5_wdata1_i2<=0;
        _pushout<=  0;
        stg4_cnt<=0;
        
    end else begin
        if(f_cnt<32 ) begin
            if(pushin) begin
                in_wrptr<=in_wrptr+1;
                f_cnt <= f_cnt +1;
            end
        end else begin
            if(empty_in_i && empty_in_r) begin
                in_wrptr<=0;
            end
        end
        if(f_cnt == 5'd31) begin
            fcnt_rdy<=1;
            in_rdptr_2<=0;
            NXT_STAGE <=STAGE1;
        end 
        
        case (NXT_STAGE) 
            STAGE1: begin
                        if(fcnt_rdy) begin
                            if(in_rdptr_2 < 5'd15) begin
                                in_rdptr_2 <= in_rdptr_2 +1;
                                twid_ct<=twid_ct+1;
                            end
                            
                            dat_in_r1<=_dat_in_r1;
                            dat_in_r2<=_dat_in_r2;
                            dat_in_i1<=_dat_in_i1;
                            dat_in_i2<=_dat_in_i2;
                            
                            stg1_wdata1_r1<=dat_out_r1;
                            stg1_wdata1_r2<=dat_out_r2[68:32];
                            stg1_wdata1_i1<=dat_out_i1;
                            stg1_wdata1_i2<=dat_out_i2[68:32];
                            if(in_rdptr_2 < 5'd7)begin
                                 dat_rdy_reg<=0;
                            end
                             if(in_rdptr_2 == 5'd7)begin
                                 dat_rdy_reg<=1;
                            end
                            if(in_rdptr_2 > 5'd7)begin
                                 
                                 stg1_mem_wr_ptr<=stg1_mem_wr_ptr+1;
                             end 

                            if((stg1_mem_wr_ptr+16) ==5'd30) begin
                                NXT_STAGE<=STAGE2;
                                f_cnt<=0;
                                twid_ct<=0;
                                stg1_mem_rd_ptr<=0;
                                stg2_mem_wr_ptr<=0;
                               // dat_rdy_reg<=0;
                            end
                        end
                       
                            
                    end
            
            STAGE2: begin
                        if(fcnt_rdy) begin
                            if(stg1_mem_rd_ptr  <= 5'd22) begin
                                twid_ct<=twid_ct+2;
                                if((stg1_mem_rd_ptr + 8) == 5'd15) begin
                                    stg1_mem_rd_ptr <= 5'd16;
                                end else begin
                                    stg1_mem_rd_ptr <= stg1_mem_rd_ptr +1;
                                end
                           end
                            dat_in_r1 <= _dat_in_r1;
                            dat_in_r2 <=_dat_in_r2;
                            dat_in_i1 <=_dat_in_i1;
                            dat_in_i2 <=_dat_in_i2;
                            if(stg1_mem_rd_ptr < 5'd7 )begin
                                dat_rdy_reg<=0;
                            end
                            if(stg1_mem_rd_ptr == 5'd7 )begin
                                dat_rdy_reg<=1;
                            end
                            if(stg1_mem_rd_ptr > 5'd7 )begin
                                 if(stg2_mem_wr_ptr == 5'd7) begin
                                    stg2_mem_wr_ptr<=5'd16;
                                 end else begin
                                    stg2_mem_wr_ptr<=stg2_mem_wr_ptr+1;
                                end
                             end 
                                
                            
                             
                            stg2_wdata1_r1<=dat_out_r1;
                            stg2_wdata1_r2<=dat_out_r2[68:32];
                            stg2_wdata1_i1<=dat_out_i1;
                            stg2_wdata1_i2<=dat_out_i2[68:32];

                            if((stg2_mem_wr_ptr+8) ==5'd30) begin
                                NXT_STAGE <= STAGE3;
                                twid_ct<=0;
                                stg2_mem_rd_ptr<=0;
                                stg3_mem_wr_ptr<=0;
                               // dat_rdy_reg<=0;
//                                 STG_SIG<=0;
                            end
                        end
                    end
            STAGE3:begin
                        if(fcnt_rdy) begin
                            if(stg2_mem_rd_ptr <=5'd26) begin
                                twid_ct<=twid_ct+4;
                                if((stg2_mem_rd_ptr + 4) == 5'd7) begin
                                    stg2_mem_rd_ptr <= 5'd8;
                                end else if ((stg2_mem_rd_ptr + 4)== 5'd15)begin
                                    stg2_mem_rd_ptr <= 5'd16;
                                end else if ((stg2_mem_rd_ptr + 4)== 5'd23)begin
                                    stg2_mem_rd_ptr <= 5'd24;
                                end else begin
                                    stg2_mem_rd_ptr <= stg2_mem_rd_ptr +1;
                                end
                            end
                            dat_in_r1 <= _dat_in_r1;
                            dat_in_r2 <=_dat_in_r2;
                            dat_in_i1 <=_dat_in_i1;
                            dat_in_i2 <=_dat_in_i2;
                            if(stg2_mem_rd_ptr < 5'd11 )begin
                                dat_rdy_reg<=0;
                            end
                            if(stg2_mem_rd_ptr == 5'd11 )begin
                                dat_rdy_reg<=1;
                            end
                            if(stg2_mem_rd_ptr > 5'd11)begin
                                
                                 if(stg3_mem_wr_ptr == 5'd3) begin
                                    stg3_mem_wr_ptr <=5'd8;
                                 end else if(stg3_mem_wr_ptr == 5'd11) begin
                                    stg3_mem_wr_ptr<=5'd16;
                                 end else if(stg3_mem_wr_ptr == 5'd19) begin
                                    stg3_mem_wr_ptr<=5'd24;
                                 end else begin
                                    stg3_mem_wr_ptr<=stg3_mem_wr_ptr+1;
                                end
                             end 
                                
                           
                             
                            stg3_wdata1_r1<=dat_out_r1;
                            stg3_wdata1_r2<=dat_out_r2[68:32];
                            stg3_wdata1_i1<=dat_out_i1;
                            stg3_wdata1_i2<=dat_out_i2[68:32];

                            if((stg3_mem_wr_ptr+4) ==5'd30) begin
                                NXT_STAGE<=STAGE4;
                                twid_ct<=0;
                                stg3_mem_rd_ptr<=0;
                                stg4_mem_wr_ptr<=0;
                                stg4_cnt<=0;
                                final_cnt<=0;
                                //dat_rdy_reg<=0;
//                                 STG_SIG<=0;
                            end
                        end
                    end
            STAGE4:begin
                        if(fcnt_rdy) begin
                            if(stg3_mem_rd_ptr < 5'd29) begin
                                twid_ct<=twid_ct+8;
                                if((stg3_mem_rd_ptr + 2) == 5'd3) begin
                                    stg3_mem_rd_ptr <= 5'd4;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd7)begin
                                    stg3_mem_rd_ptr <= 5'd8;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd11)begin
                                    stg3_mem_rd_ptr <= 5'd12;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd15)begin
                                    stg3_mem_rd_ptr <= 5'd16;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd19)begin
                                    stg3_mem_rd_ptr <= 5'd20;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd23)begin
                                    stg3_mem_rd_ptr <= 5'd24;
                                end else if ((stg3_mem_rd_ptr + 2)== 5'd27)begin
                                    stg3_mem_rd_ptr <= 5'd28;
                                end else begin
                                    stg3_mem_rd_ptr <= stg3_mem_rd_ptr +1;
                                end
                            end
                            dat_in_r1 <= _dat_in_r1;
                            dat_in_r2 <=_dat_in_r2;
                            dat_in_i1 <=_dat_in_i1;
                            dat_in_i2 <=_dat_in_i2;
                            if(stg3_mem_rd_ptr < 5'd13) begin
                                dat_rdy_reg<=0;
                                
                            end
                            if(stg3_mem_rd_ptr == 5'd13)begin
                                dat_rdy_reg<=1;
                            end
                            if(stg3_mem_rd_ptr > 5'd13)begin
                               case(stg4_cnt)
                                0: begin stg4_mem_wr_ptr <= 5'd1;stg4_cnt<=stg4_cnt+1; end
                                1: begin stg4_mem_wr_ptr <= 5'd4;stg4_cnt<=stg4_cnt+1; end
                                2 :begin stg4_mem_wr_ptr <= 5'd5;stg4_cnt<=stg4_cnt+1; end
                                3: begin stg4_mem_wr_ptr <= 5'd8;stg4_cnt<=stg4_cnt+1; end
                                4: begin stg4_mem_wr_ptr <= 5'd9;stg4_cnt<=stg4_cnt+1; end
                                5: begin stg4_mem_wr_ptr <= 5'd12;stg4_cnt<=stg4_cnt+1; end
                                6: begin stg4_mem_wr_ptr <= 5'd13; stg4_cnt<=stg4_cnt+1; end
                                7: begin stg4_mem_wr_ptr <= 5'd16; stg4_cnt<=stg4_cnt+1; end
                                8: begin stg4_mem_wr_ptr <= 5'd17; stg4_cnt<=stg4_cnt+1; end
                                9: begin stg4_mem_wr_ptr <= 5'd20; stg4_cnt<=stg4_cnt+1; end
                                10: begin stg4_mem_wr_ptr <= 5'd21; stg4_cnt<=stg4_cnt+1; end
                                11: begin stg4_mem_wr_ptr <= 5'd24; stg4_cnt<=stg4_cnt+1; end
                                12: begin stg4_mem_wr_ptr <= 5'd25; stg4_cnt<=stg4_cnt+1; end
                                13: begin stg4_mem_wr_ptr <= 5'd28; stg4_cnt<=stg4_cnt+1; end
                                14: begin stg4_mem_wr_ptr <= 5'd29; stg4_cnt<=stg4_cnt+1; end
                                
                                endcase
                                
                             end 
                             
                            stg4_wdata1_r1<=dat_out_r1;
                            stg4_wdata1_r2<=dat_out_r2[68:32];
                            stg4_wdata1_i1<=dat_out_i1;
                            stg4_wdata1_i2<=dat_out_i2[68:32];
//                             if(twid_ct <5'd38) begin
//                                 STG_SIG<=0;
//                             end else begin
//                                 STG_SIG<=1;
//                             end
                            if((stg4_mem_wr_ptr+2) ==5'd30) begin
                                NXT_STAGE<=STAGE5;
                                twid_ct<=0;
                                stg4_mem_rd_ptr<=0;
                                stg5_mem_wr_ptr<=0;
                                final_cnt<=0;
                                stg4_cnt<=0;
                                dat_rdy_reg<=0;
//                                 STG_SIG<=0;
                            end
                        end
                    end
            STAGE5: begin
                    if(fcnt_rdy) begin
                             if(stg4_mem_rd_ptr < 5'd29) begin
                                 stg4_mem_rd_ptr <= stg4_mem_rd_ptr +2;
                                 twid_ct<=0;
                             end
                             dat_in_r1 <= _dat_in_r1;
                             dat_in_r2 <=_dat_in_r2;
                             dat_in_i1 <=_dat_in_i1;
                             dat_in_i2 <=_dat_in_i2;
                             
                             if(dat_out_r1[WIDTH-1] == 1'b1) begin
                                stg5_wdata1_r1_1<= {5'h1F, dat_out_r1[36:5]};
                             end else begin
                                stg5_wdata1_r1_1 <= dat_out_r1 >> 5;
                             end
                             if(dat_out_r2[(WIDTH+36) -1] == 1'b1) begin
                                stg5_wdata1_r2_1 <= {5'h1F, dat_out_r2[72:5]} ;
                             end else begin
                                stg5_wdata1_r2_1 <= dat_out_r2 >> 5;
                             end
                             if(dat_out_i1[WIDTH-1] == 1'b1) begin
                                stg5_wdata1_i1_1<= {5'h1F, dat_out_i1[36:5]};
                             end else begin
                                stg5_wdata1_i1_1 <= dat_out_i1 >> 5;
                             end
                             if(dat_out_i2[(WIDTH+36) -1] == 1'b1) begin
                                stg5_wdata1_i2_1 <= {5'h1F,dat_out_i2[72:5]} ;
                             end else begin
                                stg5_wdata1_i2_1 <= dat_out_i2 >> 5;
                             end
                             
                            
                            stg5_wdata1_r1 <= stg5_wdata1_r1_1;

                            stg5_wdata1_r2 <= stg5_wdata1_r2_1[68:32];

                            stg5_wdata1_i1 <= stg5_wdata1_i1_1;

                            
                             stg5_wdata1_i2 <= stg5_wdata1_i2_1[68:32];
                             if(stg4_mem_rd_ptr < 5'd14)begin
                                dat_rdy_reg<=0;
                             end
                             if(stg4_mem_rd_ptr == 5'd14)begin
                                dat_rdy_reg<=1;
                             end
                             if(stg4_mem_rd_ptr > 5'd14) begin
                                
                                case(final_cnt) 
                                    0:begin
                                        final_cnt<=final_cnt+1;
                                      end
                                    1: begin
                                        stg5_mem_wr_ptr<=5'd8;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    2: begin
                                        stg5_mem_wr_ptr<=5'd4;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    3: begin
                                        stg5_mem_wr_ptr<=5'd12;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    4: begin
                                        stg5_mem_wr_ptr<=5'd2;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    5: begin
                                        stg5_mem_wr_ptr<=5'd10;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    6: begin
                                        stg5_mem_wr_ptr<=5'd6;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    7: begin
                                        stg5_mem_wr_ptr<=5'd14;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    8: begin
                                        stg5_mem_wr_ptr<=5'd1;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    9: begin
                                        stg5_mem_wr_ptr<=5'd9;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    10: begin
                                        stg5_mem_wr_ptr<=5'd5;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    11: begin
                                        stg5_mem_wr_ptr<=5'd13;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    12: begin
                                        stg5_mem_wr_ptr<=5'd3;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    13: begin
                                        stg5_mem_wr_ptr<=5'd11;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    14: begin
                                        stg5_mem_wr_ptr<=5'd7;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                    15: begin
                                        stg5_mem_wr_ptr<=5'd15;
                                        final_cnt<=final_cnt+1;
                                        
                                        end
                                endcase
                                if((stg5_mem_wr_ptr+16) ==5'd31) begin
                                    NXT_STAGE<=STAGE1;
                                    twid_ct<=0;
                                    OUT_RDY<=1;
                                    //in_rdptr<=0;
                                    //in_rdptr_2<=0;
                                    stg5_mem_rd_ptr<=0;
                                     stg1_mem_wr_ptr<=0;
                                    final_cnt<=0;
                                     dat_rdy_reg<=0;
                                    fcnt_rdy<=0;
                                    
                                end

                            end        
                             
                    
                    end
                    end
              default: NXT_STAGE<=STAGE1;              
          endcase 
          if(OUT_RDY) begin
               
             dor_reg<= #1 stg5_rdata1_r1[31:4];
             doi_reg <= #1 stg5_rdata1_i1[31:4];
             _pushout<= #1 1;
             stg5_mem_rd_ptr<=stg5_mem_rd_ptr+1;
             if(stg5_mem_rd_ptr == 5'd31) begin
                OUT_RDY<=0;
                
                
             end
          end else begin
            
            
            _pushout<= #1 0;
          end
             
                       
    end
    
                
end


endmodule

module Butstruc (clk, rst, dat_in_r1,dat_in_r2, dat_in_i1, dat_in_i2, twid_ct,dat_out_r1, dat_out_i1,dat_out_r2, dat_out_i2);

parameter WIDTH = 37;
parameter ADDR=5;
input clk,rst;
input [ADDR-2:0]twid_ct;
//output STG_EN,dat_rdy;
//input STG_SIG;
input [WIDTH-1:0] dat_in_r1,dat_in_r2,dat_in_i1,dat_in_i2;
output [(WIDTH+36) -1:0] dat_out_r2, dat_out_i2;
output [WIDTH-1:0]dat_out_r1,dat_out_i1;
reg [WIDTH-1:0] adsb_r1,adsb_r2,adsb_i1,adsb_i2;
reg [WIDTH-1:0]_add_r,_add_i,add_r,add_i,_sub_r,_sub_i,sub_r,sub_i,add_r_2,add_i_2,add_r_3,add_i_3,add_r_4,add_i_4,add_r_5,add_i_5;
reg [(WIDTH+36) -1 :0] _mul_r,_mul_i;
reg [(WIDTH+36) -1:0]mul_r,mul_i;
wire [(WIDTH+36) -1 :0] product1,product2,product3,product4;
reg [ADDR-1:0]twcnt;
reg [35:0]twid_r_1,twid_r_2,twid_r_3,twid_r_4,twid_i_1,twid_i_2,twid_i_3,twid_i_4;
wire [35:0]twid_r,twid_i;
reg dat_rdy_reg;
reg [ADDR-2:0]twid_ct_reg,twid_count;
//assign dat_rdy=dat_rdy_reg;
assign dat_out_r1 =add_r_2 ;
assign dat_out_r2 = mul_r;
assign dat_out_i1 =add_i_2;
assign dat_out_i2 = mul_i;
always @(*) begin

        _add_r<=adsb_r1+adsb_r2;

        _add_i<=adsb_i1+adsb_i2;
//     end
    _sub_r<=adsb_r1-adsb_r2;
    _sub_i<=adsb_i1-adsb_i2;
    _mul_r=product1-product2;
    _mul_i=product3+product4;
    
   
    
end
TwidTHRTWO t1(.cosANG(twid_ct_reg),.cVAL(twid_r),.sinANG(twid_ct_reg),.sVAL(twid_i));
DW02_mult_4_stage #(37,36) mreal1 (.A(sub_r),.B(twid_r_2),.TC(1'b1),.PRODUCT(product1),.CLK(clk));
DW02_mult_4_stage #(37,36) mreal2 (.A(sub_i),.B(twid_i_2),.TC(1'b1),.PRODUCT(product2),.CLK(clk));
DW02_mult_4_stage #(37,36) mimg1 (.A(sub_r),.B(twid_i_2),.TC(1'b1),.PRODUCT(product3),.CLK(clk));
DW02_mult_4_stage #(37,36) mimg2 (.A(sub_i),.B(twid_r_2),.TC(1'b1),.PRODUCT(product4),.CLK(clk));

always @(posedge clk or posedge rst) begin
    
    if(rst) begin
        //dat_rdy<=0;
       // STG_EN<=0;
    end else begin
        twid_ct_reg<=twid_ct;

        twid_r_1<=twid_r;
        twid_r_2<=twid_r_1;
        twid_r_3<=twid_r_2;
        twid_r_4<=twid_r_3;
        twid_i_1<=twid_i;
        twid_i_2<=twid_i_1;
        twid_i_3<=twid_i_2;
        twid_i_4<=twid_i_3;
        adsb_r1<=dat_in_r1;
        adsb_r2<=dat_in_r2;
        adsb_i1<=dat_in_i1;
        adsb_i2<=dat_in_i2;
        if(adsb_r1[WIDTH-1] == 1 && adsb_r2[WIDTH-1] == 1)begin
            add_r<={1'b1,_add_r[36:0]};
        end else begin
            add_r<=_add_r;
        end
        if(adsb_i1[WIDTH-1] == 1 && adsb_i2[WIDTH-1] == 1)begin
            add_i<={1'b1, _add_i[36:0]};
        end else begin
            add_i<=_add_i;
        end
        sub_r<=_sub_r;
        sub_i<=_sub_i;
        add_r_5<=add_r;
        add_i_5<=add_i;
        add_r_4<=add_r_5;
        add_i_4<=add_i_5;
        add_r_3<=add_r_4;
        add_i_3<=add_i_4;
        add_r_2<=add_r_3;
        add_i_2<=add_i_3;

            mul_r <= _mul_r;

        if(product3[(WIDTH+36) -1] == 1 && product4[(WIDTH+36) -1] == 1) begin
            mul_i <= {1'b1,_mul_i[69:0]};
        end else begin
            mul_i <= _mul_i;
        end
    end
    

end

endmodule
