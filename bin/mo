#!/usr/bin/env ruby

require 'ftools'
require 'fileutils'

def usage
  puts "mo [options] <project> <context> [<version>]"
  puts "\nOptions"
  puts "   -quiet         Supress normal output"
  exit 1
end

def quiet_puts(string = "")
  puts string unless @quiet
end

def check_project
  File.makedirs File.join(ENV['HOME'], '.MO')
  
  @src_dir = File.join(ENV['HOME'], '.MO', @project)
  
  if !(File.directory?(File.join(@src_dir, '.git')))
    if !File.exists?('.MO')
      print "\nPlease enter a valid git repository URL (e.g. git@217.33.244.230:lvscm_example.git): "
      url = $stdin.gets.chomp
      `git clone #{url} #{@src_dir}`
    end
  end
  
  File.makedirs File.join(@src_dir, 'MO')
  
end


def dest_dir
  filename = File.join(@src_dir, 'MO', 'target.dat')
  if File.file? filename
    @dest_dir = File.read(filename).chomp
  else
    print "\nPlease enter the target folder: "
    @dest_dir = $stdin.gets.chomp
    File.open(filename, 'w') { |f| f.puts @dest_dir }
  end
end


def check_git
  version = `git --version`
  path = `git --exec-path`
  quiet_puts "Running #{version.chomp} found in '#{path.chomp}'"
end


def check_context(exit_on_fail = false)
  ok = false
  filename = File.join(@src_dir, 'MO', 'contexts.dat')
  unless File.file? filename
    puts "WARNING: #{filename} does not exist.  Context validation skipped."
    return true
  end
  
  contexts = File.read(filename).split("\n")

  contexts.each do |c|
    expr = Regexp.new(c)
    if @context =~ expr
      ok = true
      break
    end
  end
  
  if ok
    quiet_puts "Context     '#{@context}'"
  else
    puts "Context     '#{@context}' is not valid."
    exit 1 if exit_on_fail
  end
  ok
end


def do_version
  if @version
    expr = Regexp.new("#{@version}\n")
    if `git --git-dir=#{@src_dir}/.git branch` =~ expr
      quiet_puts "Using version '#{@version}'"
      `git --git-dir=#{@src_dir}/.git --work-tree=#{@src_dir} checkout #{@version}`
      `git --git-dir=#{@src_dir}/.git --work-tree=#{@src_dir} reset --hard`
    else
      puts "Version     '#{@version}' is not valid."
      exit 1
    end 
  else
    version = (`git --git-dir=#{@src_dir}/.git branch`.match(/\*\s\w+\n/))[0].split[1]
    quiet_puts "Version     '#{version}'"
  end
end


def parse_data(src, dest)
  input = File.open(src, 'r')
  data = input.readline

  # # The first line should contain the patterm "modusoperandi n.n.n" and some option include / exclude tags terminated by CR LF.
  matchdata = data.match(/modusoperandi v(\d+\.\d+\.\d+)(.*?)[\r\n]+/)
  if matchdata.nil?
    # This is not a valid MO file, do not attempt to interpret it.
    input.close
    quiet_puts "  COPY  | #{src}"
    File.copy(src, dest)
    return
  end

  quiet_puts "  PARSE | #{src}"
  version = matchdata[1]
  conditions = matchdata[2]

  matchdata = conditions.match(/(include|exclude)_for\s*\((.*?)\)/)
  if !matchdata.nil?
    include = true
    if (matchdata[1] == 'exclude')
      include = false
    end

    expr = Regexp.new(matchdata[2])
    if (include)
      if (@context !~ expr)
        File.delete(dest) if File.file?(dest)
        return
      end
    else
      if (@context =~ expr)
        quiet_puts "  SKIP  | #{src}"
        File.delete(dest) if File.file?(dest)
        return
      end
    end
  end

  output = File.open(dest, 'w')

  data = input.read
  input.close


  # 1. Match either 'include' or 'exclude' [1]
  # 2. Match '_for'
  # 3. Match 0 or more spaces
  # 4. Match '('
  # 5. Match all characters (non-greedy) [2]
  # 6. Match ')'
  # 7. Match 0 or more spaces, carriage returns or linefeeds
  # 8. Match '{'
  # 9. Match 0 or more spaces, carriage returns or linefeeds
  # 10. Match all characters (non-greedy) [3]
  # 11. Match '}'
  # 12. Match a space, carriage return or linefeed
  while (matchdata = data.match(/(include|exclude)_for\s*\((.*?)\)\s*\{\s*(.*?)\}\s/m))

    output.print matchdata.pre_match
    include = true
  if (matchdata[1] == 'exclude')
      include = false
    end

    expr = Regexp.new(matchdata[2])

    if (include)
      if (@context =~ expr)
        output.puts matchdata[3]
      end
    end

    if (!include and @context !~ expr)
      output.puts matchdata[3]
    end

    data = matchdata.post_match
  end

  output.print data
  output.close
end

@quiet = false
ARGS = ARGV.delete_if do |arg|
  @quiet = true if arg == '-quiet'
  arg[0].chr == '-'
end

usage() unless ARGS.size > 1

@project = ARGS[0]
@context = ARGS[1]
@version = ARGS[2] # If no tag is set, we will always continue with the current git branch

check_project() # Will check the project exists in $HOME/.MO and then set @src_dir

dest_dir()

check_git()
check_context(true)
do_version()

quiet_puts "Destination '#{@dest_dir}'\n\n"

olddir = Dir.pwd
Dir.chdir(@src_dir)

File.makedirs @dest_dir

Dir["**/*"].each do |file|
  if file !~ /^MO/
    dest = File.join(@dest_dir, file)
    if File.directory?(file)
      File.makedirs(dest)
    else 
      parse_data(file, dest)
    end
  end
end
Dir.chdir(olddir)
quiet_puts