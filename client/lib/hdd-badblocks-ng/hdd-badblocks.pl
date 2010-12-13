#!/usr/bin/perl

use warnings;
use strict;

use threads ("exit" => "threads_only");
use threads::shared;
use Getopt::Std;

################################################################################
# Configuration
################################################################################
my $UPDATE_PERIOD = 10;
my $BADBLOCKS_COMMAND = "badblocks -sv ";
my $BB_THRESHOLD = 1; # Bad controllers can give single ATA error, but
                      # this does not mean that HDD is bad. As a rule
                      # it will have several badblocks.

my %sd :shared;
my %threads;
my %speed;
my %graph;
my %options;

my $mw;
my %hdds_gui;
my $status_bar;
my $bb_loop_started = 0;

# Dummy ID, for example, if we are using LiveCD
$ENV{COMPUTER_ID} = 0 if not defined $ENV{COMPUTER_ID};

################################################################################
# subs section
################################################################################
sub usage {
	return "Usage: $0 [-g graph_datafile] [-m mode] [-b blocksize] 
                          [-p pattern] [-o blocks_at_once] [-i] [-t] 
                          [-n] hard_drives

-g \t Path to file containig data for graphs drawing
-m \t readonly, non-destructive or destructive. Default is readonly
-b \t Size of blocks in bytes. Default is 1024
-p \t Test pattern to be read (and written) to disk blocks
-o \t Number of blocks which are tested at a time. Default is 64
-i \t Enable Inquisitor related communication function
-t \t Switch to Tk based user interface
-n \t Do not clear screen while redrawing progress information

Badblocks threshold: $BB_THRESHOLD block
Update period: $UPDATE_PERIOD sec\n";
};

