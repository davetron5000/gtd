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
          task = Task.new(index+1,description,completed)
          if force_project && !task.projects.include?(force_project)
            task.projects << force_project
          end
          @tasks << task
        end
      end
    end

    def each(&block)
      @tasks.each(&block)
    end

    def next
      self.first
    end

    def search(context: nil, project: nil, completed: false, match: nil, &block)
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
      }.select { |task|
        if match.nil?
          true
        else
          !!Regexp.new(match,true).match(task.task)
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
      task_description = if task_or_task_name.kind_of?(Task)
                           task_or_task_name.serialize
                         else
                           task_or_task_name
                         end
      new_task = Task.new(next_id,task_description,false)
      if @tasks.map(&:task).include?(new_task.task)
        # no-op, task already there
      else
        @tasks << new_task
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
