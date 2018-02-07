require "cleanfb/version"
require 'digest'
require 'optparse'

module Cleanfb
  
  class Clean
    
    options = {}
    hostname = ""

    def show_help
      puts "HELP"
      exit 0
    end

    def parse_input
      OptionParser.new do |opts|
        opts.banner = ""
        opts.on("-h", "--help", "Display help information") {show_help}
        opts.on("-f", "--force", "Ignore all prompts") { |f| options[:force] = f }
        opts.on("-nNAME", "--name=NAME", "Hostname") { |n| hostname = n }
      end
    end


    def remove()
      
      unless options[:force]  
        print "Remove #{hostname} ? y|n: "
        ans = STDIN.gets.chomp
      end

      if(options[:force] || ans =~ /^y/) 
        cmd = `puppet filebucket list -l|grep -i #{hostname}`
          
        unless options[:force] 
          test = cmd.split(" ").last
          multi_match = false

          cmd.each_line { |line| (multi_match = true) if (!line.include? test) }
            
          if multi_match
            print "Matched multiple hosts. Remove all? y|n: "
            ans = STDIN.gets.chomp
                
            return "Ending run"	unless (options[:force] || ans =~/^y/)
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
              
            Dir.mkdir(File.join(Dir.home("root"), "saved_configs"), 0700) unless (Dir.exist? save_dir)

            Dir.mkdir(File.join("#{save_dir}", "#{name}"), 0700) unless (Dir.exist? "#{save_dir}/#{name}/")
                
            path += "/" + start[0..15] + sum + "/"
                    
            if File.exist? "#{path}/contents"
              puts "Storing " + path
              puts "at /root/saved_configs/#{name}/#{date}_#{time}_#{file}"
              cmd = `mv -f #{path}contents /root/saved_configs/#{name}/#{date}_#{time}_#{file}`
              cmd = `rm -rf #{path}`
            else
              puts "No file #{hostname} found."
            end
          end
        end
      
      else
        puts "No file #{hostname} found."
      end
      
      return 
    end
    
    def store(host)

      cmd = `puppet filebucket list -l|grep -i #{host}`
      unless(cmd.nil? || cmd.empty?)
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
          Dir.mkdir(File.join("#{save_dir}", "#{name}"), 0700) unless (Dir.exist? "#{save_dir}/#{name}/")
                
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

      return "Please supply a file" if (ARGV[0].nil? || ARGV[0].empty?)
        
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
