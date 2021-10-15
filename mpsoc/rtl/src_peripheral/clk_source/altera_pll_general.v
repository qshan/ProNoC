module altera_pll_general #(
	parameter DEVICE_FAMILY="Cyclone",
	parameter INPUT_FREQUENCY =50000,// input frequency in KHz	
	parameter CLKOUT_NUM=6,   // number of output clk 1-6

	parameter CLKOUT0_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT0_DIVIDE = 1,
	parameter CLKOUT0_MULTIPLY=1,
	parameter CLKOUT0_PHASE="0",

	parameter CLKOUT1_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT1_DIVIDE = 1,
	parameter CLKOUT1_MULTIPLY=1,
	parameter CLKOUT1_PHASE="0",


	parameter CLKOUT2_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT2_DIVIDE = 1,
	parameter CLKOUT2_MULTIPLY=1,
	parameter CLKOUT2_PHASE="0",


	parameter CLKOUT3_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT3_DIVIDE = 1,
	parameter CLKOUT3_MULTIPLY=1,
	parameter CLKOUT3_PHASE="0",


	parameter CLKOUT4_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT4_DIVIDE = 1,
	parameter CLKOUT4_MULTIPLY=1,
	parameter CLKOUT4_PHASE="0",

	parameter CLKOUT5_DUTY_CYCLE=50, // 0~100
	parameter CLKOUT5_DIVIDE = 1,
	parameter CLKOUT5_MULTIPLY=1,
	parameter CLKOUT5_PHASE="0"

)(
	input clk_in,     // 1-bit input: Input clock 
    	output [CLKOUT_NUM-1: 0] clk_out,   
	output reset_out,     // 1-bit output: LOCK                                
        input reset_in           // 1-bit input: Reset                         
	
)

	wire locked;
	wire [1: 0 ] inclk = {1'b0,clk_in};

	localparam
		inclk0_input_frequency = INPUT_FREQUENCY/10,
		PORT_CLK0 = (CLKOUT_NUM>0)? "PORT_USED" : "PORT_UNUSED",
		PORT_CLK1 = (CLKOUT_NUM>1)? "PORT_USED" : "PORT_UNUSED",
		PORT_CLK2 = (CLKOUT_NUM>2)? "PORT_USED" : "PORT_UNUSED",
		PORT_CLK3 = (CLKOUT_NUM>3)? "PORT_USED" : "PORT_UNUSED",
		PORT_CLK4 = (CLKOUT_NUM>4)? "PORT_USED" : "PORT_UNUSED",
		PORT_CLK5 = (CLKOUT_NUM>5)? "PORT_USED" : "PORT_UNUSED";




	altpll #(
		.inclk0_input_frequency(inclk0_input_frequency),
		.width_clock(CLKOUT_NUM),
		.intended_device_family(DEVICE_FAMILY),
		
		.clk0_duty_cycle(CLKOUT0_DUTY_CYCLE),
		.clk0_multiply_by(CLKOUT0_MULTIPLY),
		.clk0_divide_by(CLKOUT0_DIVIDE),
		.clk0_phase_shift(CLKOUT0_PHASE),

		.clk1_duty_cycle(CLKOUT1_DUTY_CYCLE),
		.clk1_multiply_by(CLKOUT1_MULTIPLY),
		.clk1_divide_by(CLKOUT1_DIVIDE),
		.clk1_phase_shift(CLKOUT1_PHASE),

		.clk2_duty_cycle(CLKOUT2_DUTY_CYCLE),
		.clk2_multiply_by(CLKOUT2_MULTIPLY),
		.clk2_divide_by(CLKOUT2_DIVIDE),
		.clk2_phase_shift(CLKOUT2_PHASE),

		.clk3_duty_cycle(CLKOUT3_DUTY_CYCLE),
		.clk3_multiply_by(CLKOUT3_MULTIPLY),
		.clk3_divide_by(CLKOUT3_DIVIDE),
		.clk3_phase_shift(CLKOUT3_PHASE),

		.clk4_duty_cycle(CLKOUT4_DUTY_CYCLE),
		.clk4_multiply_by(CLKOUT4_MULTIPLY),
		.clk4_divide_by(CLKOUT4_DIVIDE),
		.clk4_phase_shift(CLKOUT4_PHASE),

		.clk5_duty_cycle(CLKOUT5_DUTY_CYCLE),
		.clk5_multiply_by(CLKOUT5_MULTIPLY),
		.clk5_divide_by(CLKOUT5_DIVIDE),
		.clk5_phase_shift(CLKOUT5_PHASE),

		.bandwidth_type("AUTO"),
		.compensate_clock("CLK0"),
		.operation_mode("NORMAL"),
		
		.port_areset ( "PORT_USED"),
		.port_inclk0 ( "PORT_USED"),
		.port_locked ( "PORT_USED"),

		.port_clk0 ( PORT_CLK0 ),
		.port_clk1 ( PORT_CLK1 ),
		.port_clk2 ( PORT_CLK2 ),
		.port_clk3 ( PORT_CLK3 ),
		.port_clk4 ( PORT_CLK4 ),
		.port_clk5 ( PORT_CLK5 ),

		.port_activeclock ( "PORT_UNUSED"),		
		.port_clkbad0 ( "PORT_UNUSED"),
		.port_clkbad1 ( "PORT_UNUSED"),
		.port_clkloss ( "PORT_UNUSED"),
		.port_clkswitch ( "PORT_UNUSED"),
		.port_configupdate ( "PORT_UNUSED"),
		.port_fbin ( "PORT_UNUSED"),		
		.port_inclk1 ( "PORT_UNUSED"),		
		.port_pfdena ( "PORT_UNUSED"),
		.port_phasecounterselect ( "PORT_UNUSED"),
		.port_phasedone ( "PORT_UNUSED"),
		.port_phasestep ( "PORT_UNUSED"),
		.port_phaseupdown ( "PORT_UNUSED"),
		.port_pllena ( "PORT_UNUSED"),
		.port_scanaclr ( "PORT_UNUSED"),
		.port_scanclk ( "PORT_UNUSED"),
		.port_scanclkena ( "PORT_UNUSED"),
		.port_scandata ( "PORT_UNUSED"),
		.port_scandataout ( "PORT_UNUSED"),
		.port_scandone ( "PORT_UNUSED"),
		.port_scanread ( "PORT_UNUSED"),
		.port_scanwrite ( "PORT_UNUSED"),
		.port_clkena0 ( "PORT_UNUSED"),
		.port_clkena1 ( "PORT_UNUSED"),
		.port_clkena2 ( "PORT_UNUSED"),
		.port_clkena3 ( "PORT_UNUSED"),
		.port_clkena4 ( "PORT_UNUSED"),
		.port_clkena5 ( "PORT_UNUSED"),
		.port_extclk0 ( "PORT_UNUSED"),
		.port_extclk1 ( "PORT_UNUSED"),
		.port_extclk2 ( "PORT_UNUSED"),
		.port_extclk3 ( "PORT_UNUSED"),















	
	) 
	altera_pll_i
	(
		.inclk(inclk),	
		.clk(clk_out),
		.locked (locked),
		.areset(reset_in)
		
	);

	assign reset_out =~locked;


