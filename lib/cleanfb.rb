require "cleanfb/version"
require 'digest'
require 'optparse'

module Cleanfb
  
  class Clean
    
    @force = false
    @hostname = ""
    @restore = ""

    def parse_input
      OptionParser.new do |opts|
        opts.banner = "Usage: cleanfb [options]..."
        opts.on("-f", "--force", "ignore all prompts") { |f| @force = f }
        opts.on("-nNAME", "--name=NAME", "hostname to clean") { |n| @hostname = n }
        opts.on("-rRESTORE", "--restore=FILE", "file to restore") { |r| @restore = r } 
        opts.on_tail("-h", "--help", "display this message") { puts opts; exit }
      end.parse!
    end

    def remove

      if @hostname == ""
        puts "Hostname required. See cleanfb --help for usage."
        return
      end

      unless @force  
        print "Remove #{@hostname}? (y|n): "
        ans = STDIN.gets.chomp
      end

      if(@force || ans =~ /^y/) 
        cmd = `puppet filebucket list -l|grep -i #{@hostname}`
        
        unless @force 
          test = cmd.split(" ").last
          multi_match = false

          cmd.each_line { |line| (multi_match = true) if (!line.include? test) }
            
          if multi_match
            print "Matched multiple hosts. Remove all? (y|n): "
            ans = STDIN.gets.chomp
                
            return unless (@force || ans =~/^y/)
          end
        end			
        
        (backup cmd) unless (cmd.nil? || cmd.empty?)
      end
    end
   
    def backup cmd 
          
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
          puts "No file #{@hostname} found."
        end
      end
    end

    def restore
     
      if @restore == ""
        puts "File to restore required. See cleanfb --help for usage."
        return
      end

      host = @restore.scan(/_\w+\.\w+\.?\w+?_/).join("").gsub!("_", "")
      backup `puppet filebucket list -l| grep -i #{host}`
      file = host
      
      if File.exist? file
        puts  "puppet filebucket -l backup #{file}"
        cmd = `puppet filebucket -l backup #{file}`
      else
        puts "No file #{@restore} found to restore."
      end
    end
    
  end	
end
