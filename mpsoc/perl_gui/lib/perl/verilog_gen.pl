use Glib qw/TRUE FALSE/;
#use Gtk2 '-init';

use lib 'lib/perl';

use strict;
use warnings;
use soc;
use ip;
use ip_gen;
use Cwd;





######################
#   soc_generate_verilog
#####################

sub soc_generate_verilog{ 
	my ($soc)= @_;
	my $soc_name=$soc->soc_get_soc_name();
	#my $top_ip=ip_gen->ip_gen_new();
	my $top_ip=ip_gen->top_gen_new();
	if(!defined $soc_name){$soc_name='soc'};
	
	my @instances=$soc->soc_get_all_instances();
	my $io_sim_v;
	my $param_as_in_v="\tparameter\tCORE_ID=0";
	my $body_v;
	
	my ($param_v_all, $local_param_v_all, $wire_def_v_all, $inst_v_all, $plugs_assign_v_all, $sockets_assign_v_all,$io_full_v_all);
	my $wires=soc->new_wires();
	my $intfc=interface->interface_new();
	foreach my $id (@instances){
		my ($param_v, $local_param_v, $wire_def_v, $inst_v, $plugs_assign_v, $sockets_assign_v,$io_full_v)=gen_module_inst($id,$soc,\$io_sim_v,\$param_as_in_v,$top_ip,$intfc,$wires);
		my $inst   	= $soc->soc_get_instance_name($id);
		add_text_to_string(\$body_v,"/*******************\n*\n*\t$inst\n*\n*\n*********************/\n");
		
		add_text_to_string(\$local_param_v_all,"$local_param_v\n")   	if(defined($local_param_v)); 
		add_text_to_string(\$wire_def_v_all,"$wire_def_v\n")		 	if(defined($wire_def_v));
		add_text_to_string(\$inst_v_all,$inst_v)					 	if(defined($inst_v));
		add_text_to_string(\$plugs_assign_v_all,"$plugs_assign_v\n") 	if(defined($plugs_assign_v));
		add_text_to_string(\$sockets_assign_v_all,"$sockets_assign_v\n")if(defined($sockets_assign_v));
		add_text_to_string(\$io_full_v_all,"$io_full_v\n")				if(defined($io_full_v));
		
		#print  "$param_v $local_param_v $wire_def_v $inst_v $plugs_assign_v $sockets_assign_v $io_full_v";
			
	}	
	my ($addr_map,$addr_localparam,$module_addr_localparam)= generate_address_cmp($soc,$wires);

	#add functions
	my $dir = Cwd::getcwd();
	open my $file1, "<", "$dir/lib/verilog/functions.v" or die;
	my $functions_all='';
	while (my $f1 = readline ($file1)) {	
		 $functions_all="$functions_all $f1 ";
	}
	close($file1);
	my $unused_wiers_v=assign_unconnected_wires($wires,$intfc);
	

	my $soc_v = (defined $param_as_in_v )? "module $soc_name #(\n $param_as_in_v\n)(\n$io_sim_v\n);\n": "module $soc_name (\n$io_sim_v\n);\n";
	add_text_to_string(\$soc_v,$functions_all);	
	add_text_to_string(\$soc_v,$local_param_v_all);
	add_text_to_string(\$soc_v,$addr_localparam);
	add_text_to_string(\$soc_v,$module_addr_localparam);	
	add_text_to_string(\$soc_v,$io_full_v_all);
	add_text_to_string(\$soc_v,$wire_def_v_all);
	add_text_to_string(\$soc_v,$unused_wiers_v);
	add_text_to_string(\$soc_v,$inst_v_all);
	add_text_to_string(\$soc_v,$plugs_assign_v_all);
	add_text_to_string(\$soc_v,$sockets_assign_v_all);
	add_text_to_string(\$soc_v,$addr_map);
	add_text_to_string(\$soc_v,"endmodule\n\n");
	
	
	$soc->soc_add_top($top_ip);
	#print @assigned_wires;
	return "$soc_v";


}	

#################
#	gen_module_inst
###############

