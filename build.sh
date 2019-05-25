#!/usr/bin/env ruby

require 'fileutils'
require 'json'

class String
    %w{black red green yellow blue magenta cyan white}.each_with_index do |colour, index|
        define_method "#{colour}" do
            return "\e[3#{index}m#{self}\e[0m"
        end
        define_method "#{colour}_bkg" do
            return "\e[4#{index}m#{self}\e[0m"
        end
    end

    # %w{bold italic underline blink reverse_colour}.each_with_index, do |special, index|
    #     define_method "#{special}" do
    #         return "\e[#{index}m#{self}\e[2#{index}m"
    #     end
    # end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_colour; "\e[7m#{self}\e[27m" end

end

class Flags
    attr_accessor :build_flag
    attr_accessor :clean_flag
    attr_accessor :tasks_flag
    attr_accessor :default_flag
    attr_accessor :verbose_flag
    attr_accessor :properties_file

    def initialize(arguments)
        self.build_flag = false
        self.clean_flag = false
        self.tasks_flag = false
        self.default_flag = true
        self.verbose_flag = false
        self.properties_file = 'build.json'

        arguments.each do |item|
            case item
            when 'clean'
                self.clean_flag = true
                self.default_flag = false
            when 'build'
                self.build_flag = true
                self.default_flag = false
            when 'tasks'
                self.tasks_flag = true
            when /-f=(.*)/
                self.properties_file = $1
            when '-verbose'
                self.verbose_flag = true
            else
                puts "Invalid parameter option #{item.white.bold}"
                self.tasks_flag = true
            end
        end
    end

end

class BuildProperties
    attr_accessor :target, :output
    attr_accessor :source_dirs, :source_filters
    attr_accessor :compiler, :compiler_options
    attr_accessor :linker, :linker_options
    attr_accessor :language

    def initialize(properties)
        self.target = properties['target'] || 'output'
        self.output = properties['output'] || './build'

        self.compiler = properties['cc'] || 'cc'
        self.linker = properties['ld'] || 'ld'
        self.language = properties['language'] || 'c17'
        
        self.source_dirs = properties['sources'] || [ './' ]
        self.source_filters = properties['filters'] || []
        
        self.compiler_options = properties['compiler.options'] || []
        self.linker_options = properties['linker.options'] || []
    end

end



def tasks
    puts 'Build System Tasks:'
    puts 'clean - Clean the build directory'
    puts 'build - Build the target executable'
    puts 'tasks - Print the build tasks list'
    puts '-f=<filename> - Use <filename> for the build project properties'
    puts '-verbose - Enable verbose output'
    exit! 0
end

def clean properties
    puts 'Cleaning build directory'
    FileUtils.rm_r properties.output if File.exists? properties.output
    puts "#{'SUCCESS'.green} - Project build directory cleaned"
end

def build properties, verbose
    FileUtils.mkdir_p "#{properties.output}/objs"
    FileUtils.mkdir_p "#{properties.output}/exec"

    File.delete "#{properties.output}/exec/#{properties.target}" if File.exists? "#{properties.output}/exec/#{properties.target}"

    include_dirs = properties.source_dirs.map {|dir| "-I#{dir}" }.join ' '
    puts "Include Directories: #{include_dirs}".cyan if verbose

    count = 0
    properties.source_dirs.each do |dir|
        Dir.each_child(dir) do |name|
            next if name == '.' || name == '..'
            extension = File.extname name
            # TODO: Use properties.source_filters here instead of this extension check
            if properties.source_filters.length == 0
                puts "Reviewing: #{dir}/#{name}".cyan if verbose
                next if [ '.h', '.o', '.swp', '.sh', '.bat', '.cmd', '.ps1' ].include? extension
                next unless [ '.c', '.cpp', '.cxx', '.c++' ].include? extension
            else
                match = false
                properties.source_filters.each do |filter|
                    puts "Reviewing: #{dir}/#{name} => #{filter} -> #{name} :: #{name.match? Regexp.new(filter)}".cyan if verbose
                    match ||= name.match? Regexp.new(filter)
                end
                next unless match
            end

            basename = File.basename(name, extension)

            puts "#{'Compiling'.blue}: " + "#{dir}/#{name}".white.bold
            puts "#{properties.compiler} -c -o #{properties.output}/objs/#{basename}.o #{dir}/#{name} -std=#{properties.language} #{properties.compiler_options.join(' ')} #{include_dirs}".cyan if verbose
            puts %x{ #{properties.compiler} -c -o #{properties.output}/objs/#{basename}.o #{dir}/#{name} -std=#{properties.language} #{properties.compiler_options.join(' ')} #{include_dirs} }
            count += 1
        end
    end

    object_list = Dir.each_child("#{properties.output}/objs").select {|name| '.o' == File.extname(name).downcase }
            .map {|name| "#{properties.output}/objs/#{name}" }
    objects = object_list.join ' '
    puts "Objects: #{objects}".cyan if verbose
    if object_list.length > 0 && object_list.length == count
        puts "#{'Linking Target'.yellow}: #{properties.target.white.bold}"
        puts "#{properties.linker} -o #{properties.output}/exec/#{properties.target} #{objects} #{properties.linker_options.join(' ')}".cyan if verbose
        puts %x{ #{properties.linker} -o #{properties.output}/exec/#{properties.target} #{objects} #{properties.linker_options.join(' ')} }
    end

    puts "#{'SUCCESS'.green} - Build completed successfully" if File.exists? "#{properties.output}/exec/#{properties.target}"
    puts "#{'FAILED'.red} - See compilation output for details" unless File.exists? "#{properties.output}/exec/#{properties.target}"
end



flags = Flags.new(ARGV)

if flags.tasks_flag || flags.default_flag
    tasks
end

if !File.exists? flags.properties_file
    puts "#{'ERROR'.red}: Project JSON #{flags.properties_file.white.bold} does not exists in current directory; make sure you are in the correct project directory"
    exit -1
end

properties = BuildProperties.new(JSON.parse(File.read(flags.properties_file)))

if flags.clean_flag
    clean properties
end

if flags.build_flag
    build properties, flags.verbose_flag
end
