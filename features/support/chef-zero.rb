require 'chef_zero/server'

$chef_zero = ChefZero::Server.new(port: ENV['CHEF_ZERO_PORT'].to_i)
$chef_zero.start_background

Before do
  $chef_zero.clear_data
end

at_exit do
  $chef_zero.stop
end
