#!/bin/bash
#!/usr/bin/expect -f

git add .
git commit -m 'i'
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