endmodule










// megafunction wizard: %ALTPLL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altpll 

// ============================================================
// File Name: pll.v
// Megafunction Name(s):
// 			altpll
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 4.0 Build 214 3/25/2004 SP 1 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2004 Altera Corporation
//Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
//support information,  device programming or simulation file,  and any other
//associated  documentation or information  provided by  Altera  or a partner
//under  Altera's   Megafunction   Partnership   Program  may  be  used  only
//to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
//other  use  of such  megafunction  design,  netlist,  support  information,
//device programming or simulation file,  or any other  related documentation
//or information  is prohibited  for  any  other purpose,  including, but not
//limited to  modification,  reverse engineering,  de-compiling, or use  with
//any other  silicon devices,  unless such use is  explicitly  licensed under
//a separate agreement with  Altera  or a megafunction partner.  Title to the
//intellectual property,  including patents,  copyrights,  trademarks,  trade
//secrets,  or maskworks,  embodied in any such megafunction design, netlist,
//support  information,  device programming or simulation file,  or any other
//related documentation or information provided by  Altera  or a megafunction
//partner, remains with Altera, the megafunction partner, or their respective
//licensors. No other licenses, including any licenses needed under any third
//party's intellectual property, are provided herein.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module pll (
	inclk0,
	c0);

	input	  inclk0;
	output	  c0;

	wire [5:0] sub_wire0;
	wire [0:0] sub_wire4 = 1'h0;
	wire [0:0] sub_wire1 = sub_wire0[0:0];
	wire  c0 = sub_wire1;
	wire  sub_wire2 = inclk0;
	wire [1:0] sub_wire3 = {sub_wire4, sub_wire2};

	altpll	altpll_component (
				.inclk (sub_wire3),
				.clk (sub_wire0)
				// synopsys translate_off
,
				.fbin (),
				.pllena (),
				.clkswitch (),
				.areset (),
				.pfdena (),
				.clkena (),
				.extclkena (),
				.scanclk (),
				.scanaclr (),
				.scandata (),
				.scanread (),
				.scanwrite (),
				.extclk (),
				.clkbad (),
				.activeclock (),
				.locked (),
				.clkloss (),
				.scandataout (),
				.scandone (),
				.sclkout1 (),
				.sclkout0 (),
				.enable0 (),
				.enable1 ()
				// synopsys translate_on

);
	defparam
		altpll_component.clk0_duty_cycle = 50,
		altpll_component.lpm_type = "altpll",
		altpll_component.clk0_multiply_by = 1,
		altpll_component.inclk0_input_frequency = 20833,
		altpll_component.clk0_divide_by = 1,
		altpll_component.pll_type = "AUTO",
		altpll_component.clk0_time_delay = "0",
		altpll_component.intended_device_family = "Cyclone",
		altpll_component.operation_mode = "NORMAL",
		altpll_component.compensate_clock = "CLK0",
		altpll_component.clk0_phase_shift = "-3000";


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: MIRROR_CLK0 STRING "0"
// Retrieval info: PRIVATE: PHASE_SHIFT_UNIT0 STRING "ns"
// Retrieval info: PRIVATE: OUTPUT_FREQ_UNIT0 STRING "MHz"
// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_COMBO STRING "MHz"
// Retrieval info: PRIVATE: SPREAD_USE STRING "0"
// Retrieval info: PRIVATE: SPREAD_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: GLOCKED_COUNTER_EDIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: GLOCK_COUNTER_EDIT NUMERIC "1048575"
// Retrieval info: PRIVATE: SRC_SYNCH_COMP_RADIO STRING "0"
// Retrieval info: PRIVATE: DUTY_CYCLE0 STRING "50.00000000"
// Retrieval info: PRIVATE: PHASE_SHIFT0 STRING "-3.00000000"
// Retrieval info: PRIVATE: MULT_FACTOR0 NUMERIC "1"
// Retrieval info: PRIVATE: OUTPUT_FREQ_MODE0 STRING "0"
// Retrieval info: PRIVATE: SPREAD_PERCENT STRING "0.500"
// Retrieval info: PRIVATE: LOCKED_OUTPUT_CHECK STRING "0"
// Retrieval info: PRIVATE: PLL_ARESET_CHECK STRING "0"
// Retrieval info: PRIVATE: TIME_SHIFT0 STRING "0.00000000"
// Retrieval info: PRIVATE: STICKY_CLK0 STRING "1"
// Retrieval info: PRIVATE: BANDWIDTH STRING "1.000"
// Retrieval info: PRIVATE: BANDWIDTH_USE_CUSTOM STRING "0"
// Retrieval info: PRIVATE: DEVICE_SPEED_GRADE STRING "8"
// Retrieval info: PRIVATE: SPREAD_FREQ STRING "50.000"
// Retrieval info: PRIVATE: BANDWIDTH_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: LONG_SCAN_RADIO STRING "1"
// Retrieval info: PRIVATE: PLL_ENHPLL_CHECK NUMERIC "0"
// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE_DIRTY NUMERIC "0"
// Retrieval info: PRIVATE: USE_CLK0 STRING "1"
// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: SCAN_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: ZERO_DELAY_RADIO STRING "0"
// Retrieval info: PRIVATE: PLL_PFDENA_CHECK STRING "0"
// Retrieval info: PRIVATE: CREATE_CLKBAD_CHECK STRING "0"
// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT STRING "100.000"
// Retrieval info: PRIVATE: CUR_DEDICATED_CLK STRING "c0"
// Retrieval info: PRIVATE: PLL_FASTPLL_CHECK NUMERIC "0"
// Retrieval info: PRIVATE: ACTIVECLK_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_FREQ_UNIT STRING "MHz"
// Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_0 STRING "inclk;fbin;pllena;clkswitch;areset"
// Retrieval info: PRIVATE: GLOCKED_MODE_CHECK STRING "0"
// Retrieval info: PRIVATE: NORMAL_MODE_RADIO STRING "1"
// Retrieval info: PRIVATE: CUR_FBIN_CLK STRING "e0"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_1 STRING "pfdena;clkena;extclkena;scanclk;scanaclr"
// Retrieval info: PRIVATE: DIV_FACTOR0 NUMERIC "1"
// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: HAS_MANUAL_SWITCHOVER STRING "1"
// Retrieval info: PRIVATE: EXT_FEEDBACK_RADIO STRING "0"
// Retrieval info: PRIVATE: PLL_AUTOPLL_CHECK NUMERIC "1"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_2 STRING "scandata;scanread;scanwrite;clk;extclk"
// Retrieval info: PRIVATE: CLKLOSS_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_USE_AUTO STRING "1"
// Retrieval info: PRIVATE: SHORT_SCAN_RADIO STRING "0"
// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE STRING "528.000"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_3 STRING "clkbad;activeclock;locked;clkloss;scandataout"
// Retrieval info: PRIVATE: CLKSWITCH_CHECK STRING "0"
// Retrieval info: PRIVATE: SPREAD_FREQ_UNIT STRING "KHz"
// Retrieval info: PRIVATE: PLL_ENA_CHECK STRING "0"
// Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING "48.000"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_4 STRING "scandone;sclkout1;sclkout0;enable0;enable1"
// Retrieval info: PRIVATE: CNX_NO_COMPENSATE_RADIO STRING "0"
// Retrieval info: PRIVATE: INT_FEEDBACK__MODE_RADIO STRING "1"
// Retrieval info: PRIVATE: OUTPUT_FREQ0 STRING "100.000"
// Retrieval info: PRIVATE: PRIMARY_CLK_COMBO STRING "inclk0"
// Retrieval info: PRIVATE: CREATE_INCLK1_CHECK STRING "0"
// Retrieval info: PRIVATE: SACN_INPUTS_CHECK STRING "0"
// Retrieval info: PRIVATE: DEV_FAMILY STRING "Cyclone"
// Retrieval info: PRIVATE: LOCK_LOSS_SWITCHOVER_CHECK STRING "0"
// Retrieval info: PRIVATE: SWITCHOVER_COUNT_EDIT NUMERIC "1"
// Retrieval info: PRIVATE: SWITCHOVER_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_PRESET STRING "Low"
// Retrieval info: PRIVATE: GLOCKED_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: USE_CLKENA0 STRING "0"
// Retrieval info: PRIVATE: LVDS_PHASE_SHIFT_UNIT0 STRING "deg"
// Retrieval info: PRIVATE: CLKBAD_SWITCHOVER_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_USE_PRESET STRING "0"
// Retrieval info: PRIVATE: PLL_LVDS_PLL_CHECK NUMERIC "0"
// Retrieval info: PRIVATE: DEVICE_FAMILY NUMERIC "11"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: CLK0_DUTY_CYCLE NUMERIC "50"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altpll"
// Retrieval info: CONSTANT: CLK0_MULTIPLY_BY NUMERIC "1"
// Retrieval info: CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC "20833"
// Retrieval info: CONSTANT: CLK0_DIVIDE_BY NUMERIC "1"
// Retrieval info: CONSTANT: PLL_TYPE STRING "AUTO"
// Retrieval info: CONSTANT: CLK0_TIME_DELAY STRING "0"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "NORMAL"
// Retrieval info: CONSTANT: COMPENSATE_CLOCK STRING "CLK0"
// Retrieval info: CONSTANT: CLK0_PHASE_SHIFT STRING "-3000"
// Retrieval info: USED_PORT: c0 0 0 0 0 OUTPUT VCC "c0"
// Retrieval info: USED_PORT: @clk 0 0 6 0 OUTPUT VCC "@clk[5..0]"
// Retrieval info: USED_PORT: inclk0 0 0 0 0 INPUT GND "inclk0"
// Retrieval info: USED_PORT: @extclk 0 0 4 0 OUTPUT VCC "@extclk[3..0]"
// Retrieval info: CONNECT: @inclk 0 0 1 0 inclk0 0 0 0 0
// Retrieval info: CONNECT: c0 0 0 0 0 @clk 0 0 1 0
// Retrieval info: CONNECT: @inclk 0 0 1 1 GND 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL pll.v TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll.inc FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll.cmp FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll.bsf FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll_inst.v TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll_bb.v TRUE FALSE




