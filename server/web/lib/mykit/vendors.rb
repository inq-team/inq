module Mykit

class Vendors
	@@vendors = nil

	def self.find_all()
		unless @@vendors 	
	        	db_vendors = ComponentModel.find_by_sql("select distinct vendor from component_models").collect { |a| a.vendor }
			@@vendors = db_vendors.collect { |s| s.split(/\s+/).first unless s.blank? }.compact
		end
		@@vendors
	end
end

end
