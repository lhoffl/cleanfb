require "cleanfb/version"

module Cleanfb

	class Clean
		def remove()
			return "Please supply a file" if ARGV[0].nil? || ARGV[0].empty?
  			
			if ((ARGV.include? "-h") or (ARGV.include? "--help"))
				return "Remove backups of an agent from the Puppet master's filebucket.\n\n		Usage:   cleanfb <client>\n\n		options: -h or --help		| help and information\n		         -y        		| defaults all input to yes\n"
			end
			arg = ARGV[0]	
			if !ARGV.nil? and (ARGV.include? "-y") and ARGV.length > 1
  	 		ans = "y"
				arg = ARGV[1] if (ARGV.index("-y") == 0)
			else
    		print "Remove #{arg} ? y|n: "
	   		ans = STDIN.gets.chomp
		  end
  		if ans == "y" || ans == "yes"
    		cmd = `puppet filebucket list -l|grep -i #{arg}`
		 	  unless cmd.nil? || cmd.empty?
  	  	  cmd.each_line do |line|
    	  	  folders = "/opt/puppetlabs/puppet/cache/bucket"
	     		  sum = line.split(" ")[0]
						start = sum.scan /\w/
						start = start.join("/")

  	     		folders += "/" + start.substring(0,7) + "/" + sum + "/"
  	     		#folders += "/" + sum[0] + "/" + sum[1] + "/" + sum[2] + "/" + sum[3] + "/" + sum[4] + "/" + sum[5] + "/" + sum[6] + "/" + sum[7] + "/"
#	        	folders += sum + "/"
	  	      puts "Removing " + folders
  	 		    cmd = `rm -rf #{folders}`
		 	    end
  	  	else
	    	  puts "No file #{arg} found."
		 	  end
	  	end
			return 
		end
	end
end
