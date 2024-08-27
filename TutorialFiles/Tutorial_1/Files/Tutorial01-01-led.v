`timescale 1ns / 1ps
 
module LED (swU,led);
    input wire swU;                        
    output reg led;
   
    reg [31:0]count;
   
    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC
        (
          .STDBY(1'b0),
          .OSC(clk),
          .SEDSTDBY()
        );
   
    always @(posedge clk or negedge swU) begin
        if (swU == 0) begin
            led <= 1;
        end else if(count == 9999999) begin //Time is up = 9999999/12.09MHz = 0.82s
            count <= 0;             //Reset count register
            led <= ~led;            //Toggle led (in each second)
        end else begin
            count <= count + 1;     //Counts 12.09MHz clock
        end
 
    end
 
endmodule