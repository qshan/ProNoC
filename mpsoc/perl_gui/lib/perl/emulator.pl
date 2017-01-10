#! /usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;
use Gtk2;
use Gtk2::Ex::Graph::GD;
use GD::Graph::Data;
use emulator;
use IO::CaptureOutput qw(capture qxx qxy);
use GD::Graph::colour qw/:colours/;
use Proc::Background;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep  clock_gettime clock_getres clock_nanosleep clock stat );

use File::Basename;
use File::Path qw/make_path/;

require "widget.pl"; 
require "emulate_ram_gen.pl"; 
require "mpsoc_gen.pl"; 
require "mpsoc_verilog_gen.pl"; 
require "readme_gen.pl";

use List::MoreUtils qw(uniq);





sub gen_chart {
	my $emulate=shift;	
	my($width,$hight)=max_win_size();
	my $graph_w=$width/2.5;
	my $graph_h=$hight/2.5;
	my $graph = Gtk2::Ex::Graph::GD->new($graph_w, $graph_h, 'linespoints');
	my @x;
	my @legend_keys;    
	my $sample_num=$emulate->object_get_attribute("emulate_num",undef);
	my $scale= $emulate->object_get_attribute("graph_scale",undef);
	my @results;
	$results[0]=[0];
	$results[1]= [0];
my $legend_info="This attribute controls placement of the legend within the graph image. The value is supplied as a two-letter string, where the first letter is placement (a B or an R for bottom or right, respectively) and the second is alignment (L, R, C, T, or B for left, right, center, top, or bottom, respectively). ";
	
my @ginfo = (
{ label=>"Graph Title", param_name=>"G_Title", type=>"Entry", default_val=>undef, content=>undef, info=>undef, param_parent=>'graph_param', ref_delay=>undef },  
{ label=>"Y Axix Title", param_name=>"Y_Title", type=>"Entry", default_val=>'Latency (clock)', content=>undef, info=>undef, param_parent=>'graph_param', ref_delay=>undef },
  { label=>"X Axix Title", param_name=>"X_Title", type=>"Entry", default_val=>'Load per router (flits/clock (%))', content=>undef, info=>undef, param_parent=>'graph_param',ref_delay=>undef },
  { label=>"legend placement", param_name=>"legend_placement", type=>'Combo-box', default_val=>'BL', content=>"BL,BC,BR,RT,RC,RB", info=>$legend_info, param_parent=>'graph_param', ref_delay=>undef},
 { label=>"Y min", param_name=>"Y_MIN", type=>'Spin-button', default_val=>0, content=>"0,1024,1", info=>"Y axix minimum value", param_parent=>'graph_param', ref_delay=> 5},
 { label=>"X min", param_name=>"X_MIN", type=>'Spin-button', default_val=>0, content=>"0,1024,1", info=>"X axix minimum value", param_parent=>'graph_param', ref_delay=> 5},
 { label=>"Line Width", param_name=>"LINEw", type=>'Spin-button', default_val=>3, content=>"1,20,1", info=>undef, param_parent=>'graph_param', ref_delay=> 5},
 

);	

	if(defined  $sample_num){
		my @color;
		my $min_y=200;		
		for (my $i=1;$i<=$sample_num; $i++) {
			my $color_num=$emulate->object_get_attribute("sample$i","color");
			my $l_name= $emulate->object_get_attribute("sample$i","line_name");
			$legend_keys[$i-1]= (defined $l_name)? $l_name : "NoC$i";
			$color_num=$i+1 if(!defined $color_num);
			push(@color, "my_color$color_num");
			my $ref=$emulate->object_get_attribute ("sample$i","result");
			if(defined $ref) {
				push(@x, sort {$a<=>$b} keys $ref);		    	
		    	}
						
		}#for
	my  @x1;
	@x1 =  uniq(sort {$a<=>$b} @x) if (scalar @x);

	if (scalar @x1){
		$results[0]=\@x1;
		for (my $i=1;$i<=$sample_num; $i++) {
			my $j=0;
			my $ref=$emulate->object_get_attribute ("sample$i","result");
			if(defined $ref){
				my %line=%$ref;
				foreach my $k (@x1){
					$results[$i][$j]=$line{$k};
					$min_y= $line{$k} if (defined $line{$k} && $line{$k}!=0 && $min_y > $line{$k});
					$j++;
				}#$k
			}#if			
		}#$i
		
	}#if
	
	my $max_y=$min_y*$scale;
	
	

	my $graphs_info;
	foreach my $d ( @ginfo){
		$graphs_info->{$d->{param_name}}=$emulate->object_get_attribute( 'graph_param',$d->{param_name});
		$graphs_info->{$d->{param_name}}= $d->{default_val} if(!defined $graphs_info->{$d->{param_name}});
	}
	
	#print "gggggggggggggggg=".$graphs_info->{X_Title};

	$graph->set (
            	x_label         => $graphs_info->{X_Title},
               	y_label         => $graphs_info->{Y_Title},
               	y_max_value     => $max_y,
               	y_min_value	=> $graphs_info->{Y_MIN},
               	x_min_value     => $graphs_info->{X_MIN}, # dosent work?
               	title           => $graphs_info->{G_Title},
               	bar_spacing     => 1,
                shadowclr       => 'dred',
                transparent     => 0,
				line_width 		=> $graphs_info->{LINEw},
				cycle_clrs		=> 'blue',
				legend_placement => $graphs_info->{legend_placement},
				dclrs=>\@color,
       		);
     }#if
	$graph->set_legend(@legend_keys);
	
	
	my $data = GD::Graph::Data->new(\@results) or die GD::Graph::Data->error;
        my $image = my_get_image($emulate,$graph,$data);
        
        
        
        
        
        
        
        
        my $table = Gtk2::Table->new (25, 10, FALSE);
        
           
		my $box = Gtk2::HBox->new (TRUE, 2);
		my $filename;
		$box->set_border_width (4);
		my   $align = Gtk2::Alignment->new (0.5, 0.5, 0, 0);
		my $frame = Gtk2::Frame->new;
		$frame->set_shadow_type ('in');
		$frame->add ($image);
		$align->add ($frame);
		
		
		my $plus = def_image_button('icons/plus.png',undef,TRUE);
		my $minues = def_image_button('icons/minus.png',undef,TRUE);
		my $setting = def_image_button('icons/setting.png',undef,TRUE);
		my $save = def_image_button('icons/save.png',undef,TRUE);

		$minues -> signal_connect("clicked" => sub{ 
			$emulate->object_add_attribute("graph_scale",undef,$scale+0.5);
			set_gui_status($emulate,"ref",1);	
		});	

		$plus  -> signal_connect("clicked" => sub{ 
			$emulate->object_add_attribute("graph_scale",undef,$scale-0.5) if( $scale>0.5);
			set_gui_status($emulate,"ref",5);
		});	

		$setting -> signal_connect("clicked" => sub{ 
			get_graph_setting ($emulate,\@ginfo);
		});	
		
		$save-> signal_connect("clicked" => sub{ 
			 my $G = $graph->{graph};
			 my @imags=$G->export_format();  
			save_graph_as ($emulate,\@imags);
		});	
		
		
		
		
		$table->attach_defaults ($align , 0, 9, 0, 25);
		my $row=0;
		$table->attach ($plus , 9, 10, $row, $row+1,'shrink','shrink',2,2); $row++;
		$table->attach ($minues, 9, 10, $row, $row+1,'shrink','shrink',2,2); $row++;
		$table->attach ($setting, 9, 10, $row,  $row+1,'shrink','shrink',2,2); $row++;
		$table->attach ($save, 9, 10, $row,  $row+1,'shrink','shrink',2,2); $row++;
		while ($row<10){
			
			my $tmp=gen_label_in_left('');
			$table->attach_defaults ($tmp, 9, 10, $row,  $row+1);$row++;
		}
		
        return $table;
	
}