sub start_badblocks {
	my $harddrive = shift;
	my $c;
	my $str = "";

	# Start badblocks program itself
	sleep( int( rand( $#ARGV ) ) );
	open IN, "$BADBLOCKS_COMMAND $harddrive 2>&1 |" or exit 1;
	while(not eof IN){
		$c = getc IN;
		if($c =~ /[0-9 \/\ta-zA-Z:%,\.]/) { $str .= $c }
		else {
			# Read first line to retrieve total blocks number
			if($str =~ /0 to (\d+)$/){
				$sd{$harddrive}{total} = $1;
			};

			# Count badblocks number
			$sd{$harddrive}{found}++ if $str =~ /^\d+$/;

			# Override badblocks number by already calculated by badblocks
			if($str =~ /(\d+)\s*bad blocks found/){ $sd{$harddrive}{found} = $1 };

			# Check if it is completed
			if($str =~ /completed/){
				$sd{$harddrive}{doned} = $sd{$harddrive}{total};
				close IN and exit;
			};

			# Here we are deciding which parser to use,
			# because of badblocks possible different
			# output formats
			if($str =~ / ([0-9.]+)% done, .* elapsed/){
				$sd{$harddrive}{doned} = int( $sd{$harddrive}{total} * $1 * 0.01 );
			} else {
				next unless $str =~ /(\d+)\s*\/\s*\d+/;
				$sd{$harddrive}{doned} = $1;
			};

			# Clear string
			$str = "";
		};
	};
	close IN or exit 1;
};

sub alive_threads {
	my $num = 0;

	# Count number of alive threads
	foreach (keys %sd) { $num++ if $threads{$_}->is_running() };

	return $num;
};

# This is Inquisitor's specific communication function
sub inq_communication {
	system "export COMPUTER_ID=$ENV{COMPUTER_ID} && \
		. _inq-config-global && \
		. \$SHARE_DIR/functions && \
		. \$SHARE_DIR/communication && $_[0] >\$DEBUG_TTY 2>&1";
};

sub redraw_screen {
	my $str;

	my $total_doned = 0;
	my $total_total = 0;
	my $drives = scalar keys %sd;
	my $running = 0;
	my $finished = 0;
	my $maxeta = 0;
	my $bad = 0;

	# Collect total statistics
	foreach (keys %sd) {
		$total_total += $sd{$_}{total};
		$total_doned += $sd{$_}{doned};
	};

	# Clear screen
	print "\e[H\e[2J" unless (defined $options{n} or defined $options{t});

	foreach my $key (sort keys %sd) {
		# Hard drive name and it's percentage
		$str = sprintf "[%9s] [%3d%%] ", $key,
				$sd{$key}{total} ? int($sd{$key}{doned}*100 / $sd{$key}{total}) : 0;

		if(($sd{$key}{total} == 0) and !$threads{$key}->is_running()){
			# Badblocks failed to startup
			$str .= sprintf "[Failed  ]\n";
			$bad++;
		}
		elsif(($sd{$key}{total} == 0) and $threads{$key}->is_running()){
			# Badblocks thread is running but currently we didn't recieve total blocks number
			$str .= sprintf "[Waiting ]\n";
		}
		elsif(($sd{$key}{total} != $sd{$key}{doned}) and !$threads{$key}->is_running()){
			# Badblocks was working but died
			$str .= sprintf "[Died    ] [BB %10d]\n", $sd{$key}{found};
			$bad++;
		}
		elsif($sd{$key}{total} == $sd{$key}{doned}){
			$str .= sprintf "[Finished] [BB %10d]\n", $sd{$key}{found};
			$finished++;
		}
		else {
			# Speed calculation
			my $doned = $sd{$key}{doned};
			my $speed = int(($doned - $speed{$key}) / $UPDATE_PERIOD);
			# Save current doned blocks count to use it later
			$speed{$key} = $doned;

			# ETA calculation
			my $eta = "NaN";
			if($speed){
				$eta = ($sd{$key}{total} - $sd{$key}{doned}) / ($speed * 60);
				$maxeta = $eta if $eta > $maxeta;
				$eta = sprintf "%2d:%2d", int($eta / 60), int($eta % 60);
			};

			$str .= sprintf "[Running ] [BB %10d] [%8d blocks/sec] [ETA: $eta]\n", 
					$sd{$key}{found}, $speed;
			$bad++ if $sd{$key}{found};
			$running++;

			# Graph
			if(defined $options{g}){ push @{$graph{$key}}, $speed };
		};

		if(defined $options{t}){
			update_text_value($hdds_gui{$key}, $str);
		} else {
			print $str;
		};
	};

	inq_communication "test_progress $total_doned $total_total" if defined $options{i};

	# Print short totals
	# Assume we are using 80x25 display
	$str = sprintf "\nTotal drives: %2d  Running: %2d  Finished: %2d  %3d%%  Bad: %2d  ETA: %5s\n", 
			$drives, $running, $finished, 
			$total_total ? int($total_doned*100 / $total_total) : 0,
			$bad, 
			sprintf "%2d:%2d", int($maxeta / 60), int($maxeta % 60);

	if(!defined $options{t} and $drives < 23){
		print $str;
	} elsif (defined $options{t}){
		update_text_value($status_bar, $str);
	};
};

sub update_text_value {
	my ($obj, $str) = @_;

	$obj->delete("0.0", "end");
	$obj->insert("end", $str);
	$obj->update();
};

sub exit_gui {
	foreach (keys %threads) { $threads{$_}->detach() };
	exit;
};

sub init_gui {
	#use Tk;
	#use Tk::ProgressBar;

	$mw = MainWindow->new(-title => "hdd-badblocks");
	$mw ->Button(-text => "Begin",
		     -command => sub { bb_loop() unless $bb_loop_started })->pack(-expand => 1,
										  -fill => "x",
										  -side => "top");
	$status_bar = $mw->Text(-height => "2")->pack(-expand => 1,
						      -fill => "x",
						      -side => "top");
	$mw->protocol('WM_DELETE_WINDOW', \&exit_gui);
};

sub write_graph_data {
	my @output_graph_data = ();
	my $i;

	open OUT, "> $options{g}" or die "Unable to open output graph data file\n";

	# Create some kind of header
	print OUT "time ";
	foreach (sort keys %graph){ print OUT "$_ " };

	# Find maximal time values and fill up time column first
	my $max_time = 0;
	foreach (keys %graph) { $max_time = $#{$graph{$_}} if $max_time < $#{$graph{$_}} };
	for($i = 0; $i < $max_time; $i++) { $output_graph_data[$i] = "" . $i * $UPDATE_PERIOD };

	# Create columns with time and speed values
	foreach (sort keys %graph){
		for($i = 0; $i < $#{$graph{$_}}; $i++){
			$output_graph_data[$i] .= " $graph{$_}[$i]";
		};
	};

	# Print them out
	foreach (@output_graph_data) { print OUT "\n$_" };
	close OUT;
};

# Finish with necessary return codes and bad HDDs printing
sub return_bad_hdds {
	my @bad_hdds;

	foreach (sort keys %sd) { push @bad_hdds, $_ if $sd{$_}{found} > $BB_THRESHOLD };

	if($#bad_hdds >= 0){
		# There are bad HDDs
		my $msg = "Failed HDD: " . join(" ", @bad_hdds);
		print STDERR "$msg\n";

		if(defined $options{t}){
			$mw->messageBox(-message => $msg,
					-type => 'ok');
		} else {
			perform_exit(1);
		};
	} else {
		# There are no bad HDDs
		if(defined $options{t}){
			$mw->messageBox(-message => "There are no bad HDDs",
					-type => 'ok');
		} else {
			perform_exit(0);
		};
	};
};

# Main function where goes sleeping, screen redrawing exiting and etc
sub bb_loop {
	$bb_loop_started++;
	while( alive_threads() ) { sleep $UPDATE_PERIOD; redraw_screen(); };
	redraw_screen();
	write_graph_data() if defined $options{g};
	return_bad_hdds();
};

sub perform_exit {
	foreach (keys %threads) { $threads{$_}->join() };
	exit shift;
};

################################################################################
# Main
################################################################################
getopts("g:nitm:b:p:o:", \%options);
my @harddrives = @ARGV;
die usage() if $#harddrives < 0;

# Fill up badblocks command line
$BADBLOCKS_COMMAND .= defined $options{b} ? "-b $options{b} " : "-b 1024 ";
$BADBLOCKS_COMMAND .= "-t $options{p} " if defined $options{p} and $options{p} ne "";
$BADBLOCKS_COMMAND .= defined $options{o} ? "-c $options{o} " : "-c 64 ";
for($options{m}){
	if( $_ and /non-destructive/ ){ $BADBLOCKS_COMMAND .= "-n "; };
	if( $_ and /^destructive/ ){ $BADBLOCKS_COMMAND .= "-w "; };
};
print "Badblocks command: $BADBLOCKS_COMMAND\n";

init_gui() if defined $options{t};

# Initialize and fill up all hashes, startup all threads
foreach (@harddrives) {
	die "$_ is not a block device\n" unless -b $_;

	# Initialize shared hash
	$sd{$_} = &share({});
	$sd{$_}{found} = 0;
	$sd{$_}{doned} = 0;
	$sd{$_}{total} = 0;
	$sd{$_}{total} = 0;

	# Start badblocks thread itself
	$threads{$_} = threads->create('start_badblocks', $_);

	# Initialize speed and graphs hashes
	$speed{$_} = 0;
	$graph{$_} = [0];

	# Create entitity for hard drive in GUI
	if(defined $options{t}){
		$hdds_gui{$_} = $mw->Text(-height => "1")->pack(-side => "bottom",
								-expand => 1) if defined $options{t};
		update_text_value($hdds_gui{$_}, "$_");
	};
};

if(defined $options{t}){
	MainLoop();
} else {
	bb_loop();
};
