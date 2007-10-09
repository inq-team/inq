#!/usr/bin/env ruby

TLOG_ID=ENV['TLOG_ID']
p TLOG_ID

class Screen
	def self.clear
		print "\e[H\e[2J"
	end

	def self.vputs(y, str)
		print "\e[#{y + 1}d#{str}\n"
	end
end

class Log
	def self.failed(msg)
		`echo '#{msg}' | tlog #{TLOG_ID} 4 'stress [hdd r/w]'`
	end

	def self.info(msg)
		`echo '#{msg}' | tlog #{TLOG_ID} 2 'stress [hdd r/w]'`
	end
end

class DiscTest
	# Configuration
	PERIOD_LOG=15*60
	PERIOD_SCREEN=2

	def initialize(devices)
		@devices = devices
		@progress = []
		@process = []
		@done = []
		@total = []
	end

	def start
		# Start badblocks for each given HDD
		@devices.each_with_index { |hdd, i|
			next if not hdd or hdd.strip.empty?

			pw = IO::pipe   # pipe[0] for read, pipe[1] for write
			pr = IO::pipe
			pe = IO::pipe

			# Fork and start badblocks process
			@process[i] = fork {
			        pw[1].close
			        STDIN.reopen(pw[0])
			        pw[0].close

			        pr[0].close
			        STDOUT.reopen(pr[1])
			        STDERR.reopen(pr[1])
			        pr[1].close

#			        pe[0].close
#			        pe[1].close

			        exec("badblocks -sv /dev/#{hdd}")
			}

			pw[0].close
			pr[1].close
			pe[1].close

			# stdin, stdout, stderr = [pw[1], pr[0], pe[0]]

			# Start watcher thread that will make sure that pipe buffer
			# won't overflow
			Thread.new {
				badblocks_output = pr[0]
				while l = badblocks_output.gets("\b") do
					@progress[i] = l if l =~ /\d/
					if l =~ /(\d+)\s*\/\s*(\d+)/
						@done[i] = $1.to_f
						@total[i] = $2.to_f
						@total[i] = 1 if @total[i] < 1
					end
				end
			}
		}
	end

	def start_show_progress
		# Screen logging thread
		Thread.new {
			while true do
				sleep PERIOD_SCREEN
				begin
					draw_progress
				rescue Exception => e
					puts e.backtrace
				end
			end
		}

		# Database logging thread
		Thread.new {
			while true do
				sleep PERIOD_LOG
				begin
					log_progress
				rescue Exception => e
					puts e.backtrace
				end
			end
		}
		sleep 1
		puts "Running background badblocks checks: " + @process.inspect
	end

	def draw_progress
		@progress.each_with_index { |pr, i|
			msg = sprintf("HDD #%-8d [", i + 1)
			if @done[i] and @total[i] then
				perc = (@done[i] / @total[i]) * 60
				msg += '#' * perc + '.' * (60 - perc)
			else
				msg += ' UNKNOWN ' + ' ' * (60 - 9)
			end
			msg += ']'
			Screen::vputs(i + 1, msg)
		}
	end

	def log_progress
		sum_done = 0
		sum_total = 0
		@progress.each_with_index { |pr, i|
			sum_done += @done[i] if @done[i]
			sum_total += @total[i] if @total[i]
		}
		sum_total = 1 if sum_total == 0
		perc = (sum_done / sum_total * 100).to_i
		Log::info("Progress: #{perc}%")
	end

	def wait_completion
		statuses = Process.waitall
		draw_progress
		puts "\n\nAll statuses=#{statuses.inspect}"

		status = 0
		statuses.each { |s|
			if s[1].exitstatus > 0
				ind = @process.index(s[0])
				if ind then
					failed_hdd = @devices[ind]
					Log::failed("Single HDD test failed: #{failed_hdd}")
					status = s[1].exitstatus 
				end
			end
		}
		puts "Status=#{status}"
		return status
	end
end

Screen::clear
Screen::vputs(20, "Testing HDDs: " + ARGV.inspect)
t = DiscTest.new(ARGV)
t.start
t.start_show_progress
exit t.wait_completion
