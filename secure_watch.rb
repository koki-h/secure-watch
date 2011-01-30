#!/usr/bin/ruby

require 'rubygems'
require 'file/tail'
require 'pony'
$pidfile="/var/run/secure_watch.pid"
$filename = "/var/log/secure"
$current_dir = File.dirname(File.expand_path(__FILE__))
$config = eval(`cat #{$current_dir}/config`)
#config format
# see : config.sample

def mail(message)
  Pony.mail(:to   => $config[:mail_to],
            :body => message,
            :subject => $config[:mail_subject],
            :via  => :smtp, 
            :via_options => {
    :enable_starttls_auto => $config[:tls_enable],
    :address              => $config[:smtp_host],
    :port                 => $config[:smtp_port],
    :user_name            => $config[:mail_username],
    :password             => $config[:mail_password],
    :authenticaiotn       => $config[:mail_auth],
    :domain               => $config[:domain],
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