sub gen_module_inst {
	my ($id,$soc,$io_sim_v,$param_as_in_v,$top_ip, $intfc,$wires)=@_;
	my $module 	=$soc->soc_get_module($id);
	my $module_name	=$soc->soc_get_module_name($id);
	my $category 	=$soc->soc_get_category($id);
	
	my $inst   	= $soc->soc_get_instance_name($id);
	my %params	= $soc->soc_get_module_param($id);
	
	my $ip = ip->lib_new ();
	
	my @ports=$ip->ip_list_ports($category,$module);
	my ($inst_v,$intfc_v,$wire_def_v,$plugs_assign_v,$sockets_assign_v,$io_full_v);
	$plugs_assign_v="\n";
	
	my $counter=0;
	my @param_order=$soc->soc_get_instance_param_order($id);
	
	my ($param_v,$local_param_v,$instance_param_v)= gen_parameter_v(\%params,$id,$inst,$category,$module,$ip,$param_as_in_v,\@param_order,$top_ip);
	my $param_size = keys %params;
	
	
	$top_ip->top_add_def_to_instance($id,'module',$module);
	$top_ip->top_add_def_to_instance($id,'module_name',$module_name);
	$top_ip->top_add_def_to_instance($id,'category',$category);
	$top_ip->top_add_def_to_instance($id,'instance',$inst);
	
	
	
	
	
	
	#module name	
	$inst_v=($param_size>0)? "$module_name #(\n": $module_name ; 
	
	

	#module parameters
	$inst_v=($param_size>0)? "$inst_v $instance_param_v\n\t)": $inst_v;
	#module instance name 
	$inst_v="$inst_v  $inst \t(\n";
	
	#module ports
	$counter=0;
	foreach my $port (@ports){
		my ($type,$range,$intfc_name,$i_port)=$ip->ip_get_port($category,$module,$port);
		my $assigned_port;
		my($i_type,$i_name,$i_num) =split("[:\[ \\]]", $intfc_name);
		my $IO='no';
		my $NC='no';		
		if($i_type eq 'plug'){
			my ($addr,$base,$end,$name,$connect_id,$connect_socket,$connect_socket_num)=$soc->soc_get_plug($id,$i_name,$i_num);
			if($connect_id eq 'IO'){ $IO='yes';}
			if($connect_id eq 'NC'){ $NC='yes';}
		}		
		if($i_type eq 'socket' && $i_name ne'wb_addr_map'){
			
			my ($ref1,$ref2)= $soc->soc_get_modules_plug_connected_to_socket($id,$i_name,$i_num);
			my %connected_plugs=%$ref1;
			my %connected_plug_nums=%$ref2;
			if(!%connected_plugs ){ 
				my  ($s_type,$s_value,$s_connection_num)=$soc->soc_get_socket_of_instance($id,$i_name);
				my $v=$soc->soc_get_module_param_value($id,$s_value);
				if ( length( $v || '' )){ $IO='no';} else {$IO='yes';}
			}
		}
		if($NC eq 'yes'){
			
			
		}
		elsif($IO eq 'yes' || !defined $i_type || !defined $i_name || !defined $i_num){ #its an IO port
			 $assigned_port="$inst\_$port";
			 $$io_sim_v= (!defined $$io_sim_v)? "\t$assigned_port" : "$$io_sim_v, \n\t$assigned_port";
			 my $new_range = add_instantc_name_to_parameters(\%params,$inst,$range);
			 my $port_def=(length ($range)>1 )? 	"\t$type\t [ $new_range    ] $assigned_port;\n": "\t$type\t\t\t$assigned_port;\n";			 
			 add_text_to_string(\$io_full_v,$port_def);
			# $top_ip->ipgen_add_port($assigned_port, $new_range, $type ,$intfc_name,$i_port);
			$top_ip->top_add_port($id,$assigned_port, $new_range, $type ,$intfc_name,$i_port);
			 
			 
		}
		else{ # port connected internally using interface 
			 $assigned_port="$inst\_$i_type\_$i_name\_$i_num\_$i_port";
			 
			 #create plug wires
			 my $wire_string=generate_wire ($range,$assigned_port,$inst,\%params,$i_type,$i_name,$i_num,$i_port, $wires);
			 add_text_to_string(\$wire_def_v,$wire_string);
				
			 
			 
			if($i_type eq 'plug'){
				#read socket port name
				my ($addr,$base,$end,$name,$connect_id,$connect_socket,$connect_socket_num)=$soc->soc_get_plug($id,$i_name,$i_num);
				my ($i_range,$t,$i_connect)=$intfc->get_port_info_of_plug($i_name,$i_port);
				#my $connect_port= "socket_$i_name\_$i_num\_$i_connect";
				if(defined $connect_socket_num){
					my $connect_n=$soc->soc_get_instance_name($connect_id);
					my $connect_port= "$connect_n\_socket_$i_name\_$connect_socket_num\_$i_connect";
					#connect plug port to socket port
					my $new_range = add_instantc_name_to_parameters(\%params,$inst,$range);
					my $connect_port_range=(length($new_range)>1)?"$connect_port\[$new_range\]":$connect_port;					
					
					if($type eq 'input' ){
						$plugs_assign_v= "$plugs_assign_v \tassign  $assigned_port = $connect_port_range;\n";
						$wires->wire_add($assigned_port,"connected",1);
						
					}else{
						$plugs_assign_v= "$plugs_assign_v \tassign  $connect_port  = $assigned_port;\n";
						$wires->wire_add($connect_port,"connected",1);						
					}


				}
			}#plug
			else{ #socket
				my  ($s_type,$s_value,$s_connection_num)=$soc->soc_get_socket_of_instance($id,$i_name);
				my $v=$soc->soc_get_module_param_value($id,$s_value);
				my ($i_range,$t,$i_connect)=$intfc->get_port_info_of_socket($i_name,$i_port);
				if ( length( $v || '' )) {
						$v--;
						my $name= $soc->soc_get_instance_name($id);
						my $joint= "$name\_$i_type\_$i_name\_$v\_$i_port";
						
						my $wire_string=generate_wire ($i_range,"$name\_$i_type\_$i_name\_$v\_$i_port",$inst,\%params,$i_type,$i_name,$i_num,$i_port, $wires);
						add_text_to_string(\$wire_def_v,$wire_string);
						
						for(my $i=$v-1; $i>=0; $i--) {
							$joint= "$joint ,$name\_$i_type\_$i_name\_$i\_$i_port";
							#create socket wires
							 #create plug wires
							my $wire_string=generate_wire ($i_range,"$name\_$i_type\_$i_name\_$i\_$i_port",$inst,\%params,$i_type,$i_name,$i_num,$i_port, $wires);
							add_text_to_string(\$wire_def_v,$wire_string);
				
							
							
							
							
							
						}
						$wires->wire_add($assigned_port,"connected",1)  if($type eq 'input');
						if($type ne 'input' ){
							my @w=split('\s*,\s*',$joint);
							foreach my $q (@w) {
								$wires->wire_add($q,"connected",1);
							}
							
						}
						$joint=($v>0)? "\{ $joint\ }" : "$joint";
						my $text=($type eq 'input' )? "\tassign $assigned_port = $joint;\n": "\tassign $joint = $assigned_port;\n";
						
						add_text_to_string(\$sockets_assign_v,$text);
				}
				
				
				
			}#socket	
			 
			
		}		
				
		
		
		if (++$counter == scalar(@ports)){#last port def
			
			$inst_v=($NC eq 'yes')? "$inst_v\t\t.$port()\n": "$inst_v\t\t.$port($assigned_port)\n";
			
		}
		else {
			$inst_v=($NC eq 'yes')? "$inst_v\t\t.$port(),\n":"$inst_v\t\t.$port($assigned_port),\n";
		}
		
		if($type ne 'input' && $NC ne 'yes' ){
			$wires->wire_add($assigned_port,"connected",1);
			
		}
		
		
		
	}	
	$inst_v="$inst_v\t);\n";
	
	
	
	
	return ($param_v, $local_param_v, $wire_def_v, $inst_v, $plugs_assign_v, $sockets_assign_v,$io_full_v);
	
	
}	


