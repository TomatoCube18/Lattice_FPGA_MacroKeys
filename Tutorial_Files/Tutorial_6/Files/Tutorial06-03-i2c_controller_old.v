//
// i2C Controller for TomatoCube 6-Key Macro-KeyPad
// with support for 24L0x EEProm Reading & Write
// Author: Percy Chen
// Last Updated: 28th August 2024
//

module i2c_intf #(
    parameter SYS_FREQ = 12_090_000,
    parameter SCL_FREQ = 100_000
    )(
    input wire clk, nrst,
    // For Write
    input wire wrreq,
    input wire [8:0] waddr, 
    input wire [7:0] wdata,
    input wire rdreq,
    // For Read
    input wire [8:0] raddr,
    output reg [7:0] rdata,
    // Ready Flag
    output reg rdy,
    // i2c Interface
    output reg scl,
    inout sda
    );
    
    reg sda_out;
    assign sda = (sda_out == 0) ? 1'b0 : 1'bz;
	
	// I2C Clock Cycle
    localparam SCL_T = SYS_FREQ / SCL_FREQ;

	// TODO: Check i2C Device Address?
    localparam DADDR_7 = 7'b1010001;
    
    reg [7:0] device_addr;
    
    // SCL Counter
    reg [15:0] cnt_scl;
    wire add_cnt_scl;
    wire end_cnt_scl;
    // bit Counter
    reg [3:0] cnt_bit;
    wire add_cnt_bit;
    wire end_cnt_bit;
    // Step Counter
    reg [3:0] cnt_step;
    wire add_cnt_step;
    wire end_cnt_step;
    
	reg [3:0] bit_num, step_num;
        
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            device_addr <= 0;
        else if(state_c == S_WR_BYTE && cnt_step == 1 - 1 || state_c == S_RD_RANDOM && cnt_step == 1 - 1)
            device_addr <= {DADDR_7, 1'b0};
        else if(state_c == S_RD_RANDOM && cnt_step == 5 - 1)
            device_addr <= {DADDR_7, 1'b1};
    end

    localparam S_IDLE         = 6'b000_001;
    localparam S_WR_BYTE     = 6'b000_010;
    localparam S_RD_RANDOM    = 6'b000_100;
    
    reg [5:0] state_c, state_n;
    
    wire idle2wr_byte;
    wire idle2rd_random;
    wire wr_byte2idle;
    wire rd_random2idle;
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            state_c <= S_IDLE;
        else
            state_c <= state_n;
    end
    
    always @* begin
        case (state_c)
            S_IDLE: begin
                    if(idle2wr_byte)
                        state_n = S_WR_BYTE;
                    else if(idle2rd_random)
                        state_n = S_RD_RANDOM;
                    else
                        state_n = state_c;
                end
            S_WR_BYTE: begin
                    if(wr_byte2idle)
                        state_n = S_IDLE;
                    else
                        state_n = state_c;
                end
            S_RD_RANDOM: begin
                    if(rd_random2idle)
                        state_n = S_IDLE;
                    else
                        state_n = state_c;
                end
            default: state_n = state_c;
        endcase
    end
    
    assign idle2wr_byte        = state_c == S_IDLE     && wrreq;
    assign idle2rd_random    = state_c == S_IDLE        && rdreq;
    assign wr_byte2idle        = state_c == S_WR_BYTE    && end_cnt_step;
    assign rd_random2idle    = state_c == S_RD_RANDOM && end_cnt_step;
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt_scl <= 0;
        else if(add_cnt_scl) begin
            if(end_cnt_scl)
                cnt_scl <= 0;
            else
                cnt_scl <= cnt_scl + 1'b1;
        end
    end
    assign add_cnt_scl = state_c != S_IDLE;
    assign end_cnt_scl = add_cnt_scl && cnt_scl == SCL_T - 1;
        
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt_bit <= 0;
        else if(add_cnt_bit) begin
            if(end_cnt_bit)
                cnt_bit <= 0;
            else
                cnt_bit <= cnt_bit + 1'b1;
        end
    end
    assign add_cnt_bit = end_cnt_scl;
    assign end_cnt_bit = add_cnt_bit && cnt_bit == bit_num - 1;
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt_step <= 0;
        else if(add_cnt_step) begin
            if(end_cnt_step)
                cnt_step <= 0;
            else
                cnt_step <= cnt_step + 1'b1;
        end
    end
    assign add_cnt_step = end_cnt_bit;
    assign end_cnt_step = add_cnt_step && cnt_step == step_num - 1;

   
	// Write Sequence: Start, Device Address, Write 0(Page), Write Address, Write Data, End
	// Read Sequence: Start, Device Address, Write 0(Page), Write Address, Start, Device Address, Read Data, End 
    always @* begin
        if(state_c == S_IDLE) begin
            step_num = 0;
            bit_num = 0;
        end
        else if(state_c == S_WR_BYTE) begin
            step_num = 6;
            if(cnt_step == 1 - 1 || cnt_step == step_num - 1)
                bit_num = 1;
            else
                bit_num = 9;
        end
        else if(state_c == S_RD_RANDOM) begin
            step_num = 8;
            if(cnt_step == 1 - 1 || cnt_step == 5 - 1 || cnt_step == step_num - 1)
                bit_num = 1;
            else
                bit_num = 9;
        end
        else begin
          step_num = 0;
          bit_num = 0;
        end
    end
    
    // SCL Signal
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            scl <= 1;
        else if(add_cnt_scl && cnt_scl == SCL_T / 2 - 1)
            scl <= 1;
        else if(end_cnt_scl && !end_cnt_step)
            scl <= 0;
    end
    
    // SDA Signal
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            sda_out <= 1;
        else begin
            // Start
            if((cnt_step == 1 - 1 || state_c == S_RD_RANDOM && cnt_step == 5 - 1) && cnt_scl == SCL_T * 3 / 4 - 1)
                sda_out <= 0;
            // End, Pull SDA Low
            else if(cnt_step == step_num - 1 && cnt_scl == SCL_T / 4 - 1)
                sda_out <= 0;
            else if(cnt_step == step_num - 1 && cnt_scl == SCL_T * 3 / 4 - 1)
                sda_out <= 1;
            // Pull Data High while Waiting
            else if(cnt_bit == 9 - 1 && cnt_scl == SCL_T / 4 - 1)
                sda_out <= 1;
            // Device Address
            else if((state_c == S_WR_BYTE && cnt_step == 2 - 1 || state_c == S_RD_RANDOM && (cnt_step == 2 - 1 || cnt_step == 6 - 1)) && cnt_scl == SCL_T / 4 - 1 && cnt_bit != 9 - 1)
                sda_out <= device_addr[7 - cnt_bit];
            // Write 0
            else if((state_c == S_WR_BYTE && cnt_step == 3 - 1 || state_c == S_RD_RANDOM && cnt_step == 3 - 1 ) && cnt_scl == SCL_T / 4 - 1 && cnt_bit != 9 - 1)
                sda_out <= 0;
            
            // Write Address
            else if(state_c == S_WR_BYTE && cnt_step == 4 - 1 && cnt_scl == SCL_T / 4 - 1 && cnt_bit != 9 - 1)
                sda_out <= waddr[7 - cnt_bit];
            // Write Data
            else if(state_c == S_WR_BYTE && cnt_step == 5 - 1 && cnt_scl == SCL_T / 4 - 1 && cnt_bit != 9 - 1)
                sda_out <= wdata[7 - cnt_bit];
            // Read Address
            else if(state_c == S_RD_RANDOM && cnt_step == 4 - 1 && cnt_scl == SCL_T / 4 - 1 && cnt_bit != 9 - 1)
                sda_out <= raddr[7 - cnt_bit];
        end
    end

    // Reading Portion
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            rdata <= 0;
        else if(state_c == S_RD_RANDOM && cnt_step == 7 - 1 && cnt_scl == SCL_T / 4 * 3 - 1 && cnt_bit != 9 - 1)
            rdata[7 - cnt_bit] <= sda;
    end
    
 
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            rdy <= 1;
        else if(state_c == S_IDLE)
            rdy <= 1;
        else
            rdy <= 0;
    end
   
endmodule