module Mykit

class Item
	attr_accessor :string, :chunks, :sense, :properties, :components, :vendors, :keywords, :sku
	def initialize(s, sku = nil)
		Lexer.lex(s, sku).each { |k, v| send("#{ k }=".to_s, v) }
	end
end


end
