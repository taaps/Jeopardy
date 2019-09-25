module hexdecoder(input c0, c1, c2, c3, output a, b, c, d, e, f, g);

	// Display a number from 0-15 in hex on the hex displays on the FPGA
	assign a = (~c3&~c2&~c1&c0) + (~c3&c2&~c1&~c0) + (c3&~c2&c1&c0) + (c3&c2&~c1&c0);		  
	assign b = (~c3&c2&~c1&c0) + (~c3&c2&c1&~c0) + (c3&~c2&c1&c0) + (c3&c2&~c1&~c0) + (c3&c2&c1&~c0) + (c3&c2&c1&c0);				  
	assign c = (~c3&~c2&c1&~c0) + (c3&c2&~c1&~c0) + (c3&c2&c1&~c0) + (c3&c2&c1&c0);
	assign d = (~c3&~c2&~c1&c0) + (~c3&c2&~c1&~c0) + (~c3&c2&c1&c0) + (c3&~c2&c1&~c0) + (c3&c2&c1&c0);
	assign e = (~c3&~c2&~c1&c0) + (~c3&~c2&c1&c0) + (~c3&c2&~c1&~c0) + (~c3&c2&~c1&c0) + (~c3&c2&c1&c0) + (c3&~c2&~c1&c0);
	assign f = (~c3&~c2&~c1&c0) + (~c3&~c2&c1&~c0) + (~c3&~c2&c1&c0) + (~c3&c2&c1&c0) + (c3&c2&~c1&c0);
	assign g = (~c3&~c2&~c1&~c0) + (~c3&~c2&~c1&c0) + (~c3&c2&c1&c0) + (c3&c2&~c1&~c0);
							  
endmodule