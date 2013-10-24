# Older plugin initializer
# (borrowed from http://stackoverflow.com/questions/9107531/how-to-deal-with-vendor-plugins-after-upgrading-to-rails-3-2-1)
#
# Should be removed after full transition to Rails 4+

Dir[Rails.root.join('lib', 'plugins', '*')].each do |plugin|
  next if File.basename(plugin) == 'initializers'

  lib = File.join(plugin, 'lib')
  $LOAD_PATH.unshift lib

  begin
    require File.join(plugin, 'init.rb')
  rescue LoadError
    begin
      require File.join(lib, File.basename(plugin) + '.rb')
    rescue LoadError
      require File.join(lib, File.basename(plugin).underscore + '.rb')
    end
  end

  initializer = File.join(File.dirname(plugin), 'initializers', File.basename(plugin) + '.rb')
  require initializer if File.exists?(initializer)
end
