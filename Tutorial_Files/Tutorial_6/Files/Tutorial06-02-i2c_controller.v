/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name:
** Creation Date: 28th August 2024
** Function Description: i2C Controller with support for 24L0x EEProm Reading & Write
** Operation Process:
** Hardware Platform: TomatoCube 6-Key Macro-KeyPad with MachXO2 FPGA
** Copyright Statement: This code is an IP of TomatoCube and can only for non-profit or
**                      educational exchange.
**---------------------------Related Information of Modified Files------------------------
** Modifier: Percy Chen
** Modification Date: 31st August 2024       
** Modification Content:
******************************************************************************************/

module i2c_eeprom #(
    parameter SYS_FREQ = 12_090_000,  // System clock frequency (in Hz)
    parameter I2C_FREQ = 100_000      // I2C clock frequency (in Hz)
)(
    input wire clk,            // System clock
    input wire rst_n,          // Active low reset
	input wire start,          // Start signal
    input wire rw,             // Read/Write signal (1 = Read, 0 = Write)
    input wire [7:0] address,  // EEPROM memory address
    input wire [7:0] data_in,  // Data to write
    output wire [7:0] data_out, // Data read from EEPROM
    output reg done,           // Operation complete signal
    inout wire sda,            // I2C data line (bidirectional)
    output wire scl             // I2C clock line
);

    //---------------------------------------------
	// Address and data to be written to 24C02	
	
	`define DEVICE_READ     8'b1010_0001    // Device address (read operation)
	`define DEVICE_WRITE    8'b1010_0000    // Device address (write operation)
	//`define WRITE_DATA      8'b0000_0001    // Data written to EEPROM
	//`define WRITE_DATA      8'b0010_1111    
	//`define BYTE_ADDR       8'b0000_0011    // Address register for writing/reading EEPROM 
	
	reg[7:0] db_r;        // Data register transmitted on IIC
	reg[7:0] read_data;    // Data register read from EEPROM
	
	reg[19:0] cnt_20ms;    // 20ms count register
 
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt_20ms <= 20'd0;
		else
			cnt_20ms <= cnt_20ms+1'b1;    // Constant counting
		end
	
	//---------------------------------------------
	// Frequency division part
	reg [2:0] cnt;           // cnt=0: scl rising edge, cnt=1: scl high middle, cnt=2: scl falling edge, cnt=3: scl low middle
	reg [8:0] cnt_delay;     // 500 loop count, generates the clock needed for IIC
	reg scl_r;               // Clock pulse register
	 
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt_delay <= 9'd0;
		else if(cnt_delay == 9'd499)
			cnt_delay <= 9'd0;    // Count to 10us for scl period, i.e., 100KHz -> 50000000/500
		else
			cnt_delay <= cnt_delay+1'b1;    // Clock counting
	end
	 
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt <= 3'd5;
		else
		begin
			case (cnt_delay)				//500/4
				9'd129:    cnt <= 3'd1;    // cnt=1: scl high middle, used for data sampling
				9'd249:    cnt <= 3'd2;    // cnt=2: scl falling edge
				9'd379:    cnt <= 3'd3;    // cnt=3: scl low middle, used for data change
				9'd499:    cnt <= 3'd0;    // cnt=0: scl rising edge
				default:   cnt <= 3'd5;
			endcase
		end
	end
	`define SCL_POS        (cnt==3'd0)        // cnt=0: scl rising edge
	`define SCL_HIG        (cnt==3'd1)        // cnt=1: scl high middle, used for data sampling
	`define SCL_NEG        (cnt==3'd2)        // cnt=2: scl falling edge
	`define SCL_LOW        (cnt==3'd3)        // cnt=3: scl low middle, used for data change
	 
	always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			scl_r <= 1'b0;
		else if(cnt==3'd0)
			scl_r <= 1'b1;    // scl signal rising edge
		else if(cnt==3'd2)
			scl_r <= 1'b0;    // scl signal falling edge
	end
	assign scl = scl_r;    // Generate the clock needed for IIC

	//---------------------------------------------
	// Read, write timing
	parameter     IDLE     = 4'd0;
	parameter     START1     = 4'd1;
	parameter     ADD1     = 4'd2;
	parameter     ACK1     = 4'd3;
	parameter     ADD2     = 4'd4;
	parameter     ACK2     = 4'd5;
	parameter     START2     = 4'd6;
	
	parameter     ADD3     = 4'd7;
	parameter     ACK3    = 4'd8;
	parameter     DATA     = 4'd9;
	parameter     ACK4    = 4'd10;
	parameter     STOP1     = 4'd11;
	parameter     STOP2     = 4'd12;
	
	//parameter     RESET     = 4'd13;
	 
	reg [3:0] cstate;     // State register
	reg sda_r;            // Output data register
	reg sda_link;         // Output data SDA signal inout direction control bit        
	reg[3:0] num;    
	 
	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
				cstate <= IDLE;
				sda_r <= 1'b1;
				sda_link <= 1'b0;
				num <= 4'd0;
				read_data <= 8'b0000_0000;
				done <= 1'b0;
			end
		else     
			case (cstate)
				IDLE:    begin
						sda_link <= 1'b1;            // Data line SDA is output
						sda_r <= 1'b1;
						done <= 1'b0;
						if(start) begin    //Start detected    
							done <= 1'b0;
							db_r <= `DEVICE_WRITE;    // Send device address (write operation)
							cstate <= START1;        
							end
						else cstate <= IDLE;    // Nothing going on here
					end
				START1: begin
						if(`SCL_HIG) begin        // During scl high level
							sda_link <= 1'b1;    // Data line SDA is output
							sda_r <= 1'b0;        // Pull down the data line SDA to generate a start bit signal
							cstate <= ADD1;
							num <= 4'd0;        // Clear num count
							end
						else cstate <= START1; // Wait for scl high middle position
					end
				ADD1:    begin
						if(`SCL_LOW) begin
								if(num == 4'd8) begin    
										num <= 4'd0;            // Clear num count
										sda_r <= 1'b1;
										sda_link <= 1'b0;        // Set SDA to high impedance (input)
										cstate <= ACK1;
									end
								else begin
										cstate <= ADD1;
										num <= num+1'b1;
										case (num)
											4'd0: sda_r <= db_r[7];
											4'd1: sda_r <= db_r[6];
											4'd2: sda_r <= db_r[5];
											4'd3: sda_r <= db_r[4];
											4'd4: sda_r <= db_r[3];
											4'd5: sda_r <= db_r[2];
											4'd6: sda_r <= db_r[1];
											4'd7: sda_r <= db_r[0];
											default: ;
											endcase
								
									end
							end
				
						else cstate <= ADD1;
					end
				ACK1:    begin
						if(/*!sda*/`SCL_HIG) begin    // Note: 24C01/02/04/08/16 devices may not need to consider the acknowledge bit
								if (sda) begin			// Device not ready
									db_r <= `DEVICE_WRITE;    // Send device address (write operation)
									cstate <= START1;     
								end else begin
									cstate <= ADD2;    // Slave response signal
									db_r <= address;//`BYTE_ADDR;    // Send Byte address
								end
							end
						else cstate <= ACK1;        // Wait for slave response
					end
				
				ADD2:    begin
						if(`SCL_LOW) begin
								if(num==4'd8) begin    
										num <= 4'd0;            // Clear num count
										sda_r <= 1'b1;
										sda_link <= 1'b0;        // Set SDA to high impedance (input)
										cstate <= ACK2;
									end
								else begin
										sda_link <= 1'b1;        //sda as output
										num <= num+1'b1;
										case (num)
											4'd0: sda_r <= db_r[7];
											4'd1: sda_r <= db_r[6];
											4'd2: sda_r <= db_r[5];
											4'd3: sda_r <= db_r[4];
											4'd4: sda_r <= db_r[3];
											4'd5: sda_r <= db_r[2];
											4'd6: sda_r <= db_r[1];
											4'd7: sda_r <= db_r[0];
											default: ;
											endcase
								//        sda_r <= db_r[4'd7-num];    //Sending EEPROM Address (Starting with Hi Bit.. Which endian??)        
										cstate <= ADD2;                    
									end
							end
				//        else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};    
						else cstate <= ADD2;                
					end
				ACK2:    begin
						if(/*!sda*/`SCL_HIG) begin        // Slave response signal
							if (!sda) begin
								if (rw == 0) begin        // execute write (1 = Read, 0 = Write)
										sda_link <= 1'b1;
										sda_r <= 1'b0; 
										cstate <= DATA;     //Write Operation
										db_r <= data_in;//`WRITE_DATA;    // Send write data                           
									end    
								else begin				// execute read
										db_r <= `DEVICE_READ;     // Send device address (read operation)
										cstate <= START2;        // Slave response signal
									end
								end
							end 
							
						else cstate <= ACK2;    // Wait for slave response signal
					end
				START2: begin    //2nd Start for Read operation
						if(`SCL_LOW) begin
							sda_link <= 1'b1;    //sda as output
							sda_r <= 1'b1;        // Pull up sda
							cstate <= START2;
							end
						else if(`SCL_HIG) begin    // During scl high level
							sda_r <= 1'b0;        // Pull down data line SDA to generate a start bit signal
							cstate <= ADD3;
							end    
						else cstate <= START2;
					end
				ADD3:    begin    
						if(`SCL_LOW) begin
								if(num==4'd8) begin    
										num <= 4'd0;            // Clear num count
										sda_r <= 1'b1;
										sda_link <= 1'b0;        
										cstate <= ACK3;
									end
								else begin
										num <= num+1'b1;
										case (num)
											4'd0: sda_r <= db_r[7];
											4'd1: sda_r <= db_r[6];
											4'd2: sda_r <= db_r[5];
											4'd3: sda_r <= db_r[4];
											4'd4: sda_r <= db_r[3];
											4'd5: sda_r <= db_r[2];
											4'd6: sda_r <= db_r[1];
											4'd7: sda_r <= db_r[0];
											default: ;
										endcase                                    
									//    sda_r <= db_r[4'd7-num];            
										cstate <= ADD3;                    
									end
							end
					//    else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};    
						else cstate <= ADD3;                
					end
					
						
				ACK3:    begin
						if(/*!sda*/`SCL_HIG) begin    // Note: 24C01/02/04/08/16 devices may not need to consider the acknowledge bit
								if (sda) begin			// Device not ready
									db_r <= `DEVICE_READ;    // Send device address (write operation)
									cstate <= START2;     
								end else begin
									cstate <= DATA;    // Slave response signal
									sda_link <= 1'b0;
								end
							end
						else cstate <= ACK3;        // Wait for slave response
							
						//if(/*!sda*/`SCL_NEG) begin
								//cstate <= DATA;    //Ack response
								//sda_link <= 1'b0;
							//end
						//else cstate <= ACK3;         //Waiting for response
					end
				DATA:    begin
						if(rw == 1) begin     //Read  operation
								if(num<=4'd7) begin
									cstate <= DATA;
									if(`SCL_HIG) begin    
										num <= num+1'b1;    
										case (num)
											4'd0: read_data[7] <= sda;
											4'd1: read_data[6] <= sda;
											4'd2: read_data[5] <= sda;
											4'd3: read_data[4] <= sda;
											4'd4: read_data[3] <= sda;
											4'd5: read_data[2] <= sda;
											4'd6: read_data[1] <= sda;
											4'd7: read_data[0] <= sda;
											default: ;
											endcase                                                                        
						//                read_data[4'd7-num] <= sda;    
										end
					//                else if(`SCL_NEG) read_data <= {read_data[6:0],read_data[7]};    
									end
								else if((`SCL_LOW) && (num==4'd8)) begin
									num <= 4'd0;            //num counter to 0
									cstate <= ACK4;
									end
								else cstate <= DATA;
							end
						else begin    				//Write operation
								sda_link <= 1'b1;    
								if(num<=4'd7) begin
									cstate <= DATA;
									if(`SCL_LOW) begin
										sda_link <= 1'b1;        // Data line SDA is output
										num <= num+1'b1;
										case (num)
											4'd0: sda_r <= db_r[7];
											4'd1: sda_r <= db_r[6];
											4'd2: sda_r <= db_r[5];
											4'd3: sda_r <= db_r[4];
											4'd4: sda_r <= db_r[3];
											4'd5: sda_r <= db_r[2];
											4'd6: sda_r <= db_r[1];
											4'd7: sda_r <= db_r[0];
											default: ;
											endcase                                    
									//    sda_r <= db_r[4'd7-num];    
										end
				//                    else if(`SCL_POS) db_r <= {db_r[6:0],1'b0};    
									 end
								else if((`SCL_LOW) && (num==4'd8)) begin
										num <= 4'd0;
										sda_r <= 1'b1;
										sda_link <= 1'b0;        // Data line SDA is HI-Z (Input from Device)
										cstate <= ACK4;
									end
								else cstate <= DATA;
							end
					end
				ACK4: begin
						if(/*!sda*/`SCL_NEG) begin
	//                        sda_r <= 1'b1;
							cstate <= STOP1;                        
							end
						else cstate <= ACK4;
					end
				STOP1:    begin
						if(`SCL_LOW) begin
								sda_link <= 1'b1;	// Data line SDA is output
								sda_r <= 1'b0;
								cstate <= STOP1;
							end
						else if(`SCL_HIG) begin		// During scl high level
								sda_r <= 1'b1;    // Release data line, stop condition
								cstate <= STOP2;
							end
						else cstate <= STOP1;
					end
				STOP2:    begin
						if(`SCL_LOW) sda_r <= 1'b1;
						else if(cnt_20ms==20'hffff0) 
						begin	
							//cstate <= RESET;
							cstate <= IDLE;
							done <= 1'b1;
						end
						else cstate <= STOP2;
					end
				//RESET:	begin
						//if(cnt_20ms==20'hffff0) 
						//begin
							//cstate <= IDLE;
							//sda_r <= 1'b1;
							//sda_link <= 1'b0;
							//num <= 4'd0;
							//done <= 1'b0;
						//end
					//end
				default: cstate <= IDLE;
				endcase
	end
	assign sda = sda_link ? sda_r:1'bz;		// Generate sda signal
	assign data_out = read_data;
endmodule