##############
#	save_graph_as
##############

sub save_graph_as {
	my ($emulate,$ref)=@_;
	
	my $file;
	my $title ='Save as';



	my @extensions=@$ref;
	my $open_in=undef;
	my $dialog = Gtk2::FileChooserDialog->new(
            	'Save file', undef,
            	'save',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);
	# if(defined $extension){
		
		foreach my $ext (@extensions){
			my $filter = Gtk2::FileFilter->new();
			$filter->set_name($ext);
			$filter->add_pattern("*.$ext");
			$dialog->add_filter ($filter);
		}
		
	# }
	  if(defined  $open_in){
		$dialog->set_current_folder ($open_in); 
		# print "$open_in\n";
		 
	}
		
	if ( "ok" eq $dialog->run ) {
	    		$file = $dialog->get_filename;
			my $ext = $dialog->get_filter;
			$ext=$ext->get_name;
			my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
			$file = ($suffix eq ".$ext" )? $file : "$file.$ext";
			
			$emulate->object_add_attribute("graph_save","name",$file);
			$emulate->object_add_attribute("graph_save","extension",$ext);
			$emulate->object_add_attribute("graph_save","save",1);
			set_gui_status($emulate,"ref",1);


					
	      		 }
	     		$dialog->destroy;
	       		


	 


}




sub my_get_image {
	my ($emulate,$self, $data) = @_;
	$self->{graphdata} = $data;
	my $graph = $self->{graph};
	my $gd1=$graph->plot($data) or warn $graph->error;
	my $loader = Gtk2::Gdk::PixbufLoader->new;
	
	
	
	#my $gd2=$graph->plot([[0],[0]]) or warn $graph->error;
	#$gd2->copy( $gd1, 0, 20, 0, 20, 500, 230 );
	
	
	$loader->write ($gd1->png);
	$loader->close;

	my $save=$emulate->object_get_attribute("graph_save","save");
	$save=0 if (!defined $save);	
	if ($save ==1){
		my $file=$emulate->object_get_attribute("graph_save","name");
		my $ext=$emulate->object_get_attribute("graph_save","extension");
		$emulate->object_add_attribute("graph_save","save",0);

		
		open(my $out, '>', $file);
		if (tell $out )
		{
			warn "Cannot open '$file' for write: $!";  
		}else
		{	
			#my @extens=$graph->export_format();
			binmode $out;
			print $out $gd1->$ext;# if($ext eq 'png');
			#print $out  $gd1->gif  if($ext eq 'gif');
			close $out;
		}

	}
	
		

	my $image = Gtk2::Image->new_from_pixbuf($loader->get_pixbuf);
	$self->{graphimage} = $image;
	my $hotspotlist;
	if ($self->{graphtype} eq 'bars' or
		$self->{graphtype} eq 'lines' or
		$self->{graphtype} eq 'linespoints') {
		foreach my $hotspot ($graph->get_hotspot) {
			push @$hotspotlist, $hotspot if $hotspot;
		}
	}
	$self->{hotspotlist} = $hotspotlist;
	my $eventbox = $self->{eventbox};
	my @children = $eventbox->get_children;
	foreach my $child (@children) {
		$eventbox->remove($child);
	}
	
	
	
	
	$eventbox->add ($image);

	$eventbox->signal_connect ('button-press-event' => 
		sub {
			my ($widget, $event) = @_;
			return TRUE;
			return FALSE unless $event->button == 3;
			$self->{optionsmenu}->popup(
				undef, # parent menu shell
				undef, # parent menu item
				undef, # menu pos func
				undef, # data
				$event->button,
				$event->time
			);
		}
	);	
	$eventbox->show_all;
	return $eventbox;
}


