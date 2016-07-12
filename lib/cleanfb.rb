require "cleanfb/version"

module Cleanfb

	class Clean
		def remove()
			return "Please supply a file" if ARGV[0].nil? || ARGV[0].empty?
  		
			if (ARGV[0] == "-h" or ARGV[0] == "--help")	
				return "Removes an agent's backups from the Puppet filebucket on the server.\n\n		Usage: cleanfb <client>\n\n		options: -h or --help		| help and information\n		         -y        		| defaults all input to yes\n"
			end	
			arg = ARGV[0]	
			if !ARGV[1].nil? and ARGV[1] == "-y"
  	 		ans = "y"
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
  	     		folders += "/" + sum[0] + "/" + sum[1] + "/" + sum[2] + "/" + sum[3] + "/" + sum[4] + "/" + sum[5] + "/" + sum[6] + "/" + sum[7] + "/"
	        	folders += sum + "/"
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
