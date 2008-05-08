#!/usr/bin/env ruby
# server/scannerd/daemonize.rb - A part of Inquisitor project
# Copyright (C) 2004-2008 by Iquisitor team 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

	Syslog.open('scannerd', Syslog::LOG_PID|Syslog::LOG_CONS, Syslog::LOG_DAEMON)
	def puts(x)
		Syslog.info(x)
	end
end
