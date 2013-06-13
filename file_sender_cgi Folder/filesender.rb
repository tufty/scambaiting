#!/usr/local/bin/ruby

require 'cgi'
require 'yaml'
$KCODE = "u"

# Find what files we purport to be serving and their lengths
files_served = YAML.load_file("/some/file/path.yaml") rescue {"crap" => 1024*5}

cgi = CGI.new("html4")
begin
  length = files_served[cgi['file']] || raise
  cgi.print cgi.header(
    'type' => 'application/x-pdf',
    'status' => 'OK',
    'server' => 'The Security Bureau file service 2.7b3',
    'Content-Length' => length,
    'expires' => Time.now + 30
  )
  unless "HEAD" == ENV['REQUEST_METHOD']
    tosend = length - 10
    count = 0
    cgi.print "%PDF-1.2\r\n"
    while tosend > 0
      puts count
      rts = tosend > 100 ? rand(98) : rand(tosend-2)
      tosend = tosend - rts - 2
      count = count + 1
      cgi.print((0..rts).inject(""){|m,v| m << sprintf("%c", rand(127))} + "\r\n")
      sleep (0.01 * (2 ** count))
    end
  end
rescue
  puts $!.inspect
  cgi.out(
    'type' => 'text/html',
    'server' => 'The Security Bureau file service 2.7b3',
    'status' => 'NOT FOUND'
  ) do
    cgi.html() do
      cgi.head {cgi.title {"FILE NOT FOUND"}}
      cgi.body {"<h1>FILE NOT FOUND</h1><p>You have probably cut and pasted an incorrect url or tried to access a file no longer hosted on this site</p>"}
    end
  end
end
