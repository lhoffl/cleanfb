require "cleanfb/version"

module Cleanfb

	class Clean

		##
		#		Method to remove ALL files backed up on the Puppet masters filebucket 
		#		from a specified agent.
		##
		def remove()

			# return if no args
			return "Please supply a file" if ARGV[0].nil? || ARGV[0].empty?
  			
			# return the help output if requested
			if ((ARGV.include? "-h") or (ARGV.include? "--help"))
				return "Remove backups of an agent from the Puppet master's filebucket.\n\n/
				Usage:   cleanfb <client>\n\n		options: -h or --help		| help and information\n/
				-y        		| defaults all input to yes\n"

			end

			arg = ARGV[0]	

			# set ans to yes automatically if -y option
			if !ARGV.nil? and (ARGV.include? "-y") and ARGV.length > 1
  	 		ans = "y"
				arg = ARGV[1] if (ARGV.index("-y") == 0)

			# else prompt for answer
			else
    		print "Remove #{arg} ? y|n: "
	   		ans = STDIN.gets.chomp
		  end

			# if yes, retrieve the files and remove them
  		if ans == "y" || ans == "yes"
    		cmd = `puppet filebucket list -l|grep -i #{arg}`
		 	  unless cmd.nil? || cmd.empty?
  	  	  cmd.each_line do |line|
	    	  	path = "/opt/puppetlabs/puppet/cache/bucket"
	     		  sum = line.split(" ")[0]
						start = (sum.scan /\w/).join("/")

  	     		path += "/" + start[0..15] + sum + "/"
	  	      puts "Removing " + path
						cmd = `rm -rf #{path}`
		 	    end
  	  	else
	    	  puts "No file #{arg} found."
		 	  end
	  	end
			return 
		end
	end
end
