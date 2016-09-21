require "cleanfb/version"
require 'digest'

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
				return "Remove backups of an agent from the Puppet master's filebucket.\nBackups are stored at /root/saved_configs/\n\n		Usage:   cleanfb <client> <options>\n\n		options: -h or --help		| help and information\n
				-y		| defaults all input to yes\n"

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
		 	  
				unless (ARGV.include? "-y")
					test = cmd.split(" ").last
					multi_match = false

					cmd.each_line do |line|
							if !line.include? test
									multi_match = true
							end
					end	
					
					if multi_match
						print "Matched multiple hosts. Remove all? y|n: "
						ans = STDIN.gets.chomp
						
						unless ans == "y" || ans == "yes"
							return "Ending run"	
						end
					end
				end			
				

				unless cmd.nil? || cmd.empty?
  	  	  cmd.each_line do |line|
	    	  	path = "/opt/puppetlabs/puppet/cache/bucket"
	     		  sum = line.split(" ")[0]
						start = (sum.scan /\w/).join("/")
						
						file = line.split(" ")[3].split("/").last
						name = file.split("_")[0]
						date = line.split(" ")[1]
						time = line.split(" ")[2]
						
						save_dir = "/root/saved_configs/"

						unless Dir.exist? save_dir
								Dir.mkdir(File.join(Dir.home("root"), "saved_configs"), 0700)
						end

						unless Dir.exist? "#{save_dir}/#{name}/"
							Dir.mkdir(File.join("#{save_dir}", "#{name}"), 0700)
						end
					
	  	     	path += "/" + start[0..15] + sum + "/"
						
						if File.exist? "#{path}/contents"
							
								puts "Storing " + path
								puts "at /root/saved_configs/#{name}/#{date}_#{time}_#{file}"
								cmd = `mv -f #{path}contents /root/saved_configs/#{name}/#{date}_#{time}_#{file}`
								cmd = `rm -rf #{path}`
						else
	    	  		puts "No file #{arg} found."
						end
		 	    end
  	  	else
	    	  puts "No file #{arg} found."
		 	  end
	  	end
			return 
		end
		
		def store(host)

    		cmd = `puppet filebucket list -l|grep -i #{host}`
				unless cmd.nil? || cmd.empty?
  	  	  cmd.each_line do |line|
	    	  	path = "/opt/puppetlabs/puppet/cache/bucket"
	     		  sum = line.split(" ")[0]
						start = (sum.scan /\w/).join("/")
						
						file = line.split(" ")[3].split("/").last
						name = file.split("_")[0]
						date = line.split(" ")[1]
						time = line.split(" ")[2]
						
						save_dir = "/root/saved_configs/"

						unless Dir.exist? save_dir
								Dir.mkdir(File.join(Dir.home("root"), "saved_configs"), 0700)
						end

						unless Dir.exist? "#{save_dir}/#{name}/"
							Dir.mkdir(File.join("#{save_dir}", "#{name}"), 0700)
						end
					
	  	     	path += "/" + start[0..15] + sum + "/"
						
						if File.exist? "#{path}/contents"
							
								puts "Storing " + path
								puts "at /root/saved_configs/#{name}/#{date}_#{time}_#{file}"
								cmd = `mv -f #{path}contents /root/saved_configs/#{name}/#{date}_#{time}_#{file}`
								cmd = `rm -rf #{path}`
						else
	    	  		puts "No file #{host} found."
						end
		 	    end
  	  	else
	    	  puts "No file #{host} found."
		 	  end
			return 
		end

		def restore()

			# return if no args
			return "Please supply a file" if ARGV[0].nil? || ARGV[0].empty?
  			
			# return the help output if requested
			if ((ARGV.include? "-h") or (ARGV.include? "--help"))
				return "Remove backups of an agent from the Puppet master's filebucket.\nBackups are stored at /root/saved_configs/\n\n		Usage:   cleanfb <client> <options>\n\n		options: -h or --help		| help and information\n
				-y		| defaults all input to yes\n"

			end

			arg = ARGV[1]	

			# set ans to yes automatically if -y option
			if !ARGV.nil? and (ARGV.include? "-y") and ARGV.length > 1
  	 		ans = "y"
				arg = ARGV[1] if (ARGV.index("-y") == 0)

			# else prompt for answer
			else
    		print "Restore #{arg} ? y|n: "
	   		ans = STDIN.gets.chomp
		  end

			# if yes, retrieve the files and remove them
  		if ans == "y" || ans == "yes"
				
				host = arg.scan(/[^_\$_]/)[2]
				puts host
	
				store(host)

				file = arg
				sum = Digest::MD5.file file
				sum = sum.hexdigest + ""
				start = (sum.scan /\w/).join("/")
	    	path = "/opt/puppetlabs/puppet/cache/bucket"
				
				path += "/" + start[0..15] + sum + "/"

				if File.exist? file
						puts "Restoring " + path
						unless Dir.exist? path 
							cmd = `mkdir -p #{path}`
						end
						cmd = `mv -f #{file} #{path}contents`
				else
	    	  		puts "No file #{arg} found."
				end
  	 	else
	    	  puts "No file #{arg} found."
		 	end
			return
		end
	end	
end
