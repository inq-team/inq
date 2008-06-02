require 'digest/sha1'
class Person < ActiveRecord::Base
	def admin?
		is_admin
	end

	def remember_me
		self.remember_token_expires_at = 2.weeks.from_now
		self.remember_token = Digest::SHA1.hexdigest("inq--#{self.login}--#{self.remember_token_expires_at}")
#		self.password = ""  # This bypasses password encryption, thus leaving password intact
		self.save_with_validation(false)
	end

	def forget_me
		self.remember_token_expires_at = nil
		self.remember_token = nil
#		self.password = ""  # This bypasses password encryption, thus leaving password intact
		self.save_with_validation(false)
	end
end
