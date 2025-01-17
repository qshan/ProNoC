`timescale     1ns/1ps

//`define MONITORE_PATH

/***********************************************************************
 **	File: router.v
 **    
 **	Copyright (C) 2014-2017  Alireza Monemi
 **    
 **	This file is part of ProNoC 
 **
 **	ProNoC ( stands for Prototype Network-on-chip)  is free software: 
 **	you can redistribute it and/or modify it under the terms of the GNU
 **	Lesser General Public License as published by the Free Software Foundation,
 **	either version 2 of the License, or (at your option) any later version.
 **
 ** 	ProNoC is distributed in the hope that it will be useful, but WITHOUT
 ** 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 ** 	or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
 ** 	Public License for more details.
 **
 ** 	You should have received a copy of the GNU Lesser General Public
 ** 	License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
 **
 **
 **	Description: 
 **	A two stage router 
 **   stage1: lk-route,sw/VC allocation
 **   stage2: switch-traversal
 **************************************************************/


module router_two_stage 
		import pronoc_pkg::*;
		
		# (
			parameter P = 6     // router port num		   
		)(
		current_r_addr,// connected to constant parameter  
		
		chan_in,
		chan_out,	
		
		ctrl_in,
		ctrl_out,
		
		//internal router status 
		ivc_info, 
		ovc_info,
		iport_info,
		oport_info,
		
		smart_ctrl_in,
		
		clk,
		reset

		);
 
                

	// The current/neighbor routers addresses/port. These values are fixed in each router and they are supposed to be given as parameter. 
	// However, in order to give an identical RTL code to each router, they are given as input ports. The identical RTL code reduces the
	// compilation time. Note that they wont be implemented as  input ports in the final synthesized code. 

	input [RAw-1 :  0]  current_r_addr;
	
	input   flit_chanel_t chan_in  [P-1 : 0];
	output  flit_chanel_t chan_out [P-1 : 0];
	input   ctrl_chanel_t ctrl_in  [P-1 : 0];
	output  ctrl_chanel_t ctrl_out [P-1 : 0];
	input   clk,reset;
	
	
	output  ivc_info_t 	 ivc_info    [P-1 : 0][V-1 : 0];
	output  ovc_info_t   ovc_info    [P-1 : 0][V-1 : 0];
	output  iport_info_t iport_info  [P-1 : 0];
	output  oport_info_t oport_info  [P-1 : 0]; 
	
	input   smart_ctrl_t   smart_ctrl_in [P-1 : 0];
	
	
	vsa_ctrl_t   vsa_ctrl    [P-1 : 0];   
	
	localparam
		PV = V * P,
		VV = V*V,
		PVV = PV * V,    
		P_1 = ( SELF_LOOP_EN=="NO")?  P-1 : P,
		PP_1 = P_1 * P,
		PVP_1 = PV * P_1,		  
		PFw = P*Fw,
		CONG_ALw = CONGw* P,    //  congestion width per router
		W = WEIGHTw,
		WP = W * P, 
		WPP=  WP * P,
		PRAw= P * RAw;     
	
	
	
	
    

	wire  [PFw-1 :  0]  flit_in_all;
	wire  [P-1 :  0]  flit_in_wr_all;
	wire  [PV-1 :  0]  credit_out_all;
	wire  [CONG_ALw-1 :  0]  congestion_in_all;
    
	wire  [PFw-1 :  0]  flit_out_all;
	wire  [P-1 :  0]  flit_out_wr_all;
	wire  [PV-1 :  0]  credit_in_all;
	wire  [CONG_ALw-1 :  0]  congestion_out_all;
    
	
	

	// old router verilog code
    
	 
	
	//internal wires
	wire  [PV-1 : 0] ovc_allocated_all;
	wire  [PVV-1 : 0] granted_ovc_num_all;
	wire  [PV-1 : 0] ivc_num_getting_sw_grant;
	wire  [PV-1 : 0] ivc_num_getting_ovc_grant;
	wire  [PVV-1 : 0] spec_ovc_num_all;
	wire  [PV-1 : 0] nonspec_first_arbiter_granted_ivc_all;
	wire  [PV-1 : 0] spec_first_arbiter_granted_ivc_all;
	wire  [PP_1-1 : 0] nonspec_granted_dest_port_all;
	wire  [PP_1-1 : 0] spec_granted_dest_port_all;    
	wire  [PP_1-1 : 0] granted_dest_port_all;
	wire  [P-1 : 0] any_ivc_sw_request_granted_all;
	wire  [P-1 :  0] any_ovc_granted_in_outport_all;    
	wire  [P-1 : 0] granted_dst_is_from_a_single_flit_pck;
	// to vc/sw allocator
	wire  [PVP_1-1 :  0] dest_port_all;
	wire  [PV-1 : 0] ovc_is_assigned_all;
	wire  [PV-1 : 0] ivc_request_all;
	wire  [PV-1 : 0] assigned_ovc_not_full_all;
	wire  [PVV-1: 0] masked_ovc_request_all;
	wire  [PV-1 : 0] pck_is_single_flit_all; 
	wire  [PV-1 : 0] vc_weight_is_consumed_all;
	wire  [P-1  : 0] iport_weight_is_consumed_all;       
    wire  [PV-1 : 0] vsa_ovc_released_all;  
    wire  [PV-1 : 0] vsa_credit_decreased_all;
    
	// to/from the crossbar
	wire  [PFw-1 : 0] iport_flit_out_all;
	wire  [P-1 : 0] ssa_flit_wr_all;
	reg   [PP_1-1 : 0] granted_dest_port_all_delayed;
	wire  [PFw-1 :  0]  crossbar_flit_out_all;
	wire  [P-1   :  0]  crossbar_flit_out_wr_all;
	wire  [PFw-1 :  0]  link_flit_out_all;
	wire  [P-1   :  0]  link_flit_out_wr_all;
	wire  [PV-1  :  0] flit_is_tail_all;

    
	//to weight control
	wire [WP-1 : 0] iport_weight_all;
	wire [WPP-1: 0] oports_weight_all;
	wire refresh_w_counter;
	

	//ctrl port
	wire [PRAw-1  :  0] neighbors_r_addr;
	wire [CRDTw-1 : 0 ] credit_init_val_in  [P-1 : 0][V-1 : 0];
	wire [CRDTw-1 : 0 ] credit_init_val_out [P-1 : 0][V-1 : 0];
	
	
	
	genvar i,j;
	generate for (i=0; i<P; i=i+1 ) begin :p_
			assign  neighbors_r_addr  [(i+1)*RAw-1:  i*RAw] = ctrl_in[i].neighbors_r_addr;			
			assign  flit_in_all       [(i+1)*Fw-1:  i*Fw] = chan_in[i].flit;
			assign  flit_in_wr_all    [i] = chan_in[i].flit_wr;   
			assign  credit_in_all     [(i+1)*V-1:  i*V] = chan_in[i].credit;
			assign  congestion_in_all [(i+1)*CONGw-1:  i*CONGw] = chan_in[i].congestion; 
			
			assign  ctrl_out[i].neighbors_r_addr = current_r_addr;
			assign  chan_out[i].flit=          flit_out_all       [(i+1)*Fw-1:  i*Fw];       
			assign  chan_out[i].flit_wr=       flit_out_wr_all    [i];                       
			assign  chan_out[i].credit=        credit_out_all     [(i+1)*V-1:  i*V];         
			assign  chan_out[i].congestion=    congestion_out_all [(i+1)*CONGw-1:  i*CONGw];
			
			assign  iport_info[i].swa_first_level_grant =nonspec_first_arbiter_granted_ivc_all[(i+1)*V-1:  i*V]; 
			assign  iport_info[i].swa_grant = ivc_num_getting_sw_grant[(i+1)*V-1:  i*V]; 			
			assign  iport_info[i].any_ivc_get_swa_grant=	any_ivc_sw_request_granted_all[i]; 
			assign  iport_info[i].ivc_req = ivc_request_all [(i+1)*V-1:  i*V]; 
			
			assign  vsa_ctrl[i].ovc_is_allocated = ovc_allocated_all [(i+1)*V-1:  i*V];
			assign  vsa_ctrl[i].ovc_is_released  = vsa_ovc_released_all[(i+1)*V-1:  i*V];
			assign  vsa_ctrl[i].ivc_num_getting_sw_grant = ivc_num_getting_sw_grant [(i+1)*V-1:  i*V];
			assign  vsa_ctrl[i].ivc_num_getting_ovc_grant=ivc_num_getting_ovc_grant [(i+1)*V-1:  i*V];
			assign  vsa_ctrl[i].ivc_reset=flit_is_tail_all[(i+1)*V-1:  i*V] & ivc_num_getting_sw_grant[(i+1)*V-1:  i*V];
			assign  vsa_ctrl[i].buff_space_decreased =  vsa_credit_decreased_all[(i+1)*V-1:  i*V]; 
			assign  vsa_ctrl[i].ivc_granted_ovc_num = granted_ovc_num_all[(i+1)*VV-1:  i*VV];
			
			if(SELF_LOOP_EN == "NO") begin :nslp
				add_sw_loc_one_hot #(
						.P(P),
						.SW_LOC(i)    
					)add
					(
						.destport_in(granted_dest_port_all[(i+1)*P_1-1:  i*P_1]),
						.destport_out(iport_info[i].granted_oport_one_hot[P-1 : 0])
					);	
			end else begin :slp
				assign iport_info[i].granted_oport_one_hot[P-1 : 0] = granted_dest_port_all[(i+1)*P_1-1:  i*P_1];
			end
			
			for (j=0;j<V;j++)begin :V_
				assign credit_init_val_in[i][j]      = ctrl_in[i].credit_init_val[j];
				assign ctrl_out[i].credit_init_val[j] = credit_init_val_out [i][j];				
			end
			
		end		
	endgenerate
	
	
	
            
	inout_ports
		#(		
			.P(P)
		)
		the_inout_ports
		(
			.current_r_addr(current_r_addr),
			.neighbors_r_addr(neighbors_r_addr),
			.flit_in_all(flit_in_all),
			.flit_in_wr_all(flit_in_wr_all),
			.credit_out_all(credit_out_all),
			.credit_in_all(credit_in_all),
			.masked_ovc_request_all(masked_ovc_request_all),
			.pck_is_single_flit_all(pck_is_single_flit_all),
			.granted_dst_is_from_a_single_flit_pck(granted_dst_is_from_a_single_flit_pck),
			.vsa_ovc_allocated_all(ovc_allocated_all), 
			.granted_ovc_num_all(granted_ovc_num_all), 
			.ivc_num_getting_ovc_grant(ivc_num_getting_ovc_grant), 
			.spec_ovc_num_all(spec_ovc_num_all), 
			.nonspec_first_arbiter_granted_ivc_all(nonspec_first_arbiter_granted_ivc_all), 
			.spec_first_arbiter_granted_ivc_all(spec_first_arbiter_granted_ivc_all), 
			.nonspec_granted_dest_port_all(nonspec_granted_dest_port_all), 
			.spec_granted_dest_port_all(spec_granted_dest_port_all), 
			.granted_dest_port_all(granted_dest_port_all), 
			.any_ivc_sw_request_granted_all(any_ivc_sw_request_granted_all), 
			.any_ovc_granted_in_outport_all(any_ovc_granted_in_outport_all),
			.dest_port_all(dest_port_all), 
			.ovc_is_assigned_all(ovc_is_assigned_all), 
			.ivc_request_all(ivc_request_all), 
			.assigned_ovc_not_full_all(assigned_ovc_not_full_all), 
			.flit_out_all(iport_flit_out_all),
			.congestion_in_all(congestion_in_all),
			.congestion_out_all(congestion_out_all),
			//  .lk_destination_all(lk_destination_all),
			.ssa_flit_wr_all(ssa_flit_wr_all),
			.iport_weight_all(iport_weight_all),
			.oports_weight_all(oports_weight_all),
			.vc_weight_is_consumed_all(vc_weight_is_consumed_all),
			.iport_weight_is_consumed_all(iport_weight_is_consumed_all), 
			.refresh_w_counter(refresh_w_counter), 
			.clk(clk), 
			.reset(reset),
			.ivc_info(ivc_info),
			.ovc_info(ovc_info),
			.oport_info(oport_info),
			.smart_ctrl_in(smart_ctrl_in),
			.vsa_ctrl_in(vsa_ctrl),
			.credit_init_val_in (credit_init_val_in),
			.credit_init_val_out (credit_init_val_out),
			.flit_is_tail_all(flit_is_tail_all),			
			.crossbar_flit_out_wr_all(crossbar_flit_out_wr_all),
			.vsa_ovc_released_all(vsa_ovc_released_all),
			.vsa_credit_decreased_all(vsa_credit_decreased_all)
		);


	combined_vc_sw_alloc #(
			.V(V),    
			.P(P), 
			.COMBINATION_TYPE(COMBINATION_TYPE),
			.FIRST_ARBITER_EXT_P_EN (FIRST_ARBITER_EXT_P_EN),
			.SWA_ARBITER_TYPE (SWA_ARBITER_TYPE ), 
			.DEBUG_EN(DEBUG_EN),
			.MIN_PCK_SIZE(MIN_PCK_SIZE),
			.SELF_LOOP_EN(SELF_LOOP_EN)
		)
		vsa
		(
			.dest_port_all(dest_port_all), 
			.masked_ovc_request_all(masked_ovc_request_all),
			.ovc_is_assigned_all(ovc_is_assigned_all), 
			.ivc_request_all(ivc_request_all), 
			.assigned_ovc_not_full_all(assigned_ovc_not_full_all), 
			.pck_is_single_flit_all(pck_is_single_flit_all),
			.granted_dst_is_from_a_single_flit_pck(granted_dst_is_from_a_single_flit_pck),
			.ovc_allocated_all(ovc_allocated_all), 
			.granted_ovc_num_all(granted_ovc_num_all), 
			.ivc_num_getting_ovc_grant(ivc_num_getting_ovc_grant), 
			.ivc_num_getting_sw_grant(ivc_num_getting_sw_grant), 
			.spec_first_arbiter_granted_ivc_all(spec_first_arbiter_granted_ivc_all), 
			.nonspec_first_arbiter_granted_ivc_all(nonspec_first_arbiter_granted_ivc_all), 
			.nonspec_granted_dest_port_all(nonspec_granted_dest_port_all), 
			.spec_granted_dest_port_all(spec_granted_dest_port_all), 
			.granted_dest_port_all(granted_dest_port_all), 
			.any_ivc_sw_request_granted_all(any_ivc_sw_request_granted_all), 
			.any_ovc_granted_in_outport_all(any_ovc_granted_in_outport_all),
			.spec_ovc_num_all(spec_ovc_num_all),       
			// .lk_destination_all(lk_destination_all),  
			.vc_weight_is_consumed_all(vc_weight_is_consumed_all),  
			.iport_weight_is_consumed_all(iport_weight_is_consumed_all),  
			.clk(clk), 
			.reset(reset)
		);
        
		
	
	
   
	`ifdef SYNC_RESET_MODE 
		always @ (posedge clk )begin 
		`else 
			always @ (posedge clk or posedge reset)begin 
			`endif  
			if(reset) begin 
				granted_dest_port_all_delayed<= {PP_1{1'b0}};            
			end else begin
				granted_dest_port_all_delayed<= granted_dest_port_all;            
			end    
		end//always
    
		crossbar #(
				
				.TOPOLOGY(TOPOLOGY),
				.V (V),     // vc_num_per_port
				.P (P),     // router port num
				.Fw (Fw),
				.MUX_TYPE (MUX_TYPE),				
				.SSA_EN (SSA_EN),
				.SELF_LOOP_EN(SELF_LOOP_EN)
				
			)
			the_crossbar
			(
				.granted_dest_port_all (granted_dest_port_all_delayed),
				.flit_in_all (iport_flit_out_all),				
				.ssa_flit_wr_all (ssa_flit_wr_all),
				.flit_out_all (crossbar_flit_out_all),				
				.flit_out_wr_all (crossbar_flit_out_wr_all)
        
			);    
     
		//link reg 
		generate 
		//if( ADD_PIPREG_AFTER_CROSSBAR == 1 || SMART_EN == 1) begin :link_reg
		if( ADD_PIPREG_AFTER_CROSSBAR == 1 ) begin :link_reg
            
                
			reg [PFw-1 : 0] flit_out_all_pipe;
			reg [P-1 : 0] flit_out_wr_all_pipe;
            
			`ifdef SYNC_RESET_MODE 
				always @ (posedge clk )begin 
			`else 
				always @ (posedge clk or posedge reset)begin 
			`endif  
				if(reset)begin
					flit_out_all_pipe    <=  {PFw{1'b0}};
					flit_out_wr_all_pipe <=  {P{1'b0}};
				end else begin
					flit_out_all_pipe     <=  crossbar_flit_out_all;
					flit_out_wr_all_pipe  <=  crossbar_flit_out_wr_all;               
				end
			end        
            
			assign link_flit_out_all    = flit_out_all_pipe;
			assign link_flit_out_wr_all = flit_out_wr_all_pipe;       
            
         
		end else begin :no_link_reg    
            
			assign    link_flit_out_all     =   crossbar_flit_out_all;
			assign    link_flit_out_wr_all  =   crossbar_flit_out_wr_all;
           
		end       
        
	
		/* verilator lint_off WIDTH */ 
		if (SWA_ARBITER_TYPE != "RRA" ) begin : wrra_ 
		/* verilator lint_on WIDTH */ 
   
			wire [WP-1 : 0] contention_all;
			wire [WP-1 : 0] limited_oport_weight_all;
   
			wrra_contention_gen #(
				.WEIGHTw(WEIGHTw),
				.WRRA_CONFIG_INDEX(WRRA_CONFIG_INDEX),
				.V(V),
				.P(P),
				.SELF_LOOP_EN(SELF_LOOP_EN)
			)
			contention_gen
			(
				.limited_oport_weight_all(limited_oport_weight_all),
				.dest_port_all(dest_port_all),
				.ivc_request_all(ivc_request_all),
				.ovc_is_assigned_all(ovc_is_assigned_all), 
				.contention_all(contention_all),
				.iport_weight_all(iport_weight_all),
				.oports_weight_all(oports_weight_all)
            
			); 
        
			weights_update #(
				.ARBITER_TYPE(SWA_ARBITER_TYPE),
				.V(V),
				.P(P),
				.Fw(Fw),
				.WEIGHTw(WEIGHTw),
				.WRRA_CONFIG_INDEX(WRRA_CONFIG_INDEX),
				.C(C),
				.TOPOLOGY(TOPOLOGY),
				.EAw(EAw),
				.DSTPw(DSTPw),
				.ADD_PIPREG_AFTER_CROSSBAR(ADD_PIPREG_AFTER_CROSSBAR)
        	
			)
			updater
			(
				.limited_oports_weight(limited_oport_weight_all),
				.refresh_w_counter(refresh_w_counter),
				.iport_weight_all(iport_weight_all),
				.contention_all(contention_all),
				.flit_in_all(link_flit_out_all),
				.flit_out_all(flit_out_all),
				.flit_out_wr_all(flit_out_wr_all),
				.clk(clk),
				.reset(reset)
			);        
         
	end // WRRA
	else begin : rra_    
		assign flit_out_all  =  link_flit_out_all;   
		assign refresh_w_counter = 1'b0;
	end		
	endgenerate 
		assign  flit_out_wr_all = link_flit_out_wr_all;
		
       
		//synthesis translate_off 
		//synopsys  translate_off
		generate 
		/* verilator lint_off WIDTH */ 
		if(DEBUG_EN && TOPOLOGY == "MESH")begin :dbg
		/* verilator lint_on WIDTH */ 
		debug_mesh_edges #(
			.T1(T1),
			.T2(T2),
			.T3(T3),
			.T4(T4),
			.RAw(RAw),
			.P(P)
		)
		debug_edges
		(
			.clk(clk),
			.current_r_addr(current_r_addr),
			.flit_out_wr_all(flit_out_wr_all)
		);
	end// DEBUG
		endgenerate 
		// synopsys  translate_on  
		// synthesis translate_on
      
    
    
		// for testing the route path
    

   
		// synthesis translate_off
		// synopsys  translate_off                                  
		`ifdef MONITORE_PATH
     
			
		reg[P-1 :0] t1,t2;
		generate
			for (i=0;i<P;i=i+1)begin : lp                     
    
   
				always @(posedge clk) begin
					if(reset)begin 
						t1[i]<=1'b0;
						t2[i]<=1'b0;             
					end else begin 
						if(flit_in_wr_all[i]>0 && t1[i]==0)begin 
							$display("%t :In router (addr=%h, port=%d), flitin=%h",$time,current_r_addr,i,flit_in_all[(i+1)*Fw-1 : i*Fw]);
							t1[i]<=1;
						end
						if(flit_out_wr_all[i]>0 && t2[i]==0)begin 
							$display("%t :Out router (addr=%h, port=%d), flitout=%h",$time,current_r_addr,i,flit_out_all[(i+1)*Fw-1 : i*Fw]);
							t2[i]<=1;
						end
            
            
					end
				end
			end
		endgenerate
	`endif
   
   
   
	/*



    reg [10 :  0]  counter;
    reg [31 :  0]  flit_counter;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            flit_counter <=0;
            counter <= 0;
        end else begin 
            if(flit_in_wr_all>0 )begin 
                counter <=0;
                flit_counter<=flit_counter+1'b1;
                          
            end else begin 
                counter <= counter+1'b1;
                if( counter == 512 ) $display("%t : total flits received in (x=%d,Y=%d) is %d ",$time,current_r_addr,current_y,flit_counter);
            end
        end
    end
	 */


	//synopsys  translate_on
	//synthesis translate_on 


endmodule