sub add_instantc_name_to_parameters{
	my ($params_ref,$inst,$range)=@_;
	my $new_range=$range;
	#print "$new_range\n";

	my @list=sort keys%{$params_ref};
	foreach my $param (@list){
		my $new_param= "$inst\_$param";
		($new_range=$new_range)=~ s/\b$param\b/$new_param/g;
		#print "$new_range= s/\b$param\b/$new_param/g\n";
	}
		return $new_range;
}			


sub gen_parameter_v{
	my ($param_ref,$id,$inst,$category,$module,$ip,$param_as_in_v,$ref_ordered,$top_ip)=@_;
	my %params=%$param_ref;
	my @param_order;
	@param_order=@{$ref_ordered} if(defined $ref_ordered);
	
	my ($param_v,$local_param_v,$instance_param_v);	
	my @list;
	@list= (@param_order)? @param_order : 
sort keys%params;
	my $first_param=1;
	$instance_param_v="";
	$local_param_v="";
	$param_v="";
	#add instance name to parameter value
	foreach my $param (@list){
		$params{$param}=add_instantc_name_to_parameters(\%params,$inst,$params{$param});

	}


	#print parameters
	foreach my $param (@list){
		my $inst_param= "$inst\_$param";
		my ($deafult,$type,$content,$info,$glob_param,$redefine_param)= $ip->ip_get_parameter($category,$module,$param);
		if (! defined $redefine_param){$redefine_param=1;}
		if($redefine_param eq 1){
				
			$instance_param_v=($first_param eq 1)? "$instance_param_v\t\t.$param($inst_param)" : "$instance_param_v,\n\t\t.$param($inst_param)";
			$first_param=0;			
						

		}
		
		
		if (! defined $glob_param){$glob_param=0;}
		if($glob_param eq 0){
			$local_param_v="$local_param_v\tlocalparam\t$inst_param=$params{$param};\n"; 
		}else{
			$param_v="$param_v\tparameter\t$inst_param=$params{$param};\n"; 
			$$param_as_in_v=(defined ($$param_as_in_v))? "$$param_as_in_v ,\n\tparameter\t$inst_param=$params{$param}":
														 "   \tparameter\t$inst_param=$params{$param}";
			#add parameter to top 
			#$top_ip  $inst_param			
			$top_ip->top_add_parameter($id,$inst_param,$params{$param},$type,$content,$info,$glob_param,$redefine_param);
			
		}
		
		
		
	}
	
	return ($param_v,$local_param_v,$instance_param_v);	
	
	
}	

