require 'pathname'
require_relative "task"

module Gtd
  class TodoTxt
    include Enumerable
    def initialize(file)
      @tasks = []
      @file = Pathname(file)
      if File.exist?(@file)
        File.open(@file).readlines.each_with_index do |line,index|
          next if line =~ /^x/
          @tasks << Task.new(index+1,line)
        end
      end
    end

    def each(&block)
      @tasks.each(&block)
    end

    def next
      self.first
    end

    def search(context: nil, project: nil, &block)
      @tasks.select { |task|
        task.in_context?(context)
      }.select { |task|
        task.in_project?(project)
      }.each(&block)
    end

    def projects
      @tasks.map(&:projects).flatten.uniq.sort
    end

    def save!
      File.open(@file,"w") do |file|
        @tasks.each do |task|
          file.puts task.serialize
        end
      end
    end
  end
end
