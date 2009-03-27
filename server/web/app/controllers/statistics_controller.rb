class StatisticsController < ApplicationController
	layout 'orders'

	def index
		if params[:date]
			@from_day = params[:date]['from_day'].to_i
			@from_month = params[:date]['from_month'].to_i
			@from_year = params[:date]['from_year'].to_i

			@to_day = params[:date]['to_day'].to_i
			@to_month = params[:date]['to_month'].to_i
			@to_year = params[:date]['to_year'].to_i
		else
			@from_day = Date.today.day - 1
			@from_month = Date.today.month
			@from_year = Date.today.year

			@to_day = Date.today.day
			@to_month = Date.today.month
			@to_year = Date.today.year
		end

		from_date = Date.new( @from_year, @from_month, @from_day )
		to_date = Date.new( @to_year, @to_month, @to_day )

		available_assemblers = {}
		@stats = {}
		@complexities = {}
		@total_stats = {}
		ComputerStage.find_all_by_stage( "assembling", :conditions => ['end BETWEEN ? AND ?', from_date, to_date] ).each { |stage|
			computer = Computer.find_by_id( stage.computer_id )
			next if not computer
			model = Model.find_by_id( computer.model_id )
			next if not model
			assembler = Person.find_by_id( stage.person_id )
			next if not assembler
			available_assemblers[assembler.name] = ""
			@stats[model.name] = {} if not @stats.has_key?(model.name)
			@stats[model.name][assembler.name] = @stats[model.name][assembler.name] ? @stats[model.name][assembler.name] + 1 : 1
			@complexities[model.name] = model.complexity ? model.complexity : 1
			#@total_stats[assembler.name] = @total_stats[assembler.name] ? @total_stats[assembler.name] + model.complexity : model.complexity
			@total_stats[assembler.name] = @total_stats[assembler.name] ? @total_stats[assembler.name] + @complexities[model.name] : @complexities[model.name]
		}
		@available_assemblers = available_assemblers.keys.sort
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
end