############
#	get_graph_setting
###########

sub get_graph_setting {
	my ($emulate,$ref)=@_;
	my($width,$hight)=max_win_size();
	my $window=def_popwin_size($width/3,$hight/3,'Graph Setting');
	my $table = def_table(10, 2, FALSE);
	my $row=0;


my @data=@$ref;
foreach my $d (@data) {
	$row=noc_param_widget ($emulate, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,1, $d->{param_parent}, $d->{ref_delay});
}
	
	
	
	
	my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);
	$scrolled_win->set_policy( "automatic", "automatic" );
	$scrolled_win->add_with_viewport($table);
	my $ok = def_image_button('icons/select.png',' OK ');
	
	
	my $mtable = def_table(10, 1, FALSE);
	$mtable->attach_defaults($scrolled_win,0,1,0,9);
	$mtable->attach($ok,0,1,9,10,'shrink','shrink',2,2);
	$window->add ($mtable);
	$window->show_all();
	
	$ok-> signal_connect("clicked" => sub{ 
		$window->destroy;
		set_gui_status($emulate,"ref",1);
	});



}












 ################
 # get_color_window
 ###############
 
 sub get_color_window{
	 my ($emulate,$atrebute1,$atrebute2)=@_;     
	 my $window=def_popwin_size(800,600,"Select line color");
	 my ($r,$c)=(4,8);	 
	 my $table= def_table(5,6,TRUE);
	 for (my $col=0;$col<$c;$col++){
		  for (my $row=0;$row<$r;$row++){
			my $color_num=$row*$c+$col;
			my $color=def_colored_button("    ",$color_num);
			$table->attach_defaults ($color, $col, $col+1, $row, $row+1); 
			$color->signal_connect("clicked"=> sub{
				$emulate->object_add_attribute($atrebute1,$atrebute2,$color_num);
				#print "$emulate->object_add_attribute($atrebute1,$atrebute2,$color_num);\n";
				set_gui_status($emulate,"ref",1);
				$window->destroy;
			});
		 }
	 }
	 
	 $window->add($table);
	
	$window->show_all();

}




sub check_inserted_ratios {
		my $str=shift;
		my @ratios;
	    	
	    my @chunks=split(',',$str);
	    foreach my $p (@chunks){
			if($p !~ /^[0-9.:,]+$/){ message_dialog ("$p has invalid character(S)" ); return undef; }
			my @range=split(':',$p);
			my $size= scalar @range;
			if($size==1){ # its a number
				if ( $range[0] <= 0 || $range[0] >100  ) { message_dialog ("$range[0] is out of boundery (1:100)" ); return undef; }
				push(@ratios,$range[0]);
			}elsif($size ==3){# its a range
				my($min,$max,$step)=@range;
				if ( $min <= 0 || $min >100  ) { message_dialog ("$min in  $p is out of boundery (1:100)" ); return undef; }
				if ( $max <= 0 || $max >100  ) { message_dialog ("$max in  $p is out of boundery (1:100)" ); return undef; }
				for (my $i=$min; $i<=$max; $i=$i+$step){
						push(@ratios,$i);
				}			
				
			}else{
				 message_dialog ("$p has invalid format. The correct format for range is \$min:\$max:\$step" );
				
			}
			
			
			
		}#foreach
		my @r=uniq(sort {$a<=>$b} @ratios);
		return \@r;
			
}







sub get_injection_ratios{
		my ($emulate,$atrebute1,$atrebute2)=@_;
		my $box = Gtk2::HBox->new( FALSE, 0 );
		my $init=$emulate->object_get_attribute($atrebute1,$atrebute2);
		my $entry=gen_entry($init);
		my $button=def_image_button("icons/right.png",'Check');		
		$button->signal_connect("clicked" => sub {
			my $text= $entry->get_text();
			my $r=check_inserted_ratios($text);	
			if(defined 	$r){	
				my $all=  join (',',@$r);
				message_dialog ("$all" );
			}
			
			
		});	
		$entry->signal_connect ("changed" => sub {	
			my $text= $entry->get_text();
			$emulate->object_add_attribute($atrebute1,$atrebute2,$text);
			
		});	
		$box->pack_start( $entry, 1,1, 0);
		$box->pack_start( $button, 0, 1, 3);
		return 	$box;
}



