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
