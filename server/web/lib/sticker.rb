class Sticker
	def initialize(conf, count)
		@str = "SPEED 2\r
DENSITY 10\r
SET CUTTER OFF\r
SET PEEL OFF\r
SET TEAR ON\r
DIRECTION 0\r
SIZE 3.980,2.910\r
GAP 0.120,0.00\r
OFFSET 0\r
REFERENCE 0,0\r
CLS\r"

		@str << File.open('public/images/bg-top.bmp').read
		@str << File.open('public/images/bg-bottom.bmp').read                                                                     
		step = 32
		textheight = 28
		x = 512
		low = 71
		model = conf[:computer].model.dmi_name
		serial = sprintf("%010d", conf[:computer].id)

		@str << "TEXT 655,40,\"3\",90,1,2,\"#{model}\"\r
BARCODE 666,400,\"128M\",58,0,90,2,2,\"!105#{serial}\"\r
TEXT 610,355,\"3\",90,1,1,\"S/N:#{serial}\"\r
BAR #{low},63,#{x+2*step-low},3\r
BAR #{low},522,#{x+2*step-low},1\r
BAR #{x+step},24,4,548\r
BAR #{x+2*step},24,4,548\r
TEXT #{x+step+textheight},34,\"2\",90,1,1,\"#\"\r
TEXT #{x+step+textheight},250,\"2\",90,1,1,\"P/N\"\r
TEXT #{x+step+textheight},532,\"2\",90,1,1,\"Qty\"\r"

		i = 1
		conf[:components].each do |c|
			tx = x + textheight
			label_name = c[:name][0..34]
        	qty = c[:count]
            
			@str << "BAR #{x},24,2,548\r
TEXT #{tx},34,\"2\",90,1,1,\"#{i}\"\r
TEXT #{tx},75,\"2\",90,1,1,\"#{label_name}\"\r
TEXT #{tx},538,\"2\",90,1,1,\"#{qty}\"\r"
			
			i++
            x -= step
		end
		
		fdate = nil;
		if conf[:computer].computer_stages[-1]
			fdate = conf[:computer].computer_stages[-1].end.strftime("%d.%M.%Y")
		end
		doc_no = conf[:computer].doc_no
		
		@str << "BAR 69,24,3,549\r
BAR 18,440,54,3\r
TEXT 65,450,\"3\",90,1,1,\"Test OK\"\r
TEXT 65,270,\"3\",90,1,1,\"#{fdate}\"\r
TEXT 38,270,\"3\",90,1,1,\"#{doc_no}\"\r
PRINT #{count},1\r"
		
		@str
	end
	
	def send_to_printer(host, dev)
		if @str
			File.open('/tmp/bar.tmp', 'w'){ |f| f.puts(@str) }
			`</tmp/bar.tmp ssh #{host} "sudo  cat >#{dev}"`
		end
	end
	
	def self.send_custom_sticker_to_printer(host, dev, custom)
		File.open('/tmp/bar.tmp', 'w'){ |f| f.puts(custom) }
		`</tmp/bar.tmp ssh #{host} "sudo  cat >#{dev}"`
	end

	def smth(options)
		@name = options[:name]
		@date = options[:date]
		@serial = options[:serial]
		@docno = options[:docno]
		@components = options[:components]
		
		#...	

		@components.inject("") do |s, c| 
			s + "BAR #{x},24,2,548\r
TEXT #{tx},34,\"2\",90,1,1,\"#{c}\"\r"
		end

		#...
	end
end