sub get_noc_configuration{
		my ($emulate,$n) =@_;
		my($width,$hight)=max_win_size();
		my $win=def_popwin_size($width/2.5,$hight*.8,"NoC configuration setting");
		my $table=def_table(10,2,FALSE);
		my $entry=gen_entry();
		my $row=0;
		my @l;
		my @u;
		
		my $traffics="tornado,transposed 1,transposed 2,bit reverse,bit complement,random"; #TODO hot spot 
		
		$l[$row]=gen_label_help("Select the SRAM Object File (sof) for this NoC configration.","SoF file:");
		my $dir = Cwd::getcwd();

		
		my $open_in	  = abs_path("$ENV{PRONOC_WORK}/emulate/sof");	
		$u[$row]= get_file_name_object ($emulate,"sample$n","sof_file",'sof',$open_in);
		$row++;
		$l[$row]=gen_label_help("NoC configration name. This name will be shown in load-latency graph for this configuration","Configuration name:");
		$u[$row]=gen_entry_object ($emulate,"sample$n","line_name","NoC$n");
		$row++;
		$l[$row]=gen_label_help("Traffic name","Traffic name:");
		$u[$row]=gen_combobox_object ($emulate,"sample$n","traffic",$traffics,"random");
		$row++;
		$l[$row]=gen_label_help("Define injection ratios. You can define individual ratios seprating by comma (\',\') or define a range of injection ratios with \$min:\$max:\$step format.
			As an example definnig 2,3,4:10:2 will results in (2,3,4,6,8,10) injection ratios.","Injection ratios:");
		$u[$row]=get_injection_ratios ($emulate,"sample$n","ratios");
		$row++;
		my $i=0;
		for ( $i=0; $i<12; $i++){
			if($i<$row){
				$table->attach ($l[$i] , 0, 1,  $i, $i+1,'fill','shrink',2,2);
				$table->attach ($u[$i] , 1, 2,  $i, $i+1,'fill','shrink',2,2);
			}else{
				my $l=gen_label_in_left(" ");
				$table->attach_defaults ($l , 0, 1,  $i, $i+1); 
			}
		}
		
		
	my $ok = def_image_button('icons/select.png','OK');
	
	
	$table->attach ($ok , 1, 2,  $i, $i+1,'expand','shrink',2,2); 
	
	$ok->signal_connect("clicked"=> sub{
		#check if sof file has been selected
		my $s=$emulate->object_get_attribute("sample$n","sof_file");
		#check if injection ratios are valid
		my $r=$emulate->object_get_attribute("sample$n","ratios");
		if(defined $s && defined $r) {	
				$win->destroy;
				set_gui_status($emulate,"ref",1);
		} else {
			
			if(!defined $s){
				 message_dialog("Please select sof file!")
			} else {
				 message_dialog("Please define valid injection ratio(s)!")
			}
		}
	});
		
		$win->add($table);
		$win->show_all;
	
	
}	
	 

      
#####################
#		gen_widgets_column
###################      
      
sub gen_emulation_column {
	my ($emulate,$title, $row_num,$info)=@_;
	my $table=def_table($row_num,10,FALSE);
	my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);
	$scrolled_win->set_policy( "automatic", "automatic" );
	$scrolled_win->add_with_viewport($table);	
	my $row=0;
	#title	
	if(defined $title){
		my $title=gen_label_in_center($title);
		my $box=def_vbox(FALSE, 1);
		$box->pack_start( $title, FALSE, FALSE, 3);
		my $separator = Gtk2::HSeparator->new;
		$box->pack_start( $separator, FALSE, FALSE, 3);
		$table->attach_defaults ($box , 0, 10,  $row, $row+1); $row++;
	}
	
	
	my $lb=gen_label_in_left("Number of emulations");
	my $spin= gen_spin_object ($emulate,"emulate_num",undef,"1,100,1",1,'ref','1');
    $table->attach_defaults ($lb, 0, 2, $row, $row+1);
    $table->attach_defaults ($spin, 2, 4, $row, $row+1);$row++;
	
	
		
	
	my @positions=(0,1,2,3,6,7);
	my $col=0;
	
	my @title=(" NoC configuration", "Line's color", "Clear Graph","  ");
	foreach my $t (@title){
		
		$table->attach_defaults (gen_label_in_center($title[$col]), $positions[$col], $positions[$col+1], $row, $row+1);$col++;
	}
	
	my $traffics="Random,Transposed 1,Transposed 2,Tornado";

	$col=0;
	$row++;
	@positions=(0,1,2,3,4,5,6,7);
	
	my $sample_num=$emulate->object_get_attribute("emulate_num",undef);
	 if(!defined $sample_num){
	 	$sample_num=1;
	 	$emulate->object_add_attribute("emulate_num",undef,1);
	 }
	my $i=0;
	for ($i=1;$i<=$sample_num; $i++){
		$col=0;
		my $sample="sample$i";
		my $n=$i;
		my $set=def_image_button("icons/setting.png");
		my $name=$emulate->object_get_attribute($sample,"line_name");
		my $l;
		if (defined $name){
			 $l=gen_label_in_left($name); 
		} else {
			$l=gen_label_in_center("Define NoC configuration");
			$l->set_markup("<span  foreground= 'red' ><b>Define NoC configuration</b></span>");			 
		}
		my $box=def_pack_hbox(FALSE,0,(gen_label_in_left("$i- "),$l,$set));
		$table->attach ($box, $positions[$col], $positions[$col+1], $row, $row+1,'expand','shrink',2,2);$col++;
		$set->signal_connect("clicked"=> sub{
			get_noc_configuration($emulate,$n);
		});
		
		
		
		my $color_num=$emulate->object_get_attribute($sample,"color");
		if(!defined $color_num){
			$color_num = $i+1;
			$emulate->object_add_attribute($sample,"color",$color_num);
		}
		my $color=def_colored_button("    ",$color_num);
		$table->attach ($color, $positions[$col], $positions[$col+1], $row, $row+1,'expand','shrink',2,2);$col++;
		
		
		
	
		
		
		$color->signal_connect("clicked"=> sub{
			get_color_window($emulate,$sample,"color");
		});
		
		#clear line
		my $clear = def_image_button('icons/clear.png');
		$clear->signal_connect("clicked"=> sub{
			$emulate->object_add_attribute ($sample,'result',undef);
			set_gui_status($emulate,"ref",2);
		});
		$table->attach ($clear, $positions[$col], $positions[$col+1], $row, $row+1,'expand','shrink',2,2);$col++;
		#run/pause
		my $run = def_image_button('icons/run.png','Run');
		$table->attach ($run, $positions[$col], $positions[$col+1], $row, $row+1,'expand','shrink',2,2);$col++;
		$run->signal_connect("clicked"=> sub{
			$emulate->object_add_attribute ($sample,"status","run");
			#start the emulator if it is not running	
			my $status= $emulate->object_get_attribute('status',undef);
			if($status ne 'run'){
				
				run_emulator($emulate,$info); 
				set_gui_status($emulate,"ref",2);
			}
			
		});
		
		my $image = gen_noc_status_image($emulate,$i);
		
		$table->attach_defaults ($image, $positions[$col], $positions[$col+1], $row, $row+1);
		
		
		$row++;
		
	}
	while ( $row<15){
		$table->attach_defaults (gen_label_in_left(' '), 0, 1, $row, $row+1); $row++;
	}




	return $scrolled_win;
}	      




