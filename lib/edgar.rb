$:.unshift File.join File.dirname(__FILE__), 'edgar'
%w[time_series forecast group_forecast].each {|l| require l}