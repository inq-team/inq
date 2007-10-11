#!/usr/bin/env ruby

require 'net/http'
require 'rexml/document'

class Scanner
	attr_accessor :dev, :scan_vals

	def initialize(devname)
		puts 'Initialize Scanner'
		@scan_vals=[]
		@dev = File.open(devname)
		$scanners_dev << @dev
		p @dev
	end
	
	def proccess_vals()
	    if @scan_vals.size == 3
		    if @scan_vals.sort!.map{|i| i[/./]} == $PAIRED_SCANS[0].sort! then
			puts "Scaned values:"
			puts @scan_vals
			
			system_id=@scan_vals[$PAIRED_SCANS[0].index('S')].sub(/S[0]+/, '')
			place_id=@scan_vals[$PAIRED_SCANS[0].index('P')]
			tester_id=@scan_vals[$PAIRED_SCANS[0].index('T')]
			
			proccess_ip(place_id.sub(/./,''), system_id)
			proccess_it(tester_id.sub(/./,''), system_id)
		    else
			return -1
		    end
		return 0
	    elsif @scan_vals.size < 3 
		return 1
	    else
		return -1
	    end
	end
	
	def send2place(ip_range, system_id)
	    host1=nil
	    host2=nil
	    subnet=nil
	    
	    ip_range.scan(/^(\d+\.\d+\.\d+\.)(\d+)\s\d+\.\d+\.\d+\.(\d+)/){|subnet, host1, host2|}
	    puts "Tryinf send to #{host1} .. #{host2}"
	    host1.to_i.step(host2.to_i, 1){|h| Thread.new(h) { |lh| send_id2ip_addr(subnet+"#{lh}", system_id) }}
	end
	
	def send_id2ip_addr(ip_addr, system_id)
	    begin
		puts "Trying send ID(#{system_id}) to #{ip_addr}:#{$CLIENT_PORT}"
		TCPSocket.new(ip_addr, $CLIENT_PORT).puts(system_id)
	    rescue Exception => ex
		puts ex
		puts "Error: can not connect to client on #{ip_addr}:#{$CLIENT_PORT}"
	    end
	end    
	
	
	def proccess_ip(place_id, system_id)
	    puts "Match to place (#{place_id})"
	    puts  "Send shelf"
	    puts "curl \"http://#{$SERVER_ADDR}/computers/set_shelf/#{system_id}.xml?shelf=#{place_id}\""
	    system("curl \"http://#{$SERVER_ADDR}/computers/set_shelf/#{system_id}.xml?shelf=#{place_id}\"")
	    send2place($IP_BY_PLACE[place_id], system_id)
	end
	
	def proccess_it(tid, id)
	    puts  "Send tester ID"
	    puts "curl \"http://#{$SERVER_ADDR}/computers/set_tester/#{id}.xml?tester_id=#{tid}\""
	    system("curl \"http://#{$SERVER_ADDR}/computers/set_tester/#{id}.xml?tester_id=#{tid}\"")
	end
	
	def proccess_ia(aid, id)
	    puts "Send assembler ID to server ..."
	    puts "curl -i \"http://#{$SERVER_ADDR}/computers/set_assembler/#{id}.xml?assembler_id=#{aid}\""
#	    system("curl -i \"http://#{$SERVER_ADDR}/computers/set_assembler/#{id}.xml?assembler_id=#{aid}\"")
	end
end
