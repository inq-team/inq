#!/usr/bin/env ruby

require 'net/http'
require 'rexml/document'
require 'open-uri'

class Scanner
	attr_accessor :dev

	def svals=(sv)
		@svals[ sv=~/\d{10}/ ? 'S' : sv[/./] ] = sv
	end
	
	def svals
		@svals
	end
	
	def initialize(devname)
		puts 'Initialize Scanner'
		@svals = Hash.new
		@dev = File.open(devname)
		$scanners_dev << @dev
	end

	def preprocess_vals()
		@svals.keys.each {|k| @svals[k].sub!(/^\w0*/, '') if ['S', 'A', 'T', 'I', 'P'].index(k) != nil }
	end
	
	def process_vals()
		return -1 if @svals.size > 5
		$PAIRED_SCANS.each { |ps|    
			if @svals.keys.sort! == ps.sort! then
				puts "Scanned values:"
				puts @svals
				preprocess_vals()
				case ps
				    when ['C', 'S'] then
					open("http://#{$SERVER_ADDR}/computers/add_component/#{@svals['S']}.xml?type=Power+Supply&vendor=ColdWatt&model=CWA2-0650-10-IV01&serial=#{@svals['C']}")
				    when ['A', 'P', 'S', 'T'], ['A', 'I', 'P', 'S', 'T'] then 
					addrs=nil
					
					if @svals['I'] == nil then
					    begin 
						puts 'Trying get IP addresses range for place from web-server'
						addrs = open("http://#{$SERVER_ADDR}/shelves/active_addresses/#{svals['P']}").readlines.collect { |s| s.chomp }
					    rescue Exception => ex
						puts ex
						puts 'Can\'t get IP addresses range from WEB server. Try to wait it from scanner'
					    end

					    return 1 if addrs == nil
					else
					    addrs = Array.new.push(@svals['I'])
					    puts 'IP address got from scanner'
					    puts addrs
					    open("http://#{$SERVER_ADDR}/computers/set_shelf/#{@svals['S']}.xml?shelf=#{@svals['P']}")
					end
					
					open("http://#{$SERVER_ADDR}/computers/set_assembler/#{@svals['S']}.xml?assembler_id=#{@svals['A']}")
					open("http://#{$SERVER_ADDR}/computers/set_tester/#{@svals['S']}.xml?tester_id=#{@svals['T']}")
										
					addrs.each{ |a| Thread.new(a) { |la| send2ip_addr(la, @svals['S']) } }
					    
				end

				return 0
			end
		}
		return 1
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
end
