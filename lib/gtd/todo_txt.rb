require 'pathname'
require_relative "task"

module Gtd
  class TodoTxt
    include Enumerable
    attr_reader :file
    def initialize(file,force_project: nil)
      @tasks = []
      @file = Pathname(file)
      if File.exist?(@file)
        File.open(@file).readlines.each_with_index do |line,index|
          completed,description = if line =~ /^x\s+/
                                    [true,description = line.chomp.gsub(/^x\s+/,"")]
                                  else
                                    [false,line.chomp]
                                  end
          description = description + " +#{force_project}" if force_project
          @tasks << Task.new(index+1,description,completed)
        end
      end
    end

    def each(&block)
      @tasks.each(&block)
    end

    def next
      self.first
    end

    def search(context: nil, project: nil, completed: false, &block)
      @tasks.select { |task|
        task.in_context?(context)
      }.select { |task|
        task.in_project?(project)
      }.select { |task|
        if completed
          task.completed?
        else
          !task.completed?
        end
      }.each(&block)
    end

    def projects
      @tasks.map(&:projects).flatten.uniq.sort
    end

    def complete_task(task_id)
      task = detect { |task|
        task.id == task_id.to_i
      }
      if task.nil?
        raise "No such task #{task_id}"
      end
      task.complete!
      save!
      task
    end

    def add_task(task_or_task_name)
      next_id = @tasks.map(&:id).max || 1
      if task_or_task_name.kind_of?(Task)
        if @tasks.map(&:task).include?(task_or_task_name.task)
          # no-op, task already there
        else
          @tasks << Task.new(next_id,task_or_task_name.serialize,false)
        end
      else
        @tasks << Task.new(next_id,task_name,false)
      end
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
