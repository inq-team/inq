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
	
	def process_vals()
	    if @scan_vals.size > 4 then
		return -1
	    end
	    $PAIRED_SCANS.each { |ps|
    
		if @scan_vals.sort!.map{|i| i[/./]} == ps.sort! then
		    puts "Scanned values:"
		    puts @scan_vals
			    
		    r=check_vals(ps)
		    return r if r!=0
			    
		    system_id=@scan_vals[ps.index('S')][1..-1]
		    ps.each { |actn|
			scanned_id=@scan_vals[ps.index(actn)][1..-1]
			case actn
			    when 'P'
				process_ip(scanned_id, system_id)
			    when 'T'
				process_it(scanned_id, system_id)
			    when 'I'
				process_ii(scanned_id, system_id)
			end
			
		    }
		    return 0
		end
	    }
	    return 1
	end
	
	def check_vals(exp_vals)
	    puts @scan_vals.size
	    if @scan_vals.size > 4 then
		
		return -1
	    end
	    if exp_vals.index('I')==nil && $IP_BY_PLACE[@scan_vals[exp_vals.index('P')][1..-1]]==nil then
		return 1
	    end
	    
	    return 0
	end
	
	
	def send2place(ip_range, system_id)
	    host1=nil
	    host2=nil
	    subnet=nil
	    
	    ip_range.scan(/^(\d+\.\d+\.\d+\.)(\d+)\s\d+\.\d+\.\d+\.(\d+)/){|subnet, host1, host2|}
	    puts "Trying to send to #{host1} .. #{host2}"
	    host1.to_i.step(host2.to_i, 1){|h| Thread.new(h) { |lh| send2ip_addr(subnet+"#{lh}", system_id) }}
	end
	
	def send2ip_addr(ip_addr, system_id)
	    begin
		puts "Trying to send ID(#{system_id}) to #{ip_addr}:#{$CLIENT_PORT}"
		TCPSocket.new(ip_addr, $CLIENT_PORT).puts(system_id)
	    rescue Exception => ex
		puts ex
		puts "Error: can not connect to client on #{ip_addr}:#{$CLIENT_PORT}"
	    end
	end    
	
	def process_ii(ip_id, system_id)
	    send2ip_addr(ip_id, system_id)
	end
	
	def process_ip(place_id, system_id)
	    puts "Match to place (#{place_id})"
	    puts  "Send shelf"
	    puts "curl \"http://#{$SERVER_ADDR}/computers/set_shelf/#{system_id}.xml?shelf=#{place_id}\""
	    system("curl \"http://#{$SERVER_ADDR}/computers/set_shelf/#{system_id}.xml?shelf=#{place_id}\"")
	    
	    ip_range=$IP_BY_PLACE[place_id]
	    send2place(ip_range, system_id) if ip_range!=nil
	    
	    
	end
	
	def process_it(tid, id)
	    puts  "Send tester ID"
	    puts "curl \"http://#{$SERVER_ADDR}/computers/set_tester/#{id}.xml?tester_id=#{tid}\""
	    system("curl \"http://#{$SERVER_ADDR}/computers/set_tester/#{id}.xml?tester_id=#{tid}\"")
	end
	
	def process_ia(aid, id)
	    puts "Send assembler ID to server ..."
	    puts "curl -i \"http://#{$SERVER_ADDR}/computers/set_assembler/#{id}.xml?assembler_id=#{aid}\""
#	    system("curl -i \"http://#{$SERVER_ADDR}/computers/set_assembler/#{id}.xml?assembler_id=#{aid}\"")
	end
end