##########
#
##########

sub check_sample{
	my ($emulate,$i,$info)=@_;
	my $status=1;
	my $sof=$emulate->object_get_attribute ("sample$i","sof_file");
	# ckeck if sample have sof file
	if(!defined $sof){
		add_info($info, "Error: SoF file has not set for NoC$i!\n");
		$emulate->object_add_attribute ("sample$i","status","failed");	
		$status=0;
	} else {
		# ckeck if sof file has info file 
		my ($name,$path,$suffix) = fileparse("$sof",qr"\..[^.]*$");
		my $sof_info="$path$name.inf";	
		if(!(-f $sof_info)){
			add_info($info, "Could not find $name.inf file in $path. An information file is required for each sof file containig the device name and  NoC configuration. Press F4 for more help.\n");
			$emulate->object_add_attribute ("sample$i","status","failed");	
			$status=0;
		}else { #add info
			my $p= do $sof_info ;
			$status=0 if $@;
			message_dialog("Error reading: $@") if $@;
			if ($status==1){
				$emulate->object_add_attribute ("sample$i","noc_info",$p) ;
					#print"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh\n";
			
			}
			
			
			
		}		
	}
				
	
	return $status;
	
	
}




##########
#  run external commands
##########





sub run_cmd_in_back_ground
{
  my $command = shift;
 


	


  ### Start running the Background Job:
    my $proc = Proc::Background->new($command);
    my $PID = $proc->pid;
    my $start_time = $proc->start_time;
    my $alive = $proc->alive;

  ### While $alive is NOT '0', then keep checking till it is...
  #  *When $alive is '0', it has finished executing.
  while($alive ne 0)
  {
    $alive = $proc->alive;

    # This while loop will cause Gtk2 to conti processing events, if
    # there are events pending... *which there are...
    while (Gtk2->events_pending) {
      Gtk2->main_iteration;
    }
    Gtk2::Gdk->flush;

    usleep(1000);
  }
  
  my $end_time = $proc->end_time;
 # print "*Command Completed at $end_time, with PID = $PID\n\n";

  # Since the while loop has exited, the BG job has finished running:
  # so close the pop-up window...
 # $popup_window->hide;

  # Get the RETCODE from the Background Job using the 'wait' method
  my $retcode = $proc->wait;
  $retcode /= 256;

  print "\t*RETCODE == $retcode\n\n";
  Gtk2::Gdk->flush;
  ### Check if the RETCODE returned with an Error:
  if ($retcode ne 0) {
    print "Error: The Background Job ($command) returned with an Error...!\n";
    return 1;
  } else {
    #print "Success: The Background Job Completed Successfully...!\n";
    return 0;
  }
	
}




sub run_cmd_in_back_ground_get_stdout
{
	my $cmd=shift;
	my $exit;
	my ($stdout, $stderr);
	capture { $exit=run_cmd_in_back_ground($cmd) } \$stdout, \$stderr;
	return ($stdout,$exit,$stderr);
	
}	


#############
#  images
##########
sub get_status_gif{
		my $emulate=shift;
		my $status= $emulate->object_get_attribute('status',undef);
		if($status eq 'ideal'){
			return show_gif ("icons/ProNoC.png");
		} elsif ($status eq 'run') {
			my($width,$hight)=max_win_size();
			my $image=($width>=1600)? "icons/hamster_l.gif":
			          ($width>=1200)? "icons/hamster_m.gif": "icons/hamster_s.gif"; 
				  
			return show_gif ($image);			
		} elsif ($status eq 'programer_failed') {
			return show_gif ("icons/Error.png");			
		}
	
}	




sub gen_noc_status_image {
	my ($emulate,$i)=@_;
	my   $status= $emulate->object_get_attribute ("sample$i","status");	
	 $status='' if(!defined  $status);
	my $image;
	my $vbox = Gtk2::HBox->new (TRUE,1);
	$image = Gtk2::Image->new_from_file ("icons/load.gif") if($status eq "run");
	$image = def_image("icons/button_ok.png") if($status eq "done");
	$image = def_image("icons/cancel.png") if($status eq "failed");
	#$image_file = "icons/load.gif" if($status eq "run");
	
	if (defined $image) {
		my $align = Gtk2::Alignment->new (0.5, 0.5, 0, 0);
     	my $frame = Gtk2::Frame->new;
		$frame->set_shadow_type ('in');
		# Animation
		$frame->add ($image);
		$align->add ($frame);
		$vbox->pack_start ($align, FALSE, FALSE, 0);
	}
	return $vbox;
	
}


############
#	run_emulator
###########