###############
#	generate_address_cmp
##############

sub generate_address_cmp{
	my ($soc,$wires)=@_;
	my $number=0;
	my $addr_mp_v="\n//Wishbone slave address match\n";
	my $instance_addr_localparam="\n//Wishbone slave base address based on instance name\n";
	my $module_addr_localparam="\n//Wishbone slave base address based on module name. \n";
	
	my @all_instances=$soc->soc_get_all_instances();
	foreach my $instance_id (@all_instances){
		my $instance_name=$soc->soc_get_instance_name($instance_id);
			my @plugs= $soc->soc_get_all_plugs_of_an_instance($instance_id);
			foreach my $plug (@plugs){
				my @nums=$soc->soc_list_plug_nums($instance_id,$plug);
				
				foreach my $num (@nums){
					my ($addr,$base,$end,$name,$connect_id,$connect_socket,$connect_socket_num)=$soc->soc_get_plug($instance_id,$plug,$num);
					if((defined $connect_socket) && ($connect_socket eq 'wb_slave')){
						add_text_to_string(\$addr_mp_v,"/* $instance_name wb_slave $num */\n");
						my $base_hex=sprintf("32'h%08x", ($base>>2));
						my $end_hex=sprintf("32'h%08x", ($end>>2));
						add_text_to_string(\$instance_addr_localparam,"\tlocalparam \t$instance_name\_BASE_ADDR\t=\t$base_hex;\n");
						add_text_to_string(\$instance_addr_localparam,"\tlocalparam \t$instance_name\_END_ADDR\t=\t$end_hex;\n");
						if($instance_name ne $instance_id){
							add_text_to_string(\$module_addr_localparam,"\tlocalparam \t$instance_id\_BASE_ADDR\t=\t$base_hex;\n");
							add_text_to_string(\$module_addr_localparam,"\tlocalparam \t$instance_id\_END_ADDR\t=\t$end_hex;\n");
						}
						
						my $connect_name=$soc->soc_get_instance_name($connect_id);
						$wires->wire_add("$connect_name\_socket_wb_addr_map_0_sel_one_hot","connected",1);
						$addr_mp_v="$addr_mp_v \tassign $connect_name\_socket_wb_addr_map_0_sel_one_hot[$connect_socket_num\] = (($connect_name\_socket_wb_addr_map_0_grant_addr >= $instance_name\_BASE_ADDR)   & ($connect_name\_socket_wb_addr_map_0_grant_addr< $instance_name\_END_ADDR));\n";
						
						$number++;
					}#if
				}#foreach my $num
			}#foreach my $plug
		}#foreach my $instance_id
		
		add_text_to_string(\$instance_addr_localparam,"\n");
		add_text_to_string(\$module_addr_localparam,"\n");
		return ($addr_mp_v,$instance_addr_localparam,$module_addr_localparam);	
}	









