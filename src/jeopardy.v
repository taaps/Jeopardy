module jeopardy
(
  CLOCK_50,
  SW,
  KEY,
  LEDR,
  HEX0,
  HEX1,
  HEX2,
  HEX5,
  VGA_CLK,
  VGA_HS,
  VGA_VS,
  VGA_BLANK_N,
  VGA_SYNC_N,
  VGA_R,
  VGA_G,
  VGA_B
);

input			CLOCK_50;
input	    [3:0]	KEY;
input     [9:0] SW;
output    [9:0] LEDR;
output 	 [6:0] HEX0;
output 	 [6:0] HEX1;
output 	 [6:0] HEX2;
output 	 [6:0] HEX5;
output			VGA_CLK;
output			VGA_HS;
output			VGA_VS;
output			VGA_BLANK_N;
output			VGA_SYNC_N;
output	[7:0]	VGA_R;
output	[7:0]	VGA_G;
output	[7:0]	VGA_B;

wire resetn;
assign resetn = KEY[3];
wire clock;
assign clock = CLOCK_50;
wire go;
assign go = SW[9];

wire [3:0] row;
assign row[3:0] = SW[3:0];  //row number of question
wire [4:0] col;
assign col[4:0] = SW[8:4];  //col number of question

wire done_draw; //is the square done drawing
wire black;     //draw a black square
wire draw;      //draw a coloured square

wire choosecolour;

wire [7:0] xposition;   //xposition of topleft corner of a particular block
wire [6:0] yposition;   //yposition of topleft corner of a particular block

// Create the colour, x, y and writeEn wires that are inputs to the controller.
wire [2:0] colour;
wire [7:0] x;
wire [6:0] y;
wire writeEn;

assign writeEn = draw;   //draw the square when this value is = 1

vga_adapter VGA(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(colour),
    .x(x),
    .y(y),
    .plot(writeEn),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK));
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
  defparam VGA.BACKGROUND_IMAGE = "black.mif";

  wire [2:0]colourchoice;
  assign colour[2:0] = colourchoice[2:0];
  
  wire drawblack;		//draw a black background on the screen
  wire done_black;	
  wire answer1, answer2, answer3;	//answers to a question
  assign answer1 = KEY[0];
  assign answer2 = KEY[1];
  assign answer3 = KEY[2];
  
  //LEDR lights up if the answer is right
  wire checker;
  assign LEDR[0] = checker;
  assign LEDR[1] = checker;
  assign LEDR[2] = checker;
  assign LEDR[3] = checker;
  assign LEDR[4] = checker;
  assign LEDR[5] = checker;
  assign LEDR[6] = checker;
  assign LEDR[7] = checker;
  assign LEDR[8] = checker;
  assign LEDR[9] = checker;
  
  //wires used for deciding whether to display a question
  wire go6, go7, go8, go9, go11, go12, go13, go14, go16, go17, go18, go19, go21, go22, go23, go24;
  wire go10, go15, go20, go25;
  
  //when the game is over
  wire endsignal;
  
  //control of the FSM
  FSM_control c0(.clock(clock), .resetn(resetn), .row(row), .col (col), .go(go), .done_draw(done_draw), .done_black(done_black), .answer1(answer1), .answer2(answer2), .answer3(answer3),
                 .black(black), .draw(draw), .xposition(xposition), .yposition(yposition), .choosecolour(choosecolour), .drawblack(drawblack), 
					  .checker(checker), .go7(go7), .go6(go6), .go8(go8), .go9(go9), .go11(go11), .go12(go12), .go13(go13), .go14(go14), .go16(go16),
					  .go17(go17), .go18(go18), .go19(go19), .go21(go21), .go22(go22), .go23(go23), .go24(go24),
					  .go10(go10), .go15(go15), .go20(go20), .go25(go25), .score1(score1), .score2(score2), .score3(score3), .score4(score4), .endsignal(endsignal),
					  .playera(playera), .playerb(playerb), .playerc(playerc), .playerd(playerd), .playerturn(playerturn)
  );

  //datapath of the FSM
  datapath d1(.clock(clock), .black(black), .draw(draw), .resetn(resetn), .xposition(xposition), .choosecolour(choosecolour), 
				  .drawblack(drawblack), .go7(go7), .go6(go6), .go8(go8), .go9(go9), .go11(go11), .go12(go12), .go13(go13), .go14(go14), 
				  .go16(go16), .go17(go17), .go18(go18), .go19(go19), .go21(go21), .go22(go22), .go23(go23), .go24(go24),
				  .go10(go10), .go15(go15), .go20(go20), .go25(go25), .endsignal(endsignal),
              .yposition(yposition), .X(x), .Y(y), .done_draw(done_draw), .colour(colourchoice), .done_black(done_black)
  );
  
  //decide which player's turn it is
  wire playerturn;
  
  //used to display the player's turn on the VGA
  wire playera, playerb, playerc, playerd;
  
  //100th digit of the score that the player attained
  hexdecoder h5(.c0(playera), .c1(playerb), .c2(playerc), .c3(playerd), 
					 .a(HEX5[0]), .b(HEX5[1]), .c(HEX5[2]), .d(HEX5[3]), 
					 .e(HEX5[4]), .f(HEX5[5]), .g(HEX5[6])
  );
  
  //display the score that the player has
  hexdecoder h2(.c0(score1), .c1(score2), .c2(score3), .c3(score4), 
					 .a(HEX2[0]), .b(HEX2[1]), .c(HEX2[2]), .d(HEX2[3]), 
					 .e(HEX2[4]), .f(HEX2[5]), .g(HEX2[6])
  );
  
  //display zero
  hexdecoder h0(.c0(0), .c1(0), .c2(0), .c3(0), 
					 .a(HEX0[0]), .b(HEX0[1]), .c(HEX0[2]), .d(HEX0[3]), 
					 .e(HEX0[4]), .f(HEX0[5]), .g(HEX0[6])
  );
  
  //display zero
  hexdecoder h1(.c0(0), .c1(0), .c2(0), .c3(0), 
					 .a(HEX1[0]), .b(HEX1[1]), .c(HEX1[2]), .d(HEX1[3]), 
					 .e(HEX1[4]), .f(HEX1[5]), .g(HEX1[6])
  );
  
  //whether the answer was right or not
  wire score1;
  wire score2;
  wire score3;
  wire score4;
  