sub run_emulator {
	my ($emulate,$info)=@_;
	#return if(!check_samples($emulate,$info));
	$emulate->object_add_attribute('status',undef,'run');
	set_gui_status($emulate,"ref",1);
	show_info($info, "start emulation\n");

	#search for available usb blaster
	my $cmd = "jtagconfig";
	my ($stdout,$exit)=run_cmd_in_back_ground_get_stdout("$cmd");
	my @matches= ($stdout =~ /USB-Blaster.*/g);
	my $usb_blaster=$matches[0];
  	if (!defined $usb_blaster){
		add_info($info, "jtagconfig could not find any USB blaster cable: $stdout \n");
		$emulate->object_add_attribute('status',undef,'programer_failed');
		set_gui_status($emulate,"ref",2);
		return;	
	}else{
		add_info($info, "find $usb_blaster\n");
	}
	my $sample_num=$emulate->object_get_attribute("emulate_num",undef);
	for (my $i=1; $i<=$sample_num; $i++){
		my $status=$emulate->object_get_attribute ("sample$i","status");	
		next if($status ne "run");
		next if(!check_sample($emulate,$i,$info));
		my $r= $emulate->object_get_attribute("sample$i","ratios");
		my @ratios=@{check_inserted_ratios($r)};
		#$emulate->object_add_attribute ("sample$i","status","run");			
		my $sof=$emulate->object_get_attribute ("sample$i","sof_file");		
		add_info($info, "Programe FPGA device using $sof\n");
		my $Quartus_bin=  $ENV{QUARTUS_BIN};
			

		my $cmd = "$Quartus_bin/quartus_pgm -c \"$usb_blaster\" -m jtag -o \"p;$sof\"";
		#my $output = `$cmd 2>&1 1>/dev/null`;           # either with backticks
		my ($stdout,$exit)=run_cmd_in_back_ground_get_stdout("$cmd");	
		if($exit){#programming FPGA board has failed
			$emulate->object_add_attribute('status',undef,'programer_failed');
			add_info($info, "$stdout\n");
			$emulate->object_add_attribute ("sample$i","status","failed");	
			set_gui_status($emulate,"ref",2);
			next;			
		}		
		# read noc configuration 
		my $traffic = $emulate->object_get_attribute("sample$i","traffic");
		
		
		my $ref=$emulate->object_get_attribute("sample$i","noc_info");
			
		foreach  my $ratio_in (@ratios){	
						
	    	
	    	add_info($info, "Configure packet generators for  injection ratio of $ratio_in \% \n");
	    	next if(!programe_pck_gens($ref,$traffic,$ratio_in,$info));
	    	
	    	my $avg=read_pack_gen($ref,$info);
	    	my $ref=$emulate->object_get_attribute ("sample$i","result");
	    	my %results;
	    	%results= %{$ref} if(defined $ref);
	    	#push(@results,$avg);
	    	$results{$ratio_in}=$avg;
	    	$emulate->object_add_attribute ("sample$i","result",\%results);
	    	set_gui_status($emulate,"ref",2);
	    		    	
		}
		$emulate->object_add_attribute ("sample$i","status","done");	
    	
	}
	
	add_info($info, "End emulation!\n");
	$emulate->object_add_attribute('status',undef,'ideal');
	set_gui_status($emulate,"ref",1);
}










sub process_notebook_gen{
		my ($emulate,$info)=@_;
		my $notebook = Gtk2::Notebook->new;
		$notebook->set_tab_pos ('left');
		$notebook->set_scrollable(TRUE);
		$notebook->can_focus(FALSE);
		my $page1=gen_emulation_column($emulate,"NoC Configuration",10,$info);
		$notebook->append_page ($page1,Gtk2::Label->new_with_mnemonic ("  _Run emulator  "));
		
		
		my $page2=get_noc_setting_gui ($emulate,$info);
		my $pp=$notebook->append_page ($page2,Gtk2::Label->new_with_mnemonic ("  _Generate sof   "));
		
		
		
		
		my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);
		$scrolled_win->set_policy( "automatic", "automatic" );
		$scrolled_win->add_with_viewport($notebook);
		$scrolled_win->show_all;	
		my $page_num=$emulate->object_get_attribute ("process_notebook","currentpage");		
		$notebook->set_current_page ($page_num) if(defined $page_num);
		$notebook->signal_connect( 'switch-page'=> sub{			
			$emulate->object_add_attribute ("process_notebook","currentpage",$_[2]);	#save the new pagenumber
					
		});
		
		return $scrolled_win;
	
}


