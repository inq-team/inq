module Waitstring

def self.send_to_computer(computer, message, config)
	shelf = config.by_ipnet(computer.ip) if computer.ip
	shelf = config[computer.shelf] if !shelf && computer.shelf 
	return nil unless shelf
        shelf.get_addresses().each { |a| Thread.new(a) { |aa| send2ip_addr(aa, message) } }
end

def self.send2ip_addr(ip_addr, message)
        begin
                puts "Trying to send MESSAGE(#{ message }) to #{ ip_addr }:#{ WAITSTRING_CLIENT_PORT }"
                TCPSocket.new(ip_addr, WAITSTRING_CLIENT_PORT).puts(message)
        rescue Exception => ex
                puts ex
        end
end   

end
