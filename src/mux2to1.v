module mux2to1(x, y, s, m);
    input x; //select 0
    input y; //select 1
    input s; 
    output m; 
  
    assign m = (s & y) | (~s & x);

endmodule 