endmodule

module FSM_control(
    input clock, resetn, go, done_draw, done_black, answer1, answer2, answer3,
	 input [3:0]row,
	 input [4:0]col,
	 output reg playera, playerb, playerc, playerd,
    output reg black, draw,
    output reg [7:0] xposition,
    output reg [6:0] yposition,
	 output reg choosecolour,
	 output reg drawblack,
	 output reg go7, go6, go8, go9, go11, go12, go13, go14, go16, go17, go18, go19, go21, go22, go23, go24,
	 output reg go10, go15, go20, go25,
	 output reg playerturn,
	 output reg score1, score2, score3, score4,
	 output reg endsignal,
	 output reg checker
);

  reg [5:0] current_state, next_state;

  localparam RESET_STAGE = 6'b000000,
             MAIN_START  = 6'b000001,
             BLOCK1      = 6'b000010,	//each block represents a question stage
				 BLOCK2		 = 6'b000011,
				 BLOCK3		 = 6'b000100,
				 BLOCK4		 = 6'b000101,
				 BLOCK5		 = 6'b000110,
				 BLOCK6		 = 6'b000111,
				 BLOCK7		 = 6'b001000,
				 BLOCK8		 = 6'b001001,
				 BLOCK9		 = 6'b001010,
				 BLOCK10		 = 6'b001011,
				 BLOCK11		 = 6'b001100,
				 BLOCK12     = 6'b001101,
				 BLOCK13     = 6'b001110,
				 BLOCK14     = 6'b001111,
				 BLOCK15     = 6'b010000,
				 BLOCK16     = 6'b010001,
				 BLOCK17     = 6'b010010,
				 BLOCK18     = 6'b010011,
				 BLOCK19     = 6'b010100,
				 BLOCK20     = 6'b010101,
				 BLOCK21     = 6'b010110,
				 BLOCK22     = 6'b010111,
				 BLOCK23     = 6'b011000,
				 BLOCK24     = 6'b011001,
             BLOCK25     = 6'b011010,
             MAIN_WAIT   = 6'b011011,
				 BLACK_DRAWSTATE = 6'b011100,		//draw the black background
				 END_STATE   = 6'b011101;		//display this state when the game is over
				 
    reg a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y;	//used to check if a question has already been answered
	 reg gotoblack;
	 reg [11:0]player1score;
	 reg [11:0]player2score;
	 reg switch;
	 reg gotoend;
	 
   //state table
   always @(*)
   begin: state_table
          case (current_state)
                RESET_STAGE: next_state = BLACK_DRAWSTATE;
					 BLACK_DRAWSTATE: next_state = done_black? MAIN_START : BLACK_DRAWSTATE;
                MAIN_START: next_state = BLOCK1;	//this stage is used to set some values to default
                BLOCK1: next_state = done_draw? BLOCK2 : BLOCK1;	//when a particular question block is done drawing, draw the next block
					 BLOCK2: next_state = done_draw? BLOCK3 : BLOCK2;
					 BLOCK3: next_state = done_draw? BLOCK4 : BLOCK3;
					 BLOCK4: next_state = done_draw? BLOCK5 : BLOCK4;
					 BLOCK5: next_state = done_draw? BLOCK6 : BLOCK5;
					 BLOCK6: next_state = done_draw? BLOCK7 : BLOCK6;
					 BLOCK7: next_state = done_draw? BLOCK8 : BLOCK7;
					 BLOCK8: next_state = done_draw? BLOCK9 : BLOCK8;
					 BLOCK9: next_state = done_draw? BLOCK10 : BLOCK9;
					 BLOCK10: next_state = done_draw? BLOCK11 : BLOCK10;
					 BLOCK11: next_state = done_draw? BLOCK12 : BLOCK11;
					 BLOCK12: next_state = done_draw? BLOCK13 : BLOCK12;
					 BLOCK13: next_state = done_draw? BLOCK14 : BLOCK13;
					 BLOCK14: next_state = done_draw? BLOCK15 : BLOCK14;
					 BLOCK15: next_state = done_draw? BLOCK16 : BLOCK15;
					 BLOCK16: next_state = done_draw? BLOCK17 : BLOCK16;
					 BLOCK17: next_state = done_draw? BLOCK18 : BLOCK17;
					 BLOCK18: next_state = done_draw? BLOCK19 : BLOCK18;
					 BLOCK19: next_state = done_draw? BLOCK20 : BLOCK19;
					 BLOCK20: next_state = done_draw? BLOCK21 : BLOCK20;
					 BLOCK21: next_state = done_draw? BLOCK22 : BLOCK21;
					 BLOCK22: next_state = done_draw? BLOCK23 : BLOCK22;
					 BLOCK23: next_state = done_draw? BLOCK24 : BLOCK23;
					 BLOCK24: next_state = done_draw? BLOCK25 : BLOCK24;
                BLOCK25: next_state = done_draw? MAIN_WAIT : BLOCK25;
                MAIN_WAIT: next_state = MAIN_START;
					 END_STATE: next_state = END_STATE;
                default: next_state = RESET_STAGE;
          endcase
   end
				
   //datapath control signals
   always @(*)
   begin: enable_signals

          case(current_state)
                RESET_STAGE:
                  begin
							//initialise all values to default
                      black = 1'b0;
                      draw = 1'b0;
							 drawblack = 1'b0;
                      xposition = 8'b0;
                      yposition = 7'b0;
							 checker = 1'b0;
							 go6 = 1'b0;
							 go7 = 1'b0;
							 go8 = 1'b0;
							 go9 = 1'b0;
							 go11 = 1'b0;
							 go12 = 1'b0;
							 go13 = 1'b0;
							 go14 = 1'b0;
							 go16 = 1'b0;
							 go17 = 1'b0;
							 go18 = 1'b0;
							 go19 = 1'b0;
							 go21 = 1'b0;
							 go22 = 1'b0;
							 go23 = 1'b0;
							 go24 = 1'b0;
							 go10 = 1'b0;
							 go15 = 1'b0;
							 go20 = 1'b0;
							 go25 = 1'b0;
							 gotoblack = 1'b0;
                      a = 1'b0;
							 b = 1'b0;
							 c = 1'b0;
							 d = 1'b0;
							 e = 1'b0;
							 f = 1'b0;
							 g = 1'b0;
							 h = 1'b0;
							 i = 1'b0;
							 j = 1'b0;
							 k = 1'b0;
							 l = 1'b0;
							 m = 1'b0;
							 n = 1'b0;
							 o = 1'b0;
							 p = 1'b0;
							 q = 1'b0;
							 r = 1'b0;
							 s = 1'b0;
                      t = 1'b0;
							 u = 1'b0;
							 v = 1'b0;
							 w = 1'b0;
							 x = 1'b0;
							 y = 1'b0;
							 playera = 1'b1; 
							 playerb = 1'b0;
							 playerc = 1'b0;
							 playerd = 1'b0;
							 score1 = 1'b0;
							 score2 = 1'b0;
							 score3 = 1'b0;
							 score4 = 1'b0;
							 player1score = 12'b0;
							 player2score = 12'b0;
							 switch = 0;
							 endsignal = 0;
							 gotoend = 0;
							 //playerturn = 1'b1;
                  end
						//draw the black background
                BLACK_DRAWSTATE:
						begin
							gotoblack = 1'b0;
							xposition = 8'b0;
							yposition = 7'b0;
							choosecolour = 1'b1;
							drawblack = 1'b1;
							draw = 1'b1;
							 go6 = 1'b0;
							 go7 = 1'b0;
							 go8 = 1'b0;
							 go9 = 1'b0;
							 go11 = 1'b0;
							 go12 = 1'b0;
							 go13 = 1'b0;
							 go14 = 1'b0;
							 go16 = 1'b0;
							 go17 = 1'b0;
							 go18 = 1'b0;
							 go19 = 1'b0;
							 go21 = 1'b0;
							 go22 = 1'b0;
							 go23 = 1'b0;
							 go24 = 1'b0;
							 go10 = 1'b0;
							 go15 = 1'b0;
							 go20 = 1'b0;
							 go25 = 1'b0;
							 
							 score1 = 1'b0;
							 score2 = 1'b0;
							 score3 = 1'b0;
				  			 score4 = 1'b0;
							 
							 switch = 0;
						end
						
					END_STATE:
						begin
							endsignal = 1'b1;	//display the game over page
							draw = 1'b1;
						end
						
					 MAIN_START:
						begin
							drawblack = 1'b0;
							
							//if all the questions have been answered, go to the endstage
							if ((f == 1'b1) && (g == 1'b1) && (h == 1'b1) && (i == 1'b1) && 
								(j == 1'b1) && (k == 1'b1) && (l == 1'b1) && (m == 1'b1) && (n == 1'b1) && (o == 1'b1) && (p == 1'b1) && (q == 1'b1) && (r == 1'b1) && 
								(s == 1'b1) && (t == 1'b1) && (u == 1'b1) && (v == 1'b1) && (w == 1'b1) && (x == 1'b1) && (y == 1'b1))
									begin
										gotoend = 1'b1;
									end

							//the following if statements light up correctly answered questions and add the score to the respective player		
									
							//check if question 6 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[0] == 1'b1) && (col[0] == 1'b1))
                      begin
								if (answer1 == 1'b0)
									begin
										checker = 1'b1;
										score1 = 1'b1;
										score2 = 1'b0;
										score3 = 1'b0;
										score4 = 1'b0;
										
										if (switch == 0)
										begin
											if (playerturn == 1'b0)
												player2score = player2score + 3'd100;
											else if (playerturn == 1'b1)
												player1score = player1score + 3'd100;
											
											switch = 1'b1;
										end
									end
							 end
							
							//check if question 7 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[0] == 1'b1) && (col[1] == 1'b1))
									begin
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b0;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd100;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd100;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 8 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[0] == 1'b1) && (col[2] == 1'b1))
										begin
											if (answer3 == 1'b0)
												begin
													checker = 1'b1;
													score1 = 1'b1;
													score2 = 1'b0;
													score3 = 1'b0;
													score4 = 1'b0;
													
													if (switch == 0)
													begin
														if (playerturn == 1'b0)
															player2score = player2score + 3'd100;
														else if (playerturn == 1'b1)
															player1score = player1score + 3'd100;
														
														switch = 1'b1;
													end
												end
										end
										
							//check if question 10 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[0] == 1'b1) && (col[4] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b0;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd100;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd100;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 9 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[0] == 1'b1) && (col[3] == 1'b1))
									begin
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b0;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd100;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd100;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 11 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[1] == 1'b1) && (col[0] == 1'b1))
									begin
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd200;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd200;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 12 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[1] == 1'b1) && (col[1] == 1'b1))
									begin
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd200;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd200;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 13 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[1] == 1'b1) && (col[2] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd200;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd200;
													
													switch = 1'b1;
												end
											end
									end
							
							//check if question 14 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[1] == 1'b1) && (col[3] == 1'b1))
									begin		
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd200;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd200;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 15 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[1] == 1'b1) && (col[4] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd200;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd200;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 16 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[2] == 1'b1) && (col[0] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd300;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd300;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 17 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[2] == 1'b1) && (col[1] == 1'b1))
									begin
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd300;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd300;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 18 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[2] == 1'b1) && (col[2] == 1'b1))
									begin
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd300;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd300;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 19 was correct and light up LEDRs if it was answered correctly
								if ((go == 1'b1) && (row[2] == 1'b1) && (col[3] == 1'b1))
									begin
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd300;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd300;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 20 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[2] == 1'b1) && (col[4] == 1'b1))
									begin
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b1;
												score2 = 1'b1;
												score3 = 1'b0;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd300;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd300;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 21 was correct and light up LEDRs if it was answered correctly
								if ((go == 1'b1) && (row[3] == 1'b1) && (col[0] == 1'b1))
									begin
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b0;
												score3 = 1'b1;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd400;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd400;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 22 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[3] == 1'b1) && (col[1] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b0;
												score3 = 1'b1;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd400;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd400;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 23 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[3] == 1'b1) && (col[2] == 1'b1))
									begin
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b0;
												score3 = 1'b1;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd400;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd400;
													
													switch = 1'b1;
												end
											end
									end
									
							//check if question 24 was correct and light up LEDRs if it was answered correctly
							if ((go == 1'b1) && (row[3] == 1'b1) && (col[3] == 1'b1))
									begin
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
												score1 = 1'b0;
												score2 = 1'b0;
												score3 = 1'b1;
												score4 = 1'b0;
												
												if (switch == 0)
												begin
													if (playerturn == 1'b0)
														player2score = player2score + 3'd400;
													else if (playerturn == 1'b1)
														player1score = player1score + 3'd400;
													
													switch = 1'b1;
												end
											end
									end
									
							//25
							if ((go == 1'b1) && (row[3] == 1'b1) && (col[4] == 1'b1))
										begin
											if (answer1 == 1'b0)
												begin
													checker = 1'b1;
													score1 = 1'b0;
													score2 = 1'b0;
													score3 = 1'b1;
													score4 = 1'b0;
													
													if (switch == 0)
													begin
														if (playerturn == 1'b0)
															player2score = player2score + 3'd400;
														else if (playerturn == 1'b1)
															player1score = player1score + 3'd400;
														
														switch = 1'b1;
													end
												end
										end
										
							if (playerturn == 1'b0)
								begin
									playera = 1'b1; 
									playerb = 1'b0;
									playerc = 1'b0;
									playerd = 1'b0;
								end
							else if (playerturn == 1'b1)
								begin
									playera = 1'b0; 
									playerb = 1'b1;
									playerc = 1'b0;
									playerd = 1'b0;
								end
							
						end
					//display the first category block
                BLOCK1:
                    begin
							 if (a == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b0;
									yposition = 7'b0;
									choosecolour = 1'b0;
								 end
                    end
					  //display the second category block
					  BLOCK2:
                    begin
							 if (b == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b100000;
									yposition = 7'b0;
									choosecolour = 1'b0;
								 end
                      end
					//display the third category block
					BLOCK3:
                    begin
							 if (c == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1000000;
									yposition = 7'b0;
									choosecolour = 1'b0;
								 end
                      end
					//display the fourth category block
					BLOCK4:
                    begin
							 if (d == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1100000;
									yposition = 7'b0;
									choosecolour = 1'b0;
								 end
                      end
					//display the fifth category block
					BLOCK5:
                    begin
							 if (e == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b10000000;
									yposition = 7'b0;
									choosecolour = 1'b0;
								 end
                      end	
					//display first category, first question block (remaining states follow this example)
					BLOCK6:
                    begin
                    if (f == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b0;
                        yposition = 7'b11000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[0] == 1'b1) && (col[0] == 1'b1))
                      begin
								go6 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
										begin
											go6 = 1'b0;
											f = 1'b1;
											gotoblack = 1'b1;
											
											if (answer1 == 1'b0)
												begin
													checker = 1'b1;
												end
										end
                      end
						  //display default page block
                    else
                      begin
							 if (f == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b0;
									yposition = 7'b11000;
									choosecolour = 1'b0;
								 end
                      end
                    end		
					BLOCK7:
                    begin
                    if (g == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b100000;
                        yposition = 7'b11000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[0] == 1'b1) && (col[1] == 1'b1))
                      begin
								go7 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go7 = 1'b0;
										g = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (g == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b100000;
									yposition = 7'b11000;
									choosecolour = 1'b0;
								 end
                      end
                    end		  
					BLOCK8:
                    begin
							  if (h == 1'b1)	//if question has already been answered
								 begin
									draw = 1'b1;
									black = 1'b1;
									xposition = 8'b1000000;
									yposition = 7'b11000;
									choosecolour = 1'b1;
								 end
							  //if user is in the middle of answering the question
							  else if ((go == 1'b1) && (row[0] == 1'b1) && (col[2] == 1'b1))
								 begin
									go8 = 1'b1;
									checker = 1'b0;
										if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
										begin
											go8 = 1'b0;
											h = 1'b1;
											gotoblack = 1'b1;
											
											if (answer3 == 1'b0)
												begin
													checker = 1'b1;
												end
										end
								 end
							  //display default page block
							  else
								 begin
								 if (h == 1'b0)
									 begin
										draw = 1'b1;
										black = 1'b0;
										xposition = 8'b1000000;
										yposition = 7'b11000;
										choosecolour = 1'b0;
									 end
								 end
                    end					
					 BLOCK9:
                    begin
                    if (i == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1100000;
                        yposition = 7'b11000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[0] == 1'b1) && (col[3] == 1'b1))
                      begin
								go9 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go9 = 1'b0;
										i = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (i == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1100000;
									yposition = 7'b11000;
									choosecolour = 1'b0;
								 end
                      end
                    end	
					BLOCK10:
                    begin
                    if (j == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b10000000;
                        yposition = 7'b11000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[0] == 1'b1) && (col[4] == 1'b1))
                      begin
								go10 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go10 = 1'b0;
										j = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (j == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b10000000;
									yposition = 7'b11000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 	  
						  
					 BLOCK11:
                    begin
                    if (k == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b0;
                        yposition = 7'b110000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[1] == 1'b1) && (col[0] == 1'b1))
                      begin
								go11 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go11 = 1'b0;
										k = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (k == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b0;
									yposition = 7'b110000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
					
					  BLOCK12:
                    begin
                    if (l == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b100000;
                        yposition = 7'b110000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[1] == 1'b1) && (col[1] == 1'b1))
                      begin
								go12 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go12 = 1'b0;
										l = 1'b1;
										gotoblack = 1'b1;
										
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (l == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b100000;
									yposition = 7'b110000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
						  
					 BLOCK13:
                    begin
                    if (m == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1000000;
                        yposition = 7'b110000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[1] == 1'b1) && (col[2] == 1'b1))
                      begin
								go13 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go13 = 1'b0;
										m = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (m == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1000000;
									yposition = 7'b110000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
					 
				    BLOCK14:
                    begin
                    if (n == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1100000;
                        yposition = 7'b110000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[1] == 1'b1) && (col[3] == 1'b1))
                      begin
								go14 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go14 = 1'b0;
										n = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (n == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1100000;
									yposition = 7'b110000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
					
					 BLOCK15:
                    begin
                    if (o == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b10000000;
                        yposition = 7'b110000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[1] == 1'b1) && (col[4] == 1'b1))
                      begin
								go15 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go15 = 1'b0;
										o = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (o == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b10000000;
									yposition = 7'b110000;
									choosecolour = 1'b0;
								 end
                      end
                    end
						
				    BLOCK16:
                    begin
                    if (p == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b0;
                        yposition = 7'b1001000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[2] == 1'b1) && (col[0] == 1'b1))
                      begin
								go16 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go16 = 1'b0;
										p = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (p == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b0;
									yposition = 7'b1001000;
									choosecolour = 1'b0;
								 end
                      end
                    end	
						 
					 BLOCK17:
                    begin
                    if (q == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b100000;
                        yposition = 7'b1001000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[2] == 1'b1) && (col[1] == 1'b1))
                      begin
								go17 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go17 = 1'b0;
										q = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (q == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b100000;
									yposition = 7'b1001000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
						  
					 BLOCK18:
                    begin
                    if (r == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1000000;
                        yposition = 7'b1001000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[2] == 1'b1) && (col[2] == 1'b1))
                      begin
								go18 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go18 = 1'b0;
										r = 1'b1;
										gotoblack = 1'b1;
										
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (r == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1000000;
									yposition = 7'b1001000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
						  
					 BLOCK19:
                    begin
                    if (s == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1100000;
                        yposition = 7'b1001000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[2] == 1'b1) && (col[3] == 1'b1))
                      begin
								go19 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go19 = 1'b0;
										s = 1'b1;
										gotoblack = 1'b1;
										
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (s == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1100000;
									yposition = 7'b1001000;
									choosecolour = 1'b0;
								 end
                      end
                    end
						
			       BLOCK20:
                    begin
                    if (t == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b10000000;
                        yposition = 7'b1001000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[2] == 1'b1) && (col[4] == 1'b1))
                      begin
								go20 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go20 = 1'b0;
										t = 1'b1;
										gotoblack = 1'b1;
										
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (t == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b10000000;
									yposition = 7'b1001000;
									choosecolour = 1'b0;
								 end
                      end
                    end	
						 
					 BLOCK21:
                    begin
                    if (u == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b0;
                        yposition = 7'b1100000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[3] == 1'b1) && (col[0] == 1'b1))
                      begin
								go21 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go21 = 1'b0;
										u = 1'b1;
										gotoblack = 1'b1;
										
										if (answer2 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (u == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b0;
									yposition = 7'b1100000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
					 
					 BLOCK22:
                    begin
                    if (v == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b100000;
                        yposition = 7'b1100000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[3] == 1'b1) && (col[1] == 1'b1))
                      begin
								go22 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go22 = 1'b0;
										v = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (v == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b100000;
									yposition = 7'b1100000;
									choosecolour = 1'b0;
								 end
                      end
                    end
						
				    BLOCK23:
                    begin
                    if (w == 1'b1)	//if question has already been answered
                      begin
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1000000;
                        yposition = 7'b1100000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[3] == 1'b1) && (col[2] == 1'b1))
                      begin
								go23 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go23 = 1'b0;
										w = 1'b1;
										gotoblack = 1'b1;
										
										if (answer3 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (w == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1000000;
									yposition = 7'b1100000;
									choosecolour = 1'b0;
								 end
                      end
                    end
					 
					 BLOCK24:
                    begin
                    if (x == 1'b1)	//if question has already been answered
                      begin	
                        draw = 1'b1;
                        black = 1'b1;
                        xposition = 8'b1100000;
                        yposition = 7'b1100000;
								choosecolour = 1'b1;
                      end
						  //if user is in the middle of answering the question
                    else if ((go == 1'b1) && (row[3] == 1'b1) && (col[3] == 1'b1))
                      begin
								go24 = 1'b1;
								checker = 1'b0;
									if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
									begin
										go24 = 1'b0;
										x = 1'b1;
										gotoblack = 1'b1;
										
										if (answer1 == 1'b0)
											begin
												checker = 1'b1;
											end
									end
                      end
						  //display default page block
                    else
                      begin
							 if (x == 1'b0)
								 begin
									draw = 1'b1;
									black = 1'b0;
									xposition = 8'b1100000;
									yposition = 7'b1100000;
									choosecolour = 1'b0;
								 end
                      end
                    end	 
						  
                BLOCK25:
                    begin
							  if (y == 1'b1)	//if question has already been answered
								 begin
									draw = 1'b1;
									black = 1'b1;
									xposition = 8'b10000000;
									yposition = 7'b1100000;
									choosecolour = 1'b1;
								 end
							  //if user is in the middle of answering the question
							  else if ((go == 1'b1) && (row[3] == 1'b1) && (col[4] == 1'b1))
								 begin
									go25 = 1'b1;
									checker = 1'b0;
										if ((answer1 == 1'b0) || (answer2 == 1'b0) || (answer3 == 1'b0))
										begin
											go25 = 1'b0;
											y = 1'b1;
											gotoblack = 1'b1;
											
											if (answer1 == 1'b0)
												begin
													checker = 1'b1;
												end
										end
								 end
							  //display default page block
							  else
								 begin
								 if (y == 1'b0)
									begin
										draw = 1'b1;
										black = 1'b0;
										xposition = 8'b10000000;
										yposition = 7'b1100000;
										choosecolour = 1'b0;
									end
								 end
						  end
               // MAIN_WAIT:
          endcase
   end

   //state_FFs table
   always@(posedge clock)
   begin: state_FFs
        if (!resetn)
            begin
              current_state <= RESET_STAGE;
				  playerturn <= 1'b0;
            end
		  else if (gotoblack)
				begin
					current_state <= BLACK_DRAWSTATE;
					//switch the player's turn
					if (playerturn == 1'b0)
								begin
									playerturn <= 1'b1;
								end
							 else if (playerturn == 1'b1)
								begin
									playerturn <= 1'b0;
								end
				end
			//gameover
			else if (gotoend)
				begin
					current_state <= END_STATE;
				end
        else
            begin
              current_state <= next_state;
            end
   end
endmodule

module datapath(
      input clock, black, draw, resetn, choosecolour, drawblack, go7, go6, go8, 
		input go9, go11, go12, go13, go14, go16, go17, go18, go19, go21, go22, go23, go24,
		input go10, go15, go20, go25,
      input [7:0] xposition,
      input [6:0] yposition,
		input endsignal,
      output reg [7:0] X,
      output reg [6:0] Y,
      output reg done_draw,
		output reg [2:0] colour,
		output reg done_black
);

	//assign different colours different values
	wire blackcol;
	assign blackcol = 1'b0;
	wire white;
	assign white = 1'b1;
	wire outcolour;

	//choose which colour to draw the block
	mux2to1 m0(.x(white), .y(blackcol), .s(choosecolour), .m(outcolour));

  integer i, j;
  integer a, b;
  integer c, d;
  integer y, z;
  
  //the following ram instantiations are used for displaying pictures on the screen
  reg [14:0]memoryAddress7;	//memoryAddress for this particular ram
  wire [2:0]colourimage7;		//colour sequence that is outputted from this ram
  
  ram7 a7(.address(memoryAddress7),	//memoryAddress
						  .clock(clock),	//CLOCK_50
						  .data(3'b0),		//do not want to change the data
						  .wren(1'b0),		//do not that to write any data in this ram
						  .q(colourimage7)	//obtain the colour sequence stored at a particular memory location
						  );
  //same as above	
  reg [14:0]memoryAddress6;
  wire [2:0]colourimage6;
  
  ram6 a6(.address(memoryAddress6),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage6)
						  );
	//same as above	
  reg [14:0]memoryAddress8;
  wire [2:0]colourimage8;
  
  ram8 a8(.address(memoryAddress8),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage8)
						  );
	//same as above					  
  reg [14:0]memoryAddress9;
  wire [2:0]colourimage9;
  
  ram9 a9(.address(memoryAddress9),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage9)
						  );
	//same as above	
  reg [14:0]memoryAddress11;
  wire [2:0]colourimage11;
  
  ram11 a11(.address(memoryAddress11),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage11)
						  );
	//same as above	
  reg [14:0]memoryAddress12;
  wire [2:0]colourimage12;
  
  ram12 a12(.address(memoryAddress12),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage12)
						  );
	//same as above					  
  reg [14:0]memoryAddress13;
  wire [2:0]colourimage13;
  
  ram13 a13(.address(memoryAddress13),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage13)
						  );
	//same as above	
  reg [14:0]memoryAddress14;
  wire [2:0]colourimage14;
  
  ram14 a14(.address(memoryAddress14),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage14)
						  );
	//same as above	
  reg [14:0]memoryAddress16;
  wire [2:0]colourimage16;
  
  ram16 a16(.address(memoryAddress16),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage16)
						  );
	//same as above	
  reg [14:0]memoryAddress17;
  wire [2:0]colourimage17;
  
  ram17 a17(.address(memoryAddress17),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage17)
						  );
	//same as above						  
  reg [14:0]memoryAddress18;
  wire [2:0]colourimage18;
  
  ram18 a18(.address(memoryAddress18),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage18)
						  );
	//same as above						  
  reg [14:0]memoryAddress19;
  wire [2:0]colourimage19;
  
  ram19 a19(.address(memoryAddress19),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage19)
						  );
	//same as above	
  reg [14:0]memoryAddress21;
  wire [2:0]colourimage21;
  
  ram21 a21(.address(memoryAddress21),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage21)
						  );
	//same as above						  
  reg [14:0]memoryAddress22;
  wire [2:0]colourimage22;
  
  ram22 a22(.address(memoryAddress22),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage22)
						  );
	//same as above						  
  reg [14:0]memoryAddress23;
  wire [2:0]colourimage23;
  
  ram23 a23(.address(memoryAddress23),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage23)
						  );
	//same as above						  
  reg [14:0]memoryAddress24;
  wire [2:0]colourimage24;
  
  ram24 a24(.address(memoryAddress24),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage24)
						  );
	//same as above						  
  reg [14:0]memoryAddress10;
  wire [2:0]colourimage10;
  
  ram10 a10(.address(memoryAddress10),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage10)
						  );
	//same as above						  
  reg [14:0]memoryAddress15;
  wire [2:0]colourimage15;
  
  ram15 a15(.address(memoryAddress15),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage15)
						  );
	//same as above						  
  reg [14:0]memoryAddress20;
  wire [2:0]colourimage20;
  
  ram20 a20(.address(memoryAddress20),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage20)
						  );
	//same as above						  
  reg [14:0]memoryAddress25;
  wire [2:0]colourimage25;
  
  ram25 a25(.address(memoryAddress25),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimage25)
						  );
	//same as above						  
  reg [14:0]memoryAddressover;
  wire [2:0]colourimageover;
  
  ramgameover aover(.address(memoryAddressover),
						  .clock(clock),
						  .data(3'b0),
						  .wren(1'b0),
						  .q(colourimageover)
						  );					  
	

  always @(posedge clock)
  begin
      if (!resetn)
          begin
				//assign all the values to default
            X <= 8'b0;
            Y <= 7'b0;
            i <= 0;
            j <= 0;
				a <= 0;
				b <= 0;
				c <= 0;
				d <= 0;
				y <= 0;
				z <= 0;
            done_draw <= 0;
				done_black <= 0;
				memoryAddress6 <= 0;
				memoryAddress7 <= 0;
				memoryAddress8 <= 0;
				memoryAddress9 <= 0;
				memoryAddress11 <= 0;
				memoryAddress12 <= 0;
				memoryAddress13 <= 0;
				memoryAddress14 <= 0;
				memoryAddress16 <= 0;
				memoryAddress17 <= 0;
				memoryAddress18 <= 0;
				memoryAddress19 <= 0;
				memoryAddress21 <= 0;
				memoryAddress22 <= 0;
				memoryAddress23 <= 0;
				memoryAddress24 <= 0;
				memoryAddress10 <= 0;
				memoryAddress15 <= 0;
				memoryAddress20 <= 0;
				memoryAddress25 <= 0;
				memoryAddressover <= 0;
          end
		//if the game is over, display the gameover screen
		else if (endsignal)
			begin
						colour[2:0] <= colourimageover[2:0];
						memoryAddressover <= memoryAddressover + 1'b1;
						
						if (z==159)
							begin
								z <= 0;
								y <= y + 1;
							end
						else
							begin
								z <= z + 1;
							end

						X <= z;
						Y <= y;

						if ((y==119) && (z==159))
							begin
								memoryAddressover <= 0;
								y <= 0;
								z <= 0;
								//done_draw <= 1;
							end
			end
		//if a black background needs to be drawn, draw the black screen
		else if (drawblack)
			begin
				if ((a == 0) && (b == 0))
					begin
						done_black <= 0;
					end
					
				if (b == 159)
					begin
						b <= 0;
						a <= a + 1;
					end
				else
					begin
						b <= b + 1;
					end
		
				colour <= outcolour;
				
				X <= xposition + b;
				Y <= yposition + a;
					
				if ((a == 119) && (b == 159))
					begin
						a <= 0;
						b <= 0;
						done_black <= 1;
					end
				
			end
		//if the answers selects a particular question, display the question that they selected 
		else if (go7 || go6 || go8 || go9 || go11 || go12 || go13 || go14 || go16 || go17 || go18 || go19 || go21 || go22 || go23 || go24 || go10 || go15 || go20 || go25)
			begin
						//ex. if question 6 was selected, get the colour sequence at the memory address and increase its memory count until it reaches the end
						if (go6)
							begin
								colour[2:0] <= colourimage6[2:0];
								memoryAddress6 <= memoryAddress6 + 1'b1;
							end
						else if (go7)
							begin
								colour[2:0] <= colourimage7[2:0];
								memoryAddress7 <= memoryAddress7 + 1'b1;
							end
						else if (go8)
							begin
								colour[2:0] <= colourimage8[2:0];
								memoryAddress8 <= memoryAddress8 + 1'b1;
							end
						else if (go9)
							begin
								colour[2:0] <= colourimage9[2:0];
								memoryAddress9 <= memoryAddress9 + 1'b1;
							end
						else if (go11)
							begin
								colour[2:0] <= colourimage11[2:0];
								memoryAddress11 <= memoryAddress11 + 1'b1;
							end
						else if (go12)
							begin
								colour[2:0] <= colourimage12[2:0];
								memoryAddress12 <= memoryAddress12 + 1'b1;
							end
						else if (go13)
							begin
								colour[2:0] <= colourimage13[2:0];
								memoryAddress13 <= memoryAddress13 + 1'b1;
							end
						else if (go14)
							begin
								colour[2:0] <= colourimage14[2:0];
								memoryAddress14 <= memoryAddress14 + 1'b1;
							end
						else if (go16)
							begin
								colour[2:0] <= colourimage16[2:0];
								memoryAddress16 <= memoryAddress16 + 1'b1;
							end
						else if (go17)
							begin
								colour[2:0] <= colourimage17[2:0];
								memoryAddress17 <= memoryAddress17 + 1'b1;
							end
						else if (go18)
							begin
								colour[2:0] <= colourimage18[2:0];
								memoryAddress18 <= memoryAddress18 + 1'b1;
							end
						else if (go19)
							begin
								colour[2:0] <= colourimage19[2:0];
								memoryAddress19 <= memoryAddress19 + 1'b1;
							end
						else if (go21)
							begin
								colour[2:0] <= colourimage21[2:0];
								memoryAddress21 <= memoryAddress21 + 1'b1;
							end
						else if (go22)
							begin
								colour[2:0] <= colourimage22[2:0];
								memoryAddress22 <= memoryAddress22 + 1'b1;
							end
						else if (go23)
							begin
								colour[2:0] <= colourimage23[2:0];
								memoryAddress23 <= memoryAddress23 + 1'b1;
							end
						else if (go24)
							begin
								colour[2:0] <= colourimage24[2:0];
								memoryAddress24 <= memoryAddress24 + 1'b1;
							end
						else if (go10)
							begin
								colour[2:0] <= colourimage10[2:0];
								memoryAddress10 <= memoryAddress10 + 1'b1;
							end
						else if (go15)
							begin
								colour[2:0] <= colourimage15[2:0];
								memoryAddress15 <= memoryAddress15 + 1'b1;
							end
						else if (go20)
							begin
								colour[2:0] <= colourimage20[2:0];
								memoryAddress20 <= memoryAddress20 + 1'b1;
							end
						else if (go25)
							begin
								colour[2:0] <= colourimage25[2:0];
								memoryAddress25 <= memoryAddress25 + 1'b1;
							end
						

						if (d==159)
							begin
								d <= 0;
								c <= c + 1;
							end
						else
							begin
								d <= d + 1;
							end

						X <= d;
						Y <= c;

						//assign all values to default when finished drawing the picture
						if ((c==119) && (d==159))
							begin
								memoryAddress6 <= 0;
								memoryAddress7 <= 0;
								memoryAddress8 <= 0;
								memoryAddress9 <= 0;
								memoryAddress11 <= 0;
								memoryAddress12 <= 0;
								memoryAddress13 <= 0;
								memoryAddress14 <= 0;
								memoryAddress16 <= 0;
								memoryAddress17 <= 0;
								memoryAddress18 <= 0;
								memoryAddress19 <= 0;
								memoryAddress21 <= 0;
								memoryAddress22 <= 0;
								memoryAddress23 <= 0;
								memoryAddress24 <= 0;
								memoryAddress10 <= 0;
								memoryAddress15 <= 0;
								memoryAddress20 <= 0;
								memoryAddress25 <= 0;
								c <= 0;
								d <= 0;
								//done_draw <= 1;
							end
			end
			
		//draw a black screen on the VGA
		else if (drawblack)
			begin
				if ((a == 0) && (b == 0))
					begin
						done_black <= 0;
					end
					
				if (b == 159)
					begin
						b <= 0;
						a <= a + 1;
					end
				else
					begin
						b <= b + 1;
					end
		
				colour <= outcolour;
				
				X <= xposition + b;
				Y <= yposition + a;
					
				if ((a == 119) && (b == 159))
					begin
						a <= 0;
						b <= 0;
						done_black <= 1;
					end
				
			end
			
		//if the default board screen is to be drawn
      else if (draw)
          begin
					//done_black <= 0;
					if ((i==0) && (j==0))
						begin
							done_draw <= 0;
						end
			 
              if (j == 22)
                  begin
                      i <= i + 1;
                      j <= 0;
                  end
              else
                  begin
                      j <= j + 1;
                  end
              X <= xposition + i;
              Y <= yposition + j;
				  
				  if (outcolour == 1'b0)
						begin
							colour <= 3'b000;
						end
				  else
						begin
							colour <= 3'b001;
						end
			if (outcolour == 1'b1)
				begin
				 //putting dollar sign on the board
				 if (yposition>0)
					begin
							if ((i==1) || (i==2))
								if (((j>=6) && (j<=12))||(j==16)||(j==17))
									colour <= 3'b111;
							if ((i==3)||(i==4)||(i==5))
								if (((j>=4) && (j<=7))||(j==11)||(j==12)||((j>=16) && (j<=19))) 
									colour <= 3'b111;
							if ((i==6)||(i==7))
								if ((j==6)||(j==7)||((j>=11) && (j<=17)))
									colour <= 3'b111;
					end
				  
				  //putting category nnumbers on the board
				  if (yposition == 0)
					begin
						//drawing a 1
						if (xposition == 0)
							begin
								if ((i==14) || (i==15) || (i==16))
									begin
										if ((j>=4) && (j<=18))
											begin
												colour <= 3'b111;
											end
									end
							end
						//drawing a 2
						else if (xposition == 8'b100000)
							begin
								if ((j==4) || (j==5) || (j==6) || (j==10) || (j==11) || (j==12) || (j==16) || (j==17) || (j==18))
									begin
										if ((i>=11) && (i<=19))
											begin
												colour <= 3'b111;
											end
									end
								if ((j==7) || (j==8) || (j==9))
									begin
										if ((i==17) || (i==18) || (i==19))
											begin
												colour <= 3'b111;
											end
									end
								if ((j==13) || (j==14) || (j==15))
									begin
										if ((i==11) || (i==12) || (i==13))
											begin
												colour <= 3'b111;
											end
									end
							end
						//drawing a 3
						else if (xposition == 8'b1000000)
							begin
								if ((i==13) || (i==14) || (i==15) || (i==16) || (i==17))
									begin
										if ((j==4) || (j==5) || (j==6) || (j==10) || (j==11) || (j==12) || (j==16) || (j==17) || (j==18))
											begin
												colour <= 3'b111;
											end
									end
								if ((i==18) || (i==19) || (i==20))
									begin
										if ((j>=4) && (j<=18))
											begin
												colour <= 3'b111;
											end
									end
							end
						//drawing a 4
						else if (xposition == 8'b1100000)
							begin
								if ((i==10) || (i==11) || (i==12))
									begin
										if ((j>=4) && (j<=15))
											begin
												colour <= 3'b111;
											end
									end
								if ((i==15) || (i==16) || (i==17))
									begin
										if ((j>=10) && (j<=19))
											begin
												colour <= 3'b111;
											end
									end
								if ((i==13) || (i==14) || (i==18))
									begin
										if ((j==13) || (j==14) || (j==15))
											begin
												colour <= 3'b111;
											end
									end
							end
						//drawing a 5
						else if (xposition == 8'b10000000)
							begin
								if ((j==4) || (j==5) || (j==6) || (j==10) || (j==11) || (j==12) || (j==16) || (j==17) || (j==18))
									begin
										if ((i>=11) && (i<=19))
											begin
												colour <= 3'b111;
											end
									end
								if ((j==7) || (j==8) || (j==9))
									begin
										if ((i==11) || (i==12) || (i==13))
											begin
												colour <= 3'b111;
											end
									end
								if ((j==13) || (j==14) || (j==15))
									begin
										if ((i==17) || (i==18) || (i==19))
											begin
												colour <= 3'b111;
											end
									end
							end
					end
				  
				  //putting '1' on the board
				  if(yposition == 7'b11000)
					begin
						if ((i==11) || (i==12))
							if ((j>=7) && (j<=16))
								colour <= 3'b111;
					end
					
				  //putting '2' on the board
				  if (yposition == 7'b110000)
					begin
						if ((j==7)||(j==8))
							if ((i>=10) && (i<=13))
								colour <= 3'b111;
						if ((j==9)||(j==10)||(j==11)||(j==12))
							if ((i==12)||(i==13))
								colour <= 3'b111;
						if ((j==11)||(j==12))
							if ((i==11)||(i==12))
								colour <= 3'b111;
						if ((j==11)||(j==12)||(j==13)||(j==14))
							if ((i==10)||(i==11))
								colour <= 3'b111;
						if ((j==15)||(j==16))
							if ((i>=10) && (i<=13))
								colour <= 3'b111;
					end
					
					//putting '3' on the board
					if (yposition == 7'b1001000)
					 begin
						if ((i==10)||(i==11)||(i==12))
							if ((j==7)||(j==8)||(j==11)||(j==12)||(j==15)||(j==16))
								colour <= 3'b111;
						if ((i==13)||(i==14))
							if ((j>=7) && (j<=16))
								colour <= 3'b111;
					 end	
					 
					//putting '4' on the board
					if (yposition == 7'b1100000)
					 begin
						if ((i==9)||(i==10))
							if ((j>=7) && (j<=14))
								colour <= 3'b111;
						if ((i==11)||(i==14))
							if ((j==13)||(j==14))
								colour <= 3'b111;
						if ((i==12)||(i==13))
							if ((j>=11) && (j<=16))
								colour <= 3'b111;
					 end

					//putting zeros on the board
					if (yposition>0)
						begin
							if ((i==16)||(i==17)||(i==19)||(i==20)||(i==22)||(i==23)||(i==25)||(i==26))
								if ((j>=7) && (j<=16))
									colour <= 3'b111;
							if ((i==18)||(i==24))
								if ((j==7)||(j==8)||(j==15)||(j==16))
									colour <= 3'b111;
						end
						
			end //only write numbers if in main screen

              if ((i == 30) && (j == 22))
                  begin
                      done_draw <= 1'b1;
							 i <= 0;
							 j <= 0;
                  end
          end
   end
endmodule
