#!/usr/bin/env ruby

require 'syslog'

def go_daemon
#	unless Process.uid == 0
#		$stderr.puts "#{$0} must be run as root!"
#		exit!
#	end

	Dir.chdir '/var/log/'
	File.umask 077
	trap "SIGCHLD", "IGNORE"

	if $DEBUG
		$stderr.puts "DEBUG enabled, running in foreground"
	else
		## close unneeded descriptors
		$stdin.close
		$stdout.close
		$stderr.close

		## drop into the background.
		pid = fork
		if pid
			## parent: save pid of child, then exit
			File.open($pid_file, "w") { |file| file.puts pid }
			exit!
		end
		
		## change process group and lose control tty
		Process.setpgrp
	end

	## Run at higher priority so that runaways won't get away, but try
	## not to directly compete with sched, pageout, and fsflush.
	#Process.setpriority Process::PRIO_PROCESS, Process.pid, -10

	## Initialize syslog
	#$thishost = Socket.gethostbyname(Socket.gethostname)[0]
	#$sl = Syslog.new('pray', Syslog::LOG_PID|Syslog::LOG_CONS, Syslog::LOG_DAEMON)

	Syslog.open('inquisitord', Syslog::LOG_PID|Syslog::LOG_CONS, Syslog::LOG_DAEMON)
	def puts(x)
		Syslog.info(x)
	end
end