sub get_noc_setting_gui {
		my ($emulate,$info_text)=@_;
		my $table=def_table(20,10,FALSE);#	my ($row,$col,$homogeneous)=@_;
	    my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);
	    $scrolled_win->set_policy( "automatic", "automatic" );
	    $scrolled_win->add_with_viewport($table);
	    my $row=noc_config ($emulate,$table);
	    
		my($label,$param,$default,$content,$type,$info);
		my @dirs = grep {-d} glob("../src_emulate/fpga/*");
		my $fpgas;
		foreach my $dir (@dirs) {
			my ($name,$path,$suffix) = fileparse("$dir",qr"\..[^.]*$");
			$default=$name;
			$fpgas= (defined $fpgas)? "$fpgas,$name" : "$name";
			
		}
	
		
		
		$label='simulation param';		
		$content=$fpgas;
		$type='Entry';
		$info="  I will add later"; 
		
		my %simparam;
		$simparam{'MAX_PCK_NUM'}=2560000;
		$simparam{'MAX_SIM_CLKs'}=1000000;
		$simparam{'MAX_PCK_SIZ'}=10;
		$simparam{'TIMSTMP_FIFO_NUM'}=16;
		
		foreach my $p (sort keys %simparam){
					#	print "\$p, \$simparam{\$p}=$p, $simparam{$p}\n";
				$row=noc_param_widget ($emulate,$label,$p, $simparam{$p},$type,$content,$info, $table,$row,0,'noc_param');
		}
		
	   
	    #FPGA NAME
		$label='FPGA board';
		$param='FPGA_BOARD';
		$content=$fpgas;
		$type='Combo-box';
		$info="  I will add later"; 
		$row=noc_param_widget ($emulate,$label,$param, $default,$type,$content,$info, $table,$row,1,'fpga_param');
		
		
		#save as
		$label='Save as:';
		$param='SAVE_NAME';
		$default='emulate1';
		$content=undef;
		$type="Entry";
		$info="define generated sof file's name"; 
		$row=noc_param_widget ($emulate,$label,$param, $default,$type,$content,$info, $table,$row,1,'fpga_param');
		
		
		#Project_dir
		$label='Project directory';
		$param='SOF_DIR';
		$default="../../mpsoc_work/emulate";
		$content=undef;
		$type="DIR_path";
		$info="Define the working directory for generating .sof file"; 
		$row=noc_param_widget ($emulate,$label,$param, $default,$type,$content,$info, $table,$row,1,'fpga_param');
	   
	   	
	   
	   
	    	my $generate = def_image_button('icons/gen.png','Generate');
		
	   
		$table->attach ($generate, 0,3, $row, $row+1,'expand','shrink',2,2);
      
		$generate->signal_connect ('clicked'=> sub{
			generate_sof_file($emulate,$info_text);
			
		});
		
	    
	    return $scrolled_win;	
	
}







