module interface2(
	input i_Clock,
	input i_En,
	input [7:0] i_request,
	inout	dht_data_int,
	output [7:0] o_data_int,
	output [7:0] o_data_float,
	output o_done_i1,
	output blue,
	output [7:0]inteiro
	
);

	wire [7:0] 	w_Hum_Int, 
					w_Hum_Float, 
					w_Temp_Int, 
					w_Temp_Float,
					w_Crc;
					
	reg [7:0] r_data_int = 8'd0;
	reg [7:0] r_data_float = 8'd0;
	reg r_done = 1'b0;
	reg r_Rst = 1'b0;
	wire w_done11;
	reg [1:0] state = 2'b00;
	reg en_dht11;
	
	wire         wait_int;
	wire         error_int;
	wire			 debug_int;
	
	assign inteiro = r_data_int;
	assign o_data_int = r_data_int;
	assign o_data_float = r_data_float;
	assign o_done_i1 = r_done;
	
//Definindo casos
localparam idle =  2'b00, 
			  read  =  2'b01, 
			  send  =  2'b10,
			  finish  =  2'b11;
			  

DHT11 ints_dht11 (
	 .CLK(i_Clock),  //50 MHz CLOCK
    .EN(en_dht11),
    .RST(r_Rst),	 // RESET
    .DHT_DATA(dht_data_int),// DADOS DO SENSOR
	 .HUM_INT(w_Hum_Int), // PARTE INTEIRA DOS DADOS DE UMIDADE
	 .HUM_FLOAT(w_Hum_Float), // PARTE FRACIONADA DOS DADOS UMIDADE
    .TEMP_INT(w_Temp_Int), // PARTE INTEIRA DOS DADOS DE TEMPERATURA
	 .TEMP_FLOAT(w_Temp_Float), // PARTE FRACIONADA DOS DADOS DE TEMPERATURA
	 .CRC(w_Crc),
	 .WAIT(wait_int),
	 .DEBUG(debug_int),
	 .error(error_int),
	 .done(w_done11)
);


always @(posedge i_Clock) begin
			case(state)
			idle:  
				begin
					if (i_En == 1'b1) begin
						en_dht11 <= 1'b1;
						r_Rst <= 1'b1;
						state <= read;
					end
				end
			read:
				begin
					r_Rst <= 1'b0;
					if(w_done11 == 1'b1) begin			
						if(i_request == 8'b00000010)begin
							r_data_int <= w_Temp_Int;
							r_data_float <= w_Temp_Float;
						end
						else if (i_request == 8'b00000011)begin
							r_data_int <= w_Hum_Int;
							r_data_float <= w_Hum_Float;
						end
						else if (i_request == 8'b00000001) begin
							if(error_int == 1'b0) begin
								r_data_int <= 8'b00000000;
								r_data_float <= 8'b00000000;
							end
						end
						state <= send;
					end
					if(error_int == 1'b1) begin
						r_data_int <= 8'b10000000;
						r_data_float <= 8'b00000000;
					end
				end
			send:
				begin
					r_done <= 1'b1;
					state <= finish;
				end
			finish:
				begin	
					r_done <= 1'b0;
					en_dht11 <= 1'b0;
					state <= idle;
				end
			endcase
end
	


endmodule
	