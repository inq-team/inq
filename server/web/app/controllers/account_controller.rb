require 'ldap'
require 'time'
require 'yaml'

class AccountController < ApplicationController
	layout 'orders'

	# say something nice, you goof!  something sweet.
	def index
		redirect_to(:action => 'login') unless logged_in? || Person.count > 0
	end

	def login
		return unless request.post?
		self.current_person = authenticate(params[:login], params[:password])
		if logged_in?
			if params[:remember_me] == '1'
				self.current_person.remember_me
				cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
			end
			redirect_back_or_default(:controller => '/account', :action => 'index')
			flash[:notice] = "Logged in successfully"
		end
	end
  
	def logout
#		self.current_person.forget_me if logged_in?
		cookies.delete :auth_token
		reset_session
		flash[:notice] = "You have been logged out."
		redirect_back_or_default(:controller => '/account', :action => 'index')
	end

	def authenticate(login, password)
		begin
			auth = Authenticator.new
			auth.initialization()
			u = auth.authenticate(login, password)
			u
		rescue => e
			flash[:error] = e.to_s
			logger.error e.inspect
			logger.error e.backtrace
			nil
		end
	end

	class Authenticator
		connection = nil
		host = nil
		port = nil
		domain = nil
		dn = nil

		def initialization()
			config = YAML::load(File.open("#{RAILS_ROOT}/config/active_directory.yml"))
			@host = config["host"]
			@port = config["port"]
			@domain = config["domain"]
			@dn = config["dn"]
		end

		def authenticate(login, password)
			db_user = Person.find_by_login(login)
				email = login + "@" + @domain
				connection = LDAP::Conn.new(@host, @port)
				connection.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
				connection.bind( email, password )
				connection.search( @dn, LDAP::LDAP_SCOPE_SUBTREE, "sAMAccountName=#{login}") do |ad_user|
					db_user = Person.new unless db_user
					db_user.login = login
					db_user.email = email
					db_user.display_name = ad_user.vals("displayName").to_s
					db_user.given_name = ad_user.vals("givenName").to_s
					db_user.last_login_at = Time.new
					db_user.is_assembler = 0
					db_user.is_student = 0
					db_user.save
				end
				
				@connection = connection
				db_user
		end

		def close
			@connection.unbind unless @connection == nil
			@connection = nil
		end
	end
end