sub generate_sof_file {
	my ($emulate,$info)=@_;	
		print "start compilation\n";
		my $fpga_board=  $emulate->object_get_attribute ('fpga_param',"FPGA_BOARD");
		#create work directory
		my $dir_name=$emulate->object_get_attribute ('fpga_param',"SOF_DIR");
		my $save_name=$emulate->object_get_attribute ('fpga_param',"SAVE_NAME"); 
		$save_name=$fpga_board if (!defined $save_name);
		$dir_name= "$dir_name/$save_name";

		show_info($info, "generate working directory: $dir_name\n");
		
		
		#copy all noc source codes
		my @files =("mpsoc/src_noc/*", "mpsoc/src_emulate/rtl/*","mpsoc/src_peripheral/jtag/jtag_wb/*");
				

		my $dir = Cwd::getcwd();
		my $project_dir	  = abs_path("$dir/../../");
		my ($stdout,$exit)=run_cmd_in_back_ground_get_stdout("mkdir -p $dir_name/src/" );
		foreach my $f (@files){
			($stdout,$exit) =run_cmd_in_back_ground_get_stdout("cp -Rf \"$project_dir\"/$f \"$dir_name/src/\"" );
			if($exit != 0 ){ 	print "$stdout\n"; 	message_dialog($stdout); return;}
		}		

		
		
		#copy fpga board files
		
		($stdout,$exit)=run_cmd_in_back_ground_get_stdout("cp -Rf \"$project_dir/mpsoc/src_emulate/fpga/$fpga_board\"/*    \"$dir_name/\""); 
		if($exit != 0 ){ 	print "$stdout\n"; 	message_dialog($stdout); return;}
		
		#generate emulator_top.v file
		
		open(FILE,  ">$dir_name/emulator_top.v") || die "Can not open: $!";
		print FILE gen_emulate_top_v($emulate);
		close(FILE) || die "Error closing file: $!";
				
		
		#compile the code  
		my $Quartus_bin=  $ENV{QUARTUS_BIN};
		add_info($info, "Start Quartus compilation\n $stdout\n");
		($stdout,$exit)=run_cmd_in_back_ground_get_stdout( " cd \"$dir_name/\" 
					xterm  	-e $Quartus_bin/quartus_map --64bit $fpga_board --read_settings_files=on  
					xterm  	-e $Quartus_bin/quartus_fit --64bit $fpga_board --read_settings_files=on
					xterm  	-e $Quartus_bin/quartus_asm --64bit $fpga_board --read_settings_files=on
					xterm  	-e $Quartus_bin/quartus_sta --64bit $fpga_board
		");
		if($exit != 0){			
			print "Quartus compilation failed !\n";
			add_info($info, "Quartus compilation failed !\n $stdout\n");
			return;
			
		} else {
			#save sof file
			my $sofdir="$ENV{PRONOC_WORK}/emulate/sof";
			mkpath("$sofdir/",1,01777);
			open(FILE,  ">$sofdir/$save_name.inf") || die "Can not open: $!";
			print FILE perl_file_header("$save_name.inf");
			print FILE Data::Dumper->Dump([$emulate->{'noc_param'}],["NoCparam"]);
			close(FILE) || die "Error closing file: $!";	
			($stdout,$exit)=run_cmd_in_back_ground_get_stdout("cp $dir_name/output_files/$fpga_board.sof   $sofdir/$save_name.sof");
			if($exit != 0 ){ 	print "$stdout\n"; 	message_dialog($stdout); return;}
			message_dialog("sof file has been generated successfully"); return;			
		}
		
		
		
}

##########
#	save_emulation
##########
sub save_emulation {
	my ($emulate)=@_;
	# read emulation name
	my $name=$emulate->object_get_attribute ("emulate_name",undef);	
	my $s= (!defined $name)? 0 : (length($name)==0)? 0 :1;	
	if ($s == 0){
		message_dialog("Please set emulation name!");
		return 0;
	}
	# Write object file
	open(FILE,  ">lib/emulate/$name.EML") || die "Can not open: $!";
	print FILE perl_file_header("$name.EML");
	print FILE Data::Dumper->Dump([\%$emulate],[$name]);
	close(FILE) || die "Error closing file: $!";
	message_dialog("Emulation saved as lib/emulate/$name.EML!");
	return 1;
}

#############
#	load_emulation
############

sub load_emulation {
	my ($emulate,$info)=@_;
	my $file;
	my $dialog = Gtk2::FileChooserDialog->new(
            	'Select a File', undef,
            	'open',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);

	my $filter = Gtk2::FileFilter->new();
	$filter->set_name("EML");
	$filter->add_pattern("*.EML");
	$dialog->add_filter ($filter);
	my $dir = Cwd::getcwd();
	$dialog->set_current_folder ("$dir/lib/emulate");		


	if ( "ok" eq $dialog->run ) {
		$file = $dialog->get_filename;
		my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
		if($suffix eq '.EML'){
			my $pp= eval { do $file };
			if ($@ || !defined $pp){		
				add_info($info,"**Error reading  $file file: $@\n");
				 $dialog->destroy;
				return;
			} 

			clone_obj($emulate,$pp);
			#message_dialog("done!");				
		}					
     }
     $dialog->destroy;
}

############
#    main
############
sub emulator_main{
	
	add_color_to_gd();
	my $emulate= emulator->emulator_new();
	set_gui_status($emulate,"ideal",0);
	my $left_table = Gtk2::Table->new (25, 6, FALSE);
	my $right_table = Gtk2::Table->new (25, 6, FALSE);

	my $main_table = Gtk2::Table->new (25, 12, FALSE);
	my ($infobox,$info)= create_text();	
	my $refresh = Gtk2::Button->new_from_stock('ref');
	

	
	
	
	my $conf_box=process_notebook_gen($emulate,\$info);
	my $chart   =gen_chart  ($emulate);
    


	$main_table->set_row_spacings (4);
	$main_table->set_col_spacings (1);
	
	#my  $device_win=show_active_dev($soc,$soc,$infc,$soc_state,\$refresh,$info);
	
	
	my $generate = def_image_button('icons/forward.png','Run all');
	my $open = def_image_button('icons/browse.png','Load');
	
	
	
	
	my ($entrybox,$entry) = def_h_labeled_entry('Save as:',undef);
	$entry->signal_connect( 'changed'=> sub{
		my $name=$entry->get_text();
		$emulate->object_add_attribute ("emulate_name",undef,$name);	
	});	
	my $save = def_image_button('icons/save.png','Save');
	$entrybox->pack_end($save,   FALSE, FALSE,0);
	

	#$table->attach_defaults ($event_box, $col, $col+1, $row, $row+1);
	my $image = get_status_gif($emulate);
	
	
	
	
	
	$left_table->attach_defaults ($conf_box , 0, 6, 0, 20);
	$left_table->attach_defaults ($image , 0, 6, 20, 24);
	$left_table->attach ($open,0, 3, 24,25,'expand','shrink',2,2);
	$left_table->attach ($entrybox,3, 6, 24,25,'expand','shrink',2,2);
	$right_table->attach_defaults ($infobox  , 0, 6, 0,12);
	$right_table->attach_defaults ($chart , 0, 6, 12, 24);
	$right_table->attach ($generate, 4, 6, 24,25,'expand','shrink',2,2);
	$main_table->attach_defaults ($left_table , 0, 6, 0, 25);
	$main_table->attach_defaults ($right_table , 6, 12, 0, 25);
	
	

	#referesh the mpsoc generator 
	$refresh-> signal_connect("clicked" => sub{ 
		my $name=$emulate->object_get_attribute ("emulate_name",undef);	
		$entry->set_text($name) if(defined $name);


		$conf_box->destroy();
		$chart->destroy();
		$image->destroy(); 
		$image = get_status_gif($emulate);
		$conf_box=process_notebook_gen($emulate,\$info);
		$chart   =gen_chart  ($emulate);
		$left_table->attach_defaults ($image , 0, 6, 20, 24);
		$left_table->attach_defaults ($conf_box , 0, 6, 0, 12);
		$right_table->attach_defaults ($chart , 0, 6, 12, 24);

		$conf_box->show_all();
		$main_table->show_all();


	});



	#check soc status every 0.5 second. referesh device table if there is any changes 
	Glib::Timeout->add (100, sub{ 
	 
		my ($state,$timeout)= get_gui_status($emulate);
		
		if ($timeout>0){
			$timeout--;
			set_gui_status($emulate,$state,$timeout);	
			
		}
		elsif( $state ne "ideal" ){
			$refresh->clicked;
			#my $saved_name=$mpsoc->mpsoc_get_mpsoc_name();
			#if(defined $saved_name) {$entry->set_text($saved_name);}
			set_gui_status($emulate,"ideal",0);
			
		}	
		return TRUE;
		
	} );
		
		
	$generate-> signal_connect("clicked" => sub{ 
		my $sample_num=$emulate->object_get_attribute("emulate_num",undef);
		for (my $i=1; $i<=$sample_num; $i++){
			$emulate->object_add_attribute ("sample$i","status","run");	
		}
		run_emulator($emulate,\$info);
		#set_gui_status($emulate,"ideal",2);

	});

#	$wb-> signal_connect("clicked" => sub{ 
#		wb_address_setting($mpsoc);
#	
#	});

	$open-> signal_connect("clicked" => sub{ 
		
		load_emulation($emulate,\$info);
		set_gui_status($emulate,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 
		save_emulation($emulate);		
		set_gui_status($emulate,"ref",5);
		
	
	});	

	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
		$sc_win->set_policy( "automatic", "automatic" );
		$sc_win->add_with_viewport($main_table);	

	return $sc_win;
	

}


