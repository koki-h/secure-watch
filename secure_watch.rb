#!/usr/bin/ruby

require 'rubygems'
require 'file/tail'
require 'pony'
$pidfile="/var/run/secure_watch.pid"
$filename = "/var/log/secure"
$current_dir = File.dirname(File.expand_path(__FILE__))
$config = eval(`cat #{$current_dir}/config`)
#config format
#{:mail_username => 'user',
# :mail_password => 'pass'}

def mail(message)
  Pony.mail(:to   => 'gohannnotomo@gmail.com',
            :body => message,
            :subject => "[warning]serversman.gohannnotomo.org accepted password!",
            :via  => :smtp, 
            :via_options => {
    :enable_starttls_auto => true,            #TLSを使う
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :user_name            => $config[:mail_username],
    :password             => $config[:mail_password],
    :authenticaiotn       => :plain,          # gmailでは:plainでないとダメ
    :domain               => "gmail.com"      # smtp.gmail.comでもOK 
  })
end

def watch
  File.open($filename) do |log|
    log.extend(File::Tail)
    log.interval = 1
    log.backward(1)
    log.tail do |line|
      if line =~ /Accepted password/
        mail line 
      end
    end
  end
end

system("echo #{$$} > #{$pidfile}")
watch
