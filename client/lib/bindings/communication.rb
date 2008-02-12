class Communication
	attr_reader :sh

	def initialize
		@sh = IO::popen('/bin/sh', 'w')
		@sh.puts("export COMPUTER_ID=#{ENV['COMPUTER_ID']}")
		@sh.puts('. /etc/inquisitor/global')
		@sh.puts('. $SHARE_DIR/functions')
		@sh.puts('. $SHARE_DIR/communication')
	end

	def method_missing(m, *args)
		cmd = "#{m} " + args.map { |a| "'#{a}'" }.join(' ')
#		puts cmd
		@sh.puts(cmd)
	end
end
