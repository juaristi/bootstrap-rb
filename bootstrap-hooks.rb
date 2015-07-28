#!/usr/bin/env ruby

class UserHandlers < Bootstrap::Handlers
  def post_checkout(info)
    puts "[POST] A 'git checkout' was run."
    puts "-- Project root: " + info['bt-root']
    puts "-- Checkout root: " + info['bt-checkout-root']
    puts "-- Git root: " + info['bt-checkout-git-root']
    super(info)
  end 
end