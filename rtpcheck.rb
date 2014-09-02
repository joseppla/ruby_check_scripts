#!/usr/bin/env ruby
require 'net/http'
require 'getoptlong'
require 'socket'
###################################################################################################
# Small demo ruby script for checking some local http stats and sending to graphite using sockets #
###################################################################################################




# Declaring options, variables and usage

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--server', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--sampling-interval', '-i', GetoptLong::OPTIONAL_ARGUMENT ]
)

server = nil
port = nil
sampling_interval = 30 #Default value
if ARGV[0] == nil
  puts "usage: rtpengine.rb -s server -p port [-i <sampling_interval>] or -h/--help"
  exit
end

# Parsing command line options

opts.each do |opt, arg|
  
  case opt
    when '--help'
      puts <<-EOF
rtpengine.rb -s hostname -p port [-i <sampling_interval>]

-h, --help:
  show help
-s, --server
  server IP address, hostname
-p, --port
  server port
-i, --sampling-interval
  desired check interval
      EOF
    exit
    when '--server'
  server = arg
    when '--port'
  port = arg.to_i
    when '--sampling-interval'
  sampling_interval = arg
  end
end

    s = TCPSocket.open('127.0.0.1', 2003)
# Collection loop
  while true do
    start_run = Time.now.to_i
    next_run = start_run + sampling_interval

    # collect data and write values to a socket
    data = Net::HTTP.get_response(server,'/metrics', port)
    tmp = data.body
    temp = tmp.split(':')[10]
    sessions = temp.split('}')[0]
    s.puts("jinglertp_EU.sessions #{sessions} #{Time.now.to_i}")
    
    # sleep to make the interval
    while((time_left = (next_run - Time.now.to_i)) > 0) do
      sleep(time_left)
    end
  end
