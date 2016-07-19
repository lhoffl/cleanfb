#!/usr/bin/expect -f

spawn git add .
spawn git commit -m 'i'
spawn git push -u origin master

expect "Username for 'https://github.com': "
send "lhoffl\r"
expect "Password for 'https://lhoffl@github.com': "
send "${args[0]}\r"

bundle exec rake release 
expect "Username for 'https://github.com': "
send "lhoffl\r"
expect "Password for 'https://lhoffl@github.com': "
send "${args[0]}\r"
expect "Username for 'https://github.com': "
send "lhoffl\r"
expect "Password for 'https://lhoffl@github.com': "
send "${args[0]}\r"
