require "cleanfb/version"
require 'digest'

module Cleanfb

  class Clean

    def remove()

      return "Please supply a file" if (ARGV[0].nil? || ARGV[0].empty?)
      
      help_msg = "Remove backups of an agent from the Puppet master filebucket.\nBackups are stored at /root/saved_configs/\n\n"

      return help_msg if ((ARGV.include? "-h") || (ARGV.include? "--help"))

      arg = ARGV[0]	

      if (!ARGV.nil? && (ARGV.include? "-y") && ARGV.length > 1)
        ans = "y"
        arg = ARGV[1] if (ARGV.index("-y") == 0)
        
      else
        print "Remove #{arg} ? y|n: "
        ans = STDIN.gets.chomp
      end

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

          Dir.mkdir(File.join(Dir.home("root"), "saved_configs"), 0700) unless (Dir.exist? save_dir)

          Dir.mkdir(File.join("#{save_dir}", "#{name}"), 0700) unless Dir.exist? "#{save_dir}/#{name}/"
                
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

      return "Please supply a file" if ARGV[0].nil? || ARGV[0].empty?
        
      arg = ARGV[1]	

      host = arg.scan(/_\w+\.\w+\.?\w+?_/).join("").gsub!("_", "")
      store(host)
      file = arg
      
      if File.exist? file
        puts  "puppet filebucket -l backup #{file}"
        cmd = `puppet filebucket -l backup #{file}`
      else
        puts "No file #{arg} found."
      end
     
      return
    end
    
  end	
end
