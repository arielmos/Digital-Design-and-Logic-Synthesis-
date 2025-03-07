//
// Verilog Module Lab1_lib.Stimulus
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 12:03:40 12/ 5/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Stimulus #(
  parameter Amba_Addr_Depth = 10,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8)
( 
   // Port Declarations
   Interface.Stimulus stim_bus
);

`define NULL 0

// Data Types
integer data_file_0;
integer data_file_1;
integer data_file_2;
integer scan_file_0;
integer scan_file_1;
integer scan_file_2;
integer i;


string  str0 = "C:/Users/amitnag/Desktop/Lab1/GoldenModel/parameters_random_value_";
string  str1 = "C:/Users/amitnag/Desktop/Lab1/GoldenModel/primary_image_";
string  str2 = "C:/Users/amitnag/Desktop/Lab1/GoldenModel/watermark_image_";
string  val;

reg [Amba_Word-1:0] primpix;
reg [Amba_Word-1:0] waterpix;
reg [Amba_Word-1:0] param;

reg [Amba_Word-1:0] primsize;
reg [Amba_Word-1:0] watersize;
reg [Amba_Addr_Depth-1:0] count;


always begin : clock_generator_proc
  #5000 stim_bus.clk = ~stim_bus.clk;
end

// we will change only stim_bus.PENABLE
always @(stim_bus.PENABLE) begin : AMBA_impl // they are all 1's or 0's
  stim_bus.PWRITE <= stim_bus.PENABLE;
  stim_bus.PSEL <= stim_bus.PENABLE;
end


initial 
begin : stim_proc
  
  for(i=1;i<11;i=i+1) begin
    // Initilization
    stim_bus.clk = 1; // start with clock and reset at '1', while enable at '0'
    stim_bus.rst = 1;   
    stim_bus.PENABLE = 0;

    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    stim_bus.rst = 0;
    
    // Starting work by reading the data from external files,
    // then sending it to the device by asserting the values to the appropriate ports.
    
    //// The parameters file
    //file_name = {str0, i, txt}; // Concatenation: combining number of elements together as one string
    val.itoa(i);
    //$display($sformatf({str0, val, ".txt"}));
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_0 handle was NULL");
      $finish;
    end
    //// The Primary Image Pixels file
    //file_name = {str1, i, txt}; // Concatenation: combining number of elements together as one string
    val.itoa(i);
    data_file_1 = $fopen($sformatf({str1, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_1 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end
    //// The Watermark Image Pixels file
    //file_name = {str2, i, txt}; // Concatenation: combining number of elements together as one string
    val.itoa(i);
    data_file_2 = $fopen($sformatf({str2, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_2 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_2 handle was NULL");
      $finish;
    end
    
    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    
    //// Reading First Line of each file
    if ((!$feof(data_file_0)) && (!$feof(data_file_1)) && (!$feof(data_file_2))) begin
      scan_file_1 = $fscanf(data_file_1, "%d\n", primsize); // Np
      scan_file_2 = $fscanf(data_file_2, "%d\n", watersize); // Nw
    end

    // parameters enter:
    stim_bus.PADDR = 0; //CTRL  -> 0
    stim_bus.PWDATA = 0; 
    stim_bus.PENABLE=1; //amba
    @(posedge stim_bus.clk); //waiting one clk
    stim_bus.PENABLE=0;
    
    stim_bus.PADDR = 1; //white pixel -> 255
    stim_bus.PWDATA = 255; 
    stim_bus.PENABLE=1; //amba
    @(posedge stim_bus.clk); //waiting one clk
    stim_bus.PENABLE=0;
    
    stim_bus.PADDR = 2; //Np
    stim_bus.PWDATA = primsize; 
    stim_bus.PENABLE=1; //amba
    @(posedge stim_bus.clk); //waiting one clk
    
    stim_bus.PADDR = 3; //Nw
    stim_bus.PWDATA = watersize; 
    stim_bus.PENABLE=1; //amba
    @(posedge stim_bus.clk); //waiting one clk
    stim_bus.PENABLE=0;
    
    count= 4;
    for (;count<10;count++) 
    begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", param); //scan next param from file
      stim_bus.PADDR = count; //count is the register number
      stim_bus.PWDATA = param; 
      stim_bus.PENABLE=1; //amba
      @(posedge stim_bus.clk); //waiting one clk
      stim_bus.PENABLE=0;
    end
    
    // enter images:
    count = 0;
    for (;count<primsize*primsize;count++) // enter image
    begin
      scan_file_1 = $fscanf(data_file_1, "%d\n", primpix); // Im(x,y)
      stim_bus.PADDR = count+10; //count+10 is the register number
      stim_bus.PWDATA = primpix; 
      stim_bus.PENABLE=1; //amba
      @(posedge stim_bus.clk); //waiting one clk
      stim_bus.PENABLE=0;
    end
    count = 0;
    for (;count<watersize*watersize;count++)  // enter watermark
    begin
      scan_file_2 = $fscanf(data_file_2, "%d\n", waterpix); // W(x,y)
      stim_bus.PADDR = count+primsize*primsize+10; //count+primsize*primsize+10 is the register number
      stim_bus.PWDATA = waterpix; 
      stim_bus.PENABLE=1; //amba
      @(posedge stim_bus.clk); //waiting one clk
      stim_bus.PENABLE=0;
    end 
    
    // put 1 in start bit:
    stim_bus.PADDR = 0; //CTRL  -> 1
    stim_bus.PWDATA = 1; 
    stim_bus.PENABLE=1; //amba
    @(posedge stim_bus.clk); //waiting one clk
    stim_bus.PENABLE=0;   
    
    @(posedge stim_bus.Image_Done); // wait til image is done
    // ?!
  end
  $stop;
end

endmodule

