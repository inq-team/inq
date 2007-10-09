#!/usr/bin/env ruby
require 'raid/baseraid'

TLOG_ID=ENV['TLOG_ID']

class Log
	def self.failed(msg)
		`echo '#{msg}' | tlog #{TLOG_ID} 4 'stress [hdd r/w]'`
	end

	def self.info(msg)
		`echo '#{msg}' | tlog #{TLOG_ID} 2 'stress [hdd r/w]'`
	end
end

$qty = 0

def test_available
	drivenames = `ls -1 /sys/block/ | grep -v '[0-9]$'`.split(/\n/)
	puts "Drivenames: #{drivenames.join(',')}"
	system("./hdd-badblocks.rb #{drivenames.join(' ')}")
	if $?.exitstatus != 0
		puts "Error while testing discs!"
		exit 1
	end
	return drivenames.size
end

adapters = []
RAID::BaseRaid::query_adapters.each { |ad|
	a = RAID::RAIDS[ad[:driver]].new(ad[:num])	
	adapters << a
	a.logical_clear
	a.adapter_restart
}

$qty += test_available

adapters.each { |a|
	a.logical_clear
	pl = a._physical_list.keys
	while pl.size > 0
		# Select 8 discs to test
		now_testing = []
		8.times { now_testing << pl.pop }
		now_testing.compact!
		puts "Testing #{now_testing.join(',')}"

		# Prepare passthroughs
		a.logical_clear
		now_testing.each { |disc|
			a.logical_add('passthrough', disc, nil)
		}
		a.adapter_restart
		sleep 5
		test_available
		$qty += now_testing.size
	end
}

$req_qty = `tquery get_testable hdd`.to_i

puts "========================================================================="
puts "Requested #{$req_qty} discs."
puts "Finished with #{$qty} discs."
puts "========================================================================="

if $qty != $req_qty
	Log.failed("Requested #{$req_qty} discs, finished with #{$qty} discs.")
	exit 1
else
	exit 0
end
