# client/lib/bindings/communication.rb - A part of Inquisitor project
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

class Communication
	attr_reader :sh

	def initialize(background = false)
		if background then
			@sh = IO::popen('/bin/sh', 'w')
			@sh.puts("export COMPUTER_ID=#{ENV['COMPUTER_ID']}")
			@sh.puts('. /etc/inquisitor/global')
			@sh.puts('. $SHARE_DIR/functions')
			@sh.puts('. $SHARE_DIR/communication')
		else
			@sh = nil
		end
	end

	def method_missing(m, *args)
		cmd = "#{m} " + args.map { |a| "'#{a}'" }.join(' ')
		if @sh then
#			puts cmd
			@sh.puts(cmd)
		else
			cmd = "export COMPUTER_ID=#{ENV['COMPUTER_ID']} && . /etc/inquisitor/global && . $SHARE_DIR/functions && . $SHARE_DIR/communication && #{cmd} >$DEBUG_TTY 2>&1"
#			puts cmd
			system(cmd)
		end
	end
end
