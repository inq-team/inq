class OrderSearchController < ApplicationController
	def index
	end
	
	def search
		start_date = (params[:datetime_start][:use] == '1') ? params[:start_date] : ''
		end_date = (params[:datetime_end][:use] == '1') ? params[:end_date] : ''
		start_date = sprintf("%04d-%02d-%02d %02d:%02d:%02d", params[:datetime]['start(1i)'], params[:datetime]['start(2i)'], params[:datetime]['start(3i)'], params[:datetime]['start(4i)'], params[:datetime]['start(5i)'], 0)
		end_date = sprintf("%04d-%02d-%02d %02d:%02d:%02d", params[:datetime]['end(1i)'], params[:datetime]['end(2i)'], params[:datetime]['end(3i)'], params[:datetime]['end(4i)'], params[:datetime]['end(5i)'], 0)
		start_date = (params[:datetime_start][:use] == '1') ? start_date : ''
		end_date = (params[:datetime_end][:use] == '1') ? end_date : ''
		conditions1 = [ [:customer, params[:customer]], [:buyer_order_number, params[:number]] ].select{ |x| not x[1].to_s.empty? }.map{ |x| "#{x[0].to_s}='#{x[1]}'" }.join(' AND ')
		dates = [[:start, start_date], [:end, end_date]].select{ |d| not d[1].to_s.empty? }
		conditions2 = ['order_stages.start', 'computer_stages.start'].map { |start|	dates.map{ |d| "#{start}#{d[0]==:start ? '>' : '<'}'=#{d[1]}'"}.join(' AND ') }
		conditions2 = conditions2.select{ |x| not x.to_s.empty? }
		conditions2 = conditions2.map{ |s| "(#{s})" }.join(' OR ') if conditions2.size > 1
		conditions = [conditions1, conditions2].select{ |x| not x.to_s.empty? }
		conditions = conditions.map{ |s| "(#{s})" }.join(' AND ') if conditions.size > 1
		conditions = conditions.to_s
		orders = Order.find(:all, :conditions => [conditions, start_date, end_date, start_date, end_date], :include => [:order_stages, { :computers => :computer_stages }])
		txt = '<table>'
		orders.each do |z|
			txt += "<tr><td><a href=\"/orders/show/#{z.id}\">#{z.id}, #{z.customer}</a></td></tr>"
		end
		txt += '</table>'
		render :text => txt
	end
end
