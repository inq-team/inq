class Stickercompat
	
	def initialize(options)
		name = options[:name]
		date = options[:date]
		serial = options[:serial]
		docno = options[:docno]
		components = options[:components]
		copies = options[:copies]
		qc = options[:qc]
		
		@str = "SPEED 2\n
DENSITY 10\n
SET CUTTER OFF\n
SET PEEL OFF\n
SET TEAR ON\n
DIRECTION 0\n
SIZE 3.980,2.910\n
GAP 0.120,0.00\n
OFFSET 0\n
REFERENCE 0,15\n
CLS\n"

		step = 32
		textheight = 28
		x = 647
		low = 71
		
		@str << "TEXT 790,40,\"3\",90,1,2,\"#{name}\"\n
BARCODE 799,390,\"128M\",58,0,90,2,2,\"!105#{serial}\"\n
TEXT 743,345,\"3\",90,1,1,\"S/N:#{serial}\"\n
BAR #{low},63,#{x+2*step-low},3\n
BAR #{low},522,#{x+2*step-low},1\n
BAR #{x+step},24,4,548\n
BAR #{x+2*step},24,4,548\n
TEXT #{x+step+textheight},34,\"2\",90,1,1,\"#\"\n
TEXT #{x+step+textheight},250,\"2\",90,1,1,\"P/N\"\n
TEXT #{x+step+textheight},532,\"2\",90,1,1,\"Qty\"\n"


		
		@str << File.open('public/images/bg-top.bmp').read
		@str << File.open('public/images/bg-bottom.bmp').read
		
		i = 1
		@str << components.inject('') do |s, c| 
			tx = x + textheight
			s += "BAR #{x},24,2,548\n
TEXT #{tx},34,\"2\",90,1,1,\"#{c}\"\n"
			i = i + 1
			x -= step
			s
		end
		
		@str << "BAR 69,24,3,549\n
BAR 18,440,54,3\n
TEXT 65,450,\"3\",90,1,1,\"Test OK\"\n
TEXT 38,450,\"3\",90,1,1,\"Check#{ qc }\"\n
TEXT 65,270,\"3\",90,1,1,\"#{date}\"\n
TEXT 38,270,\"3\",90,1,1,\"#{docno}\"\n
PRINT #{copies},1\n"
	end
	
	def send_to_printer(host, dev)
		if @str
			File.open('/tmp/bar.tmp', 'w'){ |f| f.puts(@str) }
			`</tmp/bar.tmp ssh #{host} "sudo  cat >#{dev}"`
		end
	end	
end
