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
		@assembly_stat = ComputerStage.find_by_sql("Select DATE(cs.end) ddmmyy, COUNT(cs.end) comp_count, SUM(m.complexity)/60.0 hours, COUNT(DISTINCT(csa.person_id)) asmbl_count, SUM(m.complexity)/(60.0*8*COUNT(DISTINCT(csa.person_id))) coef from computer_stages AS cs JOIN computers AS c ON cs.computer_id=c.id JOIN models AS m on c.model_id=m.id JOIN computer_stages AS csa on cs.computer_id=csa.computer_id where cs.stage=\"checking\" AND csa.stage=\"assembling\" AND cs.start > \'#{@from_date}\' AND cs.end < \'#{@to_date}\' GROUP BY DATE(cs.end);")
		@k = 0
		@assembly_stat.each { |i| @k += i.coef.to_f if i.coef.to_f > 1}
	end

end