// megafunction wizard: %ALTPLL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altpll 

// ============================================================
// File Name: amiga_clk_altera.v
// Megafunction Name(s):
// 			altpll
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.0.1 Build 232 06/12/2013 SP 1 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module amiga_clk_altera (
	areset,
	inclk0,
	c0,
	c1,
	c2,
	locked);

	input	  areset;
	input	  inclk0;
	output	  c0;
	output	  c1;
	output	  c2;
	output	  locked;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  areset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [4:0] sub_wire0;
	wire  sub_wire2;
	wire [0:0] sub_wire7 = 1'h0;
	wire [2:2] sub_wire4 = sub_wire0[2:2];
	wire [0:0] sub_wire3 = sub_wire0[0:0];
	wire [1:1] sub_wire1 = sub_wire0[1:1];
	wire  c1 = sub_wire1;
	wire  locked = sub_wire2;
	wire  c0 = sub_wire3;
	wire  c2 = sub_wire4;
	wire  sub_wire5 = inclk0;
	wire [1:0] sub_wire6 = {sub_wire7, sub_wire5};

	altpll	altpll_component (
				.areset (areset),
				.inclk (sub_wire6),
				.clk (sub_wire0),
				.locked (sub_wire2),
				.activeclock (),
				.clkbad (),
				.clkena ({6{1'b1}}),
				.clkloss (),
				.clkswitch (1'b0),
				.configupdate (1'b0),
				.enable0 (),
				.enable1 (),
				.extclk (),
				.extclkena ({4{1'b1}}),
				.fbin (1'b1),
				.fbmimicbidir (),
				.fbout (),
				.fref (),
				.icdrclk (),
				.pfdena (1'b1),
				.phasecounterselect ({4{1'b1}}),
				.phasedone (),
				.phasestep (1'b1),
				.phaseupdown (1'b1),
				.pllena (1'b1),
				.scanaclr (1'b0),
				.scanclk (1'b0),
				.scanclkena (1'b1),
				.scandata (1'b0),
				.scandataout (),
				.scandone (),
				.scanread (1'b0),
				.scanwrite (1'b0),
				.sclkout0 (),
				.sclkout1 (),
				.vcooverrange (),
				.vcounderrange ());
	defparam
		altpll_component.bandwidth_type = "LOW",
		altpll_component.clk0_divide_by = 4,
		altpll_component.clk0_duty_cycle = 50,
		altpll_component.clk0_multiply_by = 17,
		altpll_component.clk0_phase_shift = "-3540",
		altpll_component.clk1_divide_by = 4,
		altpll_component.clk1_duty_cycle = 50,
		altpll_component.clk1_multiply_by = 17,
		altpll_component.clk1_phase_shift = "0",
		altpll_component.clk2_divide_by = 16,
		altpll_component.clk2_duty_cycle = 50,
		altpll_component.clk2_multiply_by = 17,
		altpll_component.clk2_phase_shift = "0",
		altpll_component.compensate_clock = "CLK0",
		altpll_component.inclk0_input_frequency = 37037,
		altpll_component.intended_device_family = "Cyclone III",
		altpll_component.lpm_hint = "CBX_MODULE_PREFIX=amiga_clk_altera",
		altpll_component.lpm_type = "altpll",
		altpll_component.operation_mode = "ZERO_DELAY_BUFFER",
		altpll_component.pll_type = "AUTO",
		altpll_component.port_activeclock = "PORT_UNUSED",
		altpll_component.port_areset = "PORT_USED",
		altpll_component.port_clkbad0 = "PORT_UNUSED",
		altpll_component.port_clkbad1 = "PORT_UNUSED",
		altpll_component.port_clkloss = "PORT_UNUSED",
		altpll_component.port_clkswitch = "PORT_UNUSED",
		altpll_component.port_configupdate = "PORT_UNUSED",
		altpll_component.port_fbin = "PORT_UNUSED",
		altpll_component.port_inclk0 = "PORT_USED",
		altpll_component.port_inclk1 = "PORT_UNUSED",
		altpll_component.port_locked = "PORT_USED",
		altpll_component.port_pfdena = "PORT_UNUSED",
		altpll_component.port_phasecounterselect = "PORT_UNUSED",
		altpll_component.port_phasedone = "PORT_UNUSED",
		altpll_component.port_phasestep = "PORT_UNUSED",
		altpll_component.port_phaseupdown = "PORT_UNUSED",
		altpll_component.port_pllena = "PORT_UNUSED",
		altpll_component.port_scanaclr = "PORT_UNUSED",
		altpll_component.port_scanclk = "PORT_UNUSED",
		altpll_component.port_scanclkena = "PORT_UNUSED",
		altpll_component.port_scandata = "PORT_UNUSED",
		altpll_component.port_scandataout = "PORT_UNUSED",
		altpll_component.port_scandone = "PORT_UNUSED",
		altpll_component.port_scanread = "PORT_UNUSED",
		altpll_component.port_scanwrite = "PORT_UNUSED",
		altpll_component.port_clk0 = "PORT_USED",
		altpll_component.port_clk1 = "PORT_USED",
		altpll_component.port_clk2 = "PORT_USED",
		altpll_component.port_clk3 = "PORT_UNUSED",
		altpll_component.port_clk4 = "PORT_UNUSED",
		altpll_component.port_clk5 = "PORT_UNUSED",
		altpll_component.port_clkena0 = "PORT_UNUSED",
		altpll_component.port_clkena1 = "PORT_UNUSED",
		altpll_component.port_clkena2 = "PORT_UNUSED",
		altpll_component.port_clkena3 = "PORT_UNUSED",
		altpll_component.port_clkena4 = "PORT_UNUSED",
		altpll_component.port_clkena5 = "PORT_UNUSED",
		altpll_component.port_extclk0 = "PORT_UNUSED",
		altpll_component.port_extclk1 = "PORT_UNUSED",
		altpll_component.port_extclk2 = "PORT_UNUSED",
		altpll_component.port_extclk3 = "PORT_UNUSED",
		altpll_component.self_reset_on_loss_lock = "OFF",
		altpll_component.width_clock = 5;


endmodule

/*****************************



***************************/



module altpll ( 
// INTERFACE BEGIN
	inclk, fbin, pllena, clkswitch, areset, pfdena, clkena, extclkena,
	scanclk, scanaclr, scandata, scanread, scanwrite, clk, extclk, clkbad,
	activeclock, clkloss, locked ,scandataout, scandone, sclkout0, sclkout1,
	enable0, enable1, configupdate, fbout, phasecounterselect, phasedone, 
	phasestep, phaseupdown, scanclkena, vcooverrange, vcounderrange, fbmimicbidir, fref, icdrclk
);

// INTERFACE END
//// default parameters ////

	parameter intended_device_family = "NONE";
	parameter operation_mode = "unused";
	parameter pll_type = "AUTO";
	parameter qualify_conf_done = "OFF";
	parameter compensate_clock = "CLK0";
	parameter scan_chain = "LONG";
	parameter primary_clock = "INCLK0";
	parameter inclk0_input_frequency = 1;
	parameter inclk1_input_frequency = 0;
	parameter gate_lock_signal = "NO";
	parameter gate_lock_counter = 0;
	parameter lock_high = 1;
	parameter lock_low = 1;
	parameter valid_lock_multiplier = 1;
	parameter invalid_lock_multiplier = 5;
	parameter switch_over_type = "AUTO";
	parameter switch_over_on_lossclk = "OFF" ;
	parameter switch_over_on_gated_lock = "OFF" ;
	parameter switch_over_counter = 0;
	parameter enable_switch_over_counter = "OFF";
	parameter feedback_source = "EXTCLK0" ;
	parameter bandwidth = 0;
	parameter bandwidth_type = "AUTO";
	parameter spread_frequency = 0;
	parameter down_spread = "0";
	parameter simulation_type = "functional";
	parameter source_is_pll = "off";
	parameter skip_vco = "OFF";
	parameter clk5_multiply_by = 1;
	parameter clk4_multiply_by = 1;
	parameter clk3_multiply_by = 1;
	parameter clk2_multiply_by = 1;
	parameter clk1_multiply_by = 1;
	parameter clk0_multiply_by = 1;
	parameter clk5_divide_by = 1;
	parameter clk4_divide_by = 1;
	parameter clk3_divide_by = 1;
	parameter clk2_divide_by = 1;
	parameter clk1_divide_by = 1;
	parameter clk0_divide_by = 1;
	parameter clk5_phase_shift = "0";
	parameter clk4_phase_shift = "0";
	parameter clk3_phase_shift = "0";
	parameter clk2_phase_shift = "0";
	parameter clk1_phase_shift = "0";
	parameter clk0_phase_shift = "0";
	parameter clk5_time_delay = "0";
	parameter clk4_time_delay = "0";
	parameter clk3_time_delay = "0";
	parameter clk2_time_delay = "0";
	parameter clk1_time_delay = "0";
	parameter clk0_time_delay = "0";
	parameter clk5_duty_cycle = 50;
	parameter clk4_duty_cycle = 50;
	parameter clk3_duty_cycle = 50;
	parameter clk2_duty_cycle = 50;
	parameter clk1_duty_cycle = 50;
	parameter clk0_duty_cycle = 50;
	parameter extclk3_multiply_by = 1;
	parameter extclk2_multiply_by = 1;
	parameter extclk1_multiply_by = 1;
	parameter extclk0_multiply_by = 1;
	parameter extclk3_divide_by = 1;
	parameter extclk2_divide_by = 1;
	parameter extclk1_divide_by = 1;
	parameter extclk0_divide_by = 1;
	parameter extclk3_phase_shift = "0";
	parameter extclk2_phase_shift = "0";
	parameter extclk1_phase_shift = "0";
	parameter extclk0_phase_shift = "0";
	parameter extclk3_time_delay = "0";
	parameter extclk2_time_delay = "0";
	parameter extclk1_time_delay = "0";
	parameter extclk0_time_delay = "0";
	parameter extclk3_duty_cycle = 50;
	parameter extclk2_duty_cycle = 50;
	parameter extclk1_duty_cycle = 50;
	parameter extclk0_duty_cycle = 50;
	parameter vco_min = 0;
	parameter vco_max = 0;
	parameter vco_center = 0;
	parameter pfd_min = 0;
	parameter pfd_max = 0;
	parameter m_initial = 0;
	parameter m = 0;
	parameter n = 1;
	parameter m2 = 1;
	parameter n2 = 1;
	parameter ss = 1;
	parameter l0_high = 1;
	parameter l1_high = 1;
	parameter g0_high = 1;
	parameter g1_high = 1;
	parameter g2_high = 1;
	parameter g3_high = 1;
	parameter e0_high = 1;
	parameter e1_high = 1;
	parameter e2_high = 1;
	parameter e3_high = 1;
	parameter l0_low = 1;
	parameter l1_low = 1;
	parameter g0_low = 1;
	parameter g1_low = 1;
	parameter g2_low = 1;
	parameter g3_low = 1;
	parameter e0_low = 1;
	parameter e1_low = 1;
	parameter e2_low = 1;
	parameter e3_low = 1;
	parameter l0_initial = 1;
	parameter l1_initial = 1;
	parameter g0_initial = 1;
	parameter g1_initial = 1;
	parameter g2_initial = 1;
	parameter g3_initial = 1;
	parameter e0_initial = 1;
	parameter e1_initial = 1;
	parameter e2_initial = 1;
	parameter e3_initial = 1;
	parameter l0_mode = "BYPASS" ;
	parameter l1_mode = "BYPASS" ;
	parameter g0_mode = "BYPASS" ;
	parameter g1_mode = "BYPASS" ;
	parameter g2_mode = "BYPASS" ;
	parameter g3_mode = "BYPASS" ;
	parameter e0_mode = "BYPASS" ;
	parameter e1_mode = "BYPASS" ;
	parameter e2_mode = "BYPASS" ;
	parameter e3_mode = "BYPASS" ;
	parameter l0_ph = 0;
	parameter l1_ph = 0;
	parameter g0_ph = 0;
	parameter g1_ph = 0;
	parameter g2_ph = 0;
	parameter g3_ph = 0;
	parameter e0_ph = 0;
	parameter e1_ph = 0;
	parameter e2_ph = 0;
	parameter e3_ph = 0;
	parameter m_ph = 0;
	parameter l0_time_delay = 0;
	parameter l1_time_delay = 0;
	parameter g0_time_delay = 0;
	parameter g1_time_delay = 0;
	parameter g2_time_delay = 0;
	parameter g3_time_delay = 0;
	parameter e0_time_delay = 0;
	parameter e1_time_delay = 0;
	parameter e2_time_delay = 0;
	parameter e3_time_delay = 0;
	parameter m_time_delay = 0;
	parameter n_time_delay = 0;
	parameter extclk3_counter = "E3" ;
	parameter extclk2_counter = "E2" ;
	parameter extclk1_counter = "E1" ;
	parameter extclk0_counter = "E0" ;
	parameter clk5_counter = "G0" ;
	parameter clk4_counter = "G0" ;
	parameter clk3_counter = "G0" ;
	parameter clk2_counter = "G0" ;
	parameter clk1_counter = "G0" ;
	parameter clk0_counter = "G0" ;
	parameter charge_pump_current = 2;
	parameter loop_filter_r = " 1.000000";
	parameter loop_filter_c = 5;
	parameter lpm_type = "altpll";
	parameter lpm_hint = "UNUSED";
	parameter c0_high = 0;
	parameter c0_initial = 0;
	parameter c0_low = 0;
	parameter c0_mode = "BYPASS";
	parameter c0_ph = 0;
	parameter c1_high = 0;
	parameter c1_initial = 0;
	parameter c1_low = 0;
	parameter c1_mode = "BYPASS";
	parameter c1_ph = 0;
	parameter c1_use_casc_in = "OFF";
	parameter c2_high = 0;
	parameter c2_initial = 0;
	parameter c2_low = 0;
	parameter c2_mode = "BYPASS";
	parameter c2_ph = 0;
	parameter c2_use_casc_in = "OFF";
	parameter c3_high = 0;
	parameter c3_initial = 0;
	parameter c3_low = 0;
	parameter c3_mode = "BYPASS";
	parameter c3_ph = 0;
	parameter c3_use_casc_in = "OFF";
	parameter c4_high = 0;
	parameter c4_initial = 0;
	parameter c4_low = 0;
	parameter c4_mode = "BYPASS";
	parameter c4_ph = 0;
	parameter c4_use_casc_in = "OFF";
	parameter c5_high = 0;
	parameter c5_initial = 0;
	parameter c5_low = 0;
	parameter c5_mode = "BYPASS";
	parameter c5_ph = 0;
	parameter c5_use_casc_in = "OFF";
	parameter enable0_counter = "L0";
	parameter enable1_counter = "L0";
	parameter sclkout0_phase_shift = "0";
	parameter sclkout1_phase_shift = "0";
	parameter vco_divide_by = 0;
	parameter vco_multiply_by = 0;
	parameter vco_post_scale = 0;
	parameter clk0_output_frequency = 0;
	parameter clk1_output_frequency = 0;
	parameter clk2_output_frequency = 0;
	parameter c0_test_source = 5;
	parameter c1_test_source = 5;
	parameter c2_test_source = 5;
	parameter c3_test_source = 5;
	parameter c4_test_source = 5;
	parameter c5_test_source = 5;
	parameter m_test_source = 5;

	parameter port_activeclock = "PORT_CONNECTIVITY";
	parameter port_clkbad0 = "PORT_CONNECTIVITY";
	parameter port_clkbad1 = "PORT_CONNECTIVITY";
	parameter port_clkena0 = "PORT_CONNECTIVITY";
	parameter port_clkena1 = "PORT_CONNECTIVITY";
	parameter port_clkena2 = "PORT_CONNECTIVITY";
	parameter port_clkena3 = "PORT_CONNECTIVITY";
	parameter port_clkena4 = "PORT_CONNECTIVITY";
	parameter port_clkena5 = "PORT_CONNECTIVITY";
	parameter port_clkloss = "PORT_CONNECTIVITY";
	parameter port_extclk0 = "PORT_CONNECTIVITY";
	parameter port_extclk1 = "PORT_CONNECTIVITY";
	parameter port_extclk2 = "PORT_CONNECTIVITY";
	parameter port_extclk3 = "PORT_CONNECTIVITY";
	parameter port_extclkena0 = "PORT_CONNECTIVITY";
	parameter port_extclkena1 = "PORT_CONNECTIVITY";
	parameter port_extclkena2 = "PORT_CONNECTIVITY";
	parameter port_extclkena3 = "PORT_CONNECTIVITY";

	parameter port_areset = "PORT_CONNECTIVITY";
	parameter port_clk0 = "PORT_CONNECTIVITY";
	parameter port_clk1 = "PORT_CONNECTIVITY";
	parameter port_clk2 = "PORT_CONNECTIVITY";
	parameter port_clk3 = "PORT_CONNECTIVITY";
	parameter port_clk4 = "PORT_CONNECTIVITY";
	parameter port_clk5 = "PORT_CONNECTIVITY";
	parameter port_clk6 = "PORT_CONNECTIVITY";
	parameter port_clk7 = "PORT_CONNECTIVITY";
	parameter port_clk8 = "PORT_CONNECTIVITY";
	parameter port_clk9 = "PORT_CONNECTIVITY";
	parameter port_clkswitch = "PORT_CONNECTIVITY";
	parameter port_enable0 = "PORT_CONNECTIVITY";
	parameter port_enable1 = "PORT_CONNECTIVITY";
	parameter port_fbin = "PORT_CONNECTIVITY";
	parameter port_inclk0 = "PORT_CONNECTIVITY";
	parameter port_inclk1 = "PORT_CONNECTIVITY";
	parameter port_pfdena = "PORT_CONNECTIVITY";
	parameter port_pllena = "PORT_CONNECTIVITY";
	parameter port_scanaclr = "PORT_CONNECTIVITY";
	parameter port_scanclk = "PORT_CONNECTIVITY";
	parameter port_scandata = "PORT_CONNECTIVITY";
	parameter port_scandataout = "PORT_CONNECTIVITY";
	parameter port_scandone = "PORT_CONNECTIVITY";
	parameter port_scanread = "PORT_CONNECTIVITY";
	parameter port_scanwrite = "PORT_CONNECTIVITY";
	parameter port_sclkout0 = "PORT_CONNECTIVITY";
	parameter port_sclkout1 = "PORT_CONNECTIVITY";
	parameter self_reset_on_gated_loss_lock = "OFF";
	parameter port_locked = "PORT_CONNECTIVITY";
	parameter port_vcooverrange = "PORT_CONNECTIVITY";
	parameter port_vcounderrange = "PORT_CONNECTIVITY";
	parameter width_phasecounterselect = 4;



	parameter c6_high = 0;
	parameter c6_initial = 0;
	parameter c6_low = 0;
	parameter c6_mode = "BYPASS";
	parameter c6_ph = 0;
	parameter c6_test_source = 5;
	parameter c6_use_casc_in = "OFF";
	parameter c7_high = 0;
	parameter c7_initial = 0;
	parameter c7_low = 0;
	parameter c7_mode = "BYPASS";
	parameter c7_ph = 0;
	parameter c7_test_source = 5;
	parameter c7_use_casc_in = "OFF";
	parameter c8_high = 0;
	parameter c8_initial = 0;
	parameter c8_low = 0;
	parameter c8_mode = "BYPASS";
	parameter c8_ph = 0;
	parameter c8_test_source = 5;
	parameter c8_use_casc_in = "OFF";
	parameter c9_high = 0;
	parameter c9_initial = 0;
	parameter c9_low = 0;
	parameter c9_mode = "BYPASS";
	parameter c9_ph = 0;
	parameter c9_test_source = 5;
	parameter c9_use_casc_in = "OFF";
	parameter clk0_use_even_counter_mode = "OFF";
	parameter clk0_use_even_counter_value = "OFF";
	parameter clk1_use_even_counter_mode = "OFF";
	parameter clk1_use_even_counter_value = "OFF";
	parameter clk2_use_even_counter_mode = "OFF";
	parameter clk2_use_even_counter_value = "OFF";
	parameter clk3_use_even_counter_mode = "OFF";
	parameter clk3_use_even_counter_value = "OFF";
	parameter clk4_use_even_counter_mode = "OFF";
	parameter clk4_use_even_counter_value = "OFF";
	parameter clk5_use_even_counter_mode = "OFF";
	parameter clk5_use_even_counter_value = "OFF";
	parameter clk6_divide_by = 0;
	parameter clk6_duty_cycle = 50;
	parameter clk6_multiply_by = 0;
	parameter clk6_phase_shift = "0";
	parameter clk6_use_even_counter_mode = "OFF";
	parameter clk6_use_even_counter_value = "OFF";
	parameter clk7_divide_by = 0;
	parameter clk7_duty_cycle = 50;
	parameter clk7_multiply_by = 0;
	parameter clk7_phase_shift = "0";
	parameter clk7_use_even_counter_mode = "OFF";
	parameter clk7_use_even_counter_value = "OFF";
	parameter clk8_divide_by = 0;
	parameter clk8_duty_cycle = 50;
	parameter clk8_multiply_by = 0;
	parameter clk8_phase_shift = "0";
	parameter clk8_use_even_counter_mode = "OFF";
	parameter clk8_use_even_counter_value = "OFF";
	parameter clk9_divide_by = 0;
	parameter clk9_duty_cycle = 50;
	parameter clk9_multiply_by = 0;
	parameter clk9_phase_shift = "0";
	parameter clk9_use_even_counter_mode = "OFF";
	parameter clk9_use_even_counter_value = "OFF";
	parameter lock_window_ui = " 0.05";
	parameter self_reset_on_loss_lock = "OFF";
	parameter vco_frequency_control = "AUTO";
	parameter vco_phase_shift_step = 0;
	parameter width_clock = 6;
	parameter port_configupdate = "PORT_CONNECTIVITY";
	parameter port_fbout = "PORT_CONNECTIVITY";
	parameter port_phasecounterselect = "PORT_CONNECTIVITY";
	parameter port_phasedone = "PORT_CONNECTIVITY";
	parameter port_phasestep = "PORT_CONNECTIVITY";
	parameter port_phaseupdown = "PORT_CONNECTIVITY";
	parameter port_scanclkena = "PORT_CONNECTIVITY";

	parameter charge_pump_current_bits = 9999;
	parameter loop_filter_c_bits = 9999;
	parameter loop_filter_r_bits = 9999;

	parameter clk6_counter = "E0";
	parameter clk7_counter = "E1";
	parameter clk8_counter = "E2";
	parameter clk9_counter = "E3";
	parameter scan_chain_mif_file = "UNUSED";
	parameter sim_gate_lock_device_behavior = "OFF";
	parameter   using_fbmimicbidir_port = "OFF";

	parameter dpa_divide_by = 1;
	parameter dpa_divider = 0;
	parameter dpa_multiply_by = 0;


        //// port declarations ////

	input [1:0] inclk;
	input fbin;
	input pllena;
	input clkswitch;
	input areset;
	input pfdena;
	input [5:0] clkena;
	input [3:0] extclkena;
	input scanclk;
	input scanaclr;
	input scandata;
	input scanread;
	input scanwrite;
	input configupdate;
	input [width_phasecounterselect-1:0] phasecounterselect;
	input phasestep;
	input phaseupdown;
	input scanclkena;
	output phasedone;
	output fbout;
	output [width_clock-1:0] clk;
	output [3:0] extclk;
	output [1:0] clkbad;
	output activeclock;
	output clkloss;
	output locked;
	output enable0;
	output enable1;
	output scandataout;
	output scandone;
	output sclkout0;
	output sclkout1;
	output vcooverrange;
	output vcounderrange;
	output fref;
	output icdrclk;
	inout fbmimicbidir;

	wire locked_wire;
	wire locked_reg;
	wire feedback;

