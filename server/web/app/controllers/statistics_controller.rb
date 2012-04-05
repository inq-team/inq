class StatisticsController < ApplicationController
	layout 'orders'

	def get_dates
		if params[:date]
			@from_day = params[:date]['from_day'].to_i
			@from_month = params[:date]['from_month'].to_i
			@from_year = params[:date]['from_year'].to_i

			@to_day = params[:date]['to_day'].to_i
			@to_month = params[:date]['to_month'].to_i
			@to_year = params[:date]['to_year'].to_i
		else
			@from_day = Date.today.day != 1 ? Date.today.day-1 : Date.today.day
			@from_month = Date.today.month
			@from_year = Date.today.year

			@to_day = Date.today.day
			@to_month = Date.today.month
			@to_year = Date.today.year
		end

		@from_date = Date.new( @from_year, @from_month, @from_day )
		@to_date = Date.new( @to_year, @to_month, @to_day )
	end

	def index
		get_dates
		available_assemblers = {}
		@stats = {}
		@model_stats = {}
		@complexities = {}
		@total_stats = { :complexity => {},
				 :computers => {} }
		computers_seen = {}
		ComputerStage.find_all_by_stage( "assembling", :conditions => ['end BETWEEN ? AND ?', @from_date, @to_date] ).each { |stage|
			computer = Computer.find_by_id( stage.computer_id )
			next if not computer
			computers_seen.has_key?( computer ) ? next : computers_seen[computer] = 1
			model = Model.find_by_id( computer.model_id )
			next if not model
			assembler = Person.find_by_id( stage.person_id )
			next if not assembler
			@model_stats[ model.name ] = @model_stats.has_key?( model.name ) ? @model_stats[ model.name ] + 1 : 1
			available_assemblers[assembler.name] = ""
			@stats[model.name] = {} if not @stats.has_key?(model.name)
			@stats[model.name][assembler.name] = @stats[model.name][assembler.name] ? @stats[model.name][assembler.name] + 1 : 1
			@complexities[model.name] = model.complexity ? model.complexity : 1
			@total_stats[:complexity][assembler.name] = @total_stats[:complexity][assembler.name] ? @total_stats[:complexity][assembler.name] + @complexities[model.name] : @complexities[model.name]
			@total_stats[:computers][assembler.name] = @total_stats[:computers][assembler.name] ? @total_stats[:computers][assembler.name] + 1 : 1
		}
		@available_assemblers = available_assemblers.keys.sort

		@total_computers = 0
		@model_stats.values.map{ |x| @total_computers += x }
	end

	def show
		from_date = Date.new( params[:from_year].to_i, params[:from_month].to_i, params[:from_day].to_i )
		to_date = Date.new( params[:to_year].to_i, params[:to_month].to_i, params[:to_day].to_i )
		@person = Person.find_by_name( params[:id] )
		@model = Model.find_by_name( params[:model] )
		@computers = {}

		ComputerStage.find_all_by_stage_and_person_id( "assembling", @person.id, :conditions => ['end BETWEEN ? AND ?', from_date, to_date] ).each { |stage|
			computer = Computer.find_by_id( stage.computer_id )
			next if not computer
			next if computer.model_id != @model.id
			@computers[computer.id] = ((stage.end - stage.start) / 60).to_i
		}
	end

	def rma
		@rma_stat = Model.find_by_sql("Select m.*, count(c.id) total, count(s1.computer_id) checking, count(s2.computer_id) testing, avg(s1.d1) cavg, avg(s2.d2) tavg from models as m join computers as c on m.id = c.model_id left join ( Select computer_id, datediff(end, now() - interval 3 year) d1 from computer_stages where stage = \'checking\' group by computer_id having min( end) > now() - interval 3 year ) as s1 on c.id = s1.computer_id left join ( Select computer_id, datediff(end, now() - interval 3 year) d2 from computer_stages where stage = \'testing\' and computer_id not in ( Select computer_id from computer_stages where stage = \'checking\') group by computer_id having min( end) > now() - interval 3 year ) as s2 on c.id=s2.computer_id group by m.id order by m.name;")
	end

	def assembly
		get_dates
		@assembly_stat = ComputerStage.find_by_sql("Select DATE(cs.end) ddmmyy, GROUP_CONCAT(DISTINCT c.id) comp, COUNT(cs.end) comp_count, SUM(m.complexity)/60.0 hours, COUNT(DISTINCT(csa.person_id)) asmbl_count, SUM(m.complexity)/(60.0*8*COUNT(DISTINCT(csa.person_id))) coef, GROUP_CONCAT(DISTINCT p.display_name) c, GROUP_CONCAT(DISTINCT pa.display_name) a, GROUP_CONCAT(DISTINCT pt.display_name) t from computer_stages AS cs JOIN computers AS c ON cs.computer_id=c.id JOIN models AS m on c.model_id=m.id LEFT JOIN computer_stages AS csa on cs.computer_id=csa.computer_id LEFT JOIN computer_stages AS cst on cs.computer_id=cst.computer_id JOIN people p ON cs.person_id=p.id JOIN people pa ON csa.person_id=pa.id JOIN people pt ON cst.person_id=pt.id where cs.stage=\"checking\" AND csa.stage=\"assembling\" AND cst.stage=\"testing\" AND cs.start > \'#{@from_date}\' AND cs.end < \'#{@to_date}\' GROUP BY DATE(cs.end);")
		@k = 0
		@comps = 0
		@assemblers = {}
		@assembly_stat.each do |i|
			@comps += i.comp_count.to_i
			if i.coef.to_f > 1
				c = i.coef.to_f - 1
				@k += (i.coef.to_f-1)
				@comps += i.comp_count.to_i
				asm = (i.c.split(',').concat(i.a.split(',')).concat(i.t.split(','))).uniq
				asm.each { |a| @assemblers.has_key?(a) ? @assemblers[a] += c : @assemblers[a] = c } 

			end
		end
	end

	def order_stages
		get_dates
		@order_stat = OrderStage.find_by_sql("Select o.id id, o.buyer_order_number n, os.end ord_end, os.start ord_start, osw.start osw_start, osw.end osw_end, osa.start osa_start, osa.end osa_end, MAX(csa.end) asm_end, MIN(csa.start) asm_start, MAX(cst.end) test_end, MIN(cst.start) test_start, MAX(csc.end) check_end, MIN(csc.start) check_start from orders o JOIN order_stages os ON o.id=os.order_id LEFT JOIN (select order_id, end, start from order_stages where stage='acceptance') osa ON o.id=osa.order_id LEFT JOIN (select order_id, end, start from order_stages where stage='warehouse') osw ON o.id=osw.order_id LEFT JOIN computers c ON o.id=c.order_id LEFT JOIN (select computer_id, end, start from computer_stages where stage='assembling') csa ON c.id=csa.computer_id LEFT JOIN (select computer_id, end, start from computer_stages where stage='testing') cst ON c.id=cst.computer_id LEFT JOIN (select computer_id, end, start from computer_stages where stage='checking') csc ON c.id=csc.computer_id where os.stage='ordering' AND os.start > \'#{@from_date}\' AND os.start < \'#{@to_date}\' group by o.id order by n;")

	end

	def computer_list
		@comp_ids = params[:ids].split(',')
		@co_co = Model.find_by_sql("Select m.name model, c.id comp_id, ap.name assembler, tp.name tester, cp.name checker from computers c LEFT JOIN models m ON c.model_id=m.id JOIN (Select p.display_name name, cs.computer_id id from computer_stages cs JOIN people p ON cs.person_id=p.id where cs.stage='assembling') ap ON c.id=ap.id JOIN (Select p.display_name name, cs.computer_id id from computer_stages cs JOIN people p ON cs.person_id=p.id where cs.stage='testing') tp ON c.id=tp.id JOIN (Select p.display_name name, cs.computer_id id from computer_stages cs JOIN people p ON cs.person_id=p.id where cs.stage='checking') cp ON c.id=cp.id where c.id in (#{@comp_ids.join(",")}) order by model;")
	end
end