sub add_text_to_string{
		my ($string,$text)=@_;
		if(defined $text){
			$$string=(defined ($$string))? "$$string $text" : $text;	
		}
}	



sub generate_wire {
	my($range,$port_name,$inst_name,$params_ref,$i_type,$i_name,$i_num,$i_port, $wires)=@_;
	my $wire_string;
	my $new_range;
	if(length ($range)>1 ){
		#replace parameter in range
		$new_range = add_instantc_name_to_parameters($params_ref,$inst_name,$range);
		$wire_string= "\twire\t[ $new_range ] $port_name;\n";				
	}
	else{
		$wire_string="\twire\t\t\t $port_name;\n";
	}
	$wires->wire_add("$port_name","range",$new_range);
	$wires->wire_add("$port_name","inst_name",$inst_name);
	$wires->wire_add("$port_name","i_type",$i_type);
	$wires->wire_add("$port_name","i_name",$i_name);
	$wires->wire_add("$port_name","i_num",$i_num);
	$wires->wire_add("$port_name","i_port",$i_port);
		
	return $wire_string;	
}	

sub port_width_repeat{
	my ($range,$value)=@_;
	$range=remove_all_white_spaces($range);
	my ($h,$l)=split(':',$range);
	return "$value" if(!defined $h ) ; # port width is 1
	return "$value" if($h eq "0" && "$l" eq "0"); # port width is 1
	$h=$l if($h eq "0" && "$l" ne "0"); 
	if($h =~ /-1$/){ # the address ranged is endup with -1 
		$h =~ s/-1$//; # remove -1
		return "\{$h\{$value\}\}"  if($h =~ /\)$/);
		return "\{($h)\{$value\}\}" if($h =~ /[\*\.\+\-\^\%\&]/);
		return "\{$h\{$value\}\}";
	}
	return "\{($h+1){$value}}";	
}

sub assign_unconnected_wires{
	my($wires,$intfc)=@_;
	my $unused_wire_v=undef;
	
	my @all_wires=$wires->wires_list();
	foreach my $p (@all_wires ){
		if(!defined $wires->wire_get($p,"connected")){ # unconnected wires
			# Take default value from interface definition 
			#$wires->wire_get("$p","inst_name");
			my $i_type=$wires->wire_get($p,"i_type");
			my $i_name= $wires->wire_get($p,"i_name");
			my $i_num=$wires->wire_get($p,"i_num");
			my $i_port=$wires->wire_get($p,"i_port");
			my $new_range=$wires->wire_get($p,"range");
			my ($range,$type,$connect,$default_out) = ($i_type eq "socket" )? $intfc->get_port_info_of_socket($i_name,$i_port):
																			  $intfc->get_port_info_of_plug($i_name,$i_port);
			#""Active high","Don't care"
			
			my $default=(!defined $default_out		  )? port_width_repeat($new_range,"1\'bx"):
						($default_out eq 'Active low' )? port_width_repeat($new_range,"1\'b0"):
					    ($default_out eq 'Active high')? port_width_repeat($new_range,"1\'b1"):
 						($default_out eq 'Don\'t care')? port_width_repeat($new_range,"1\'bx"): $default_out;
					    
			
			$unused_wire_v= "$unused_wire_v \tassign ${p} = $default;\n";
		
		}
		
	}
	$unused_wire_v="\n//Take the default value for ports that defined by interfaces but did not assigned to any wires.\n $unused_wire_v\n\n" if(defined $unused_wire_v); 
	return $unused_wire_v;

	
}








1;


