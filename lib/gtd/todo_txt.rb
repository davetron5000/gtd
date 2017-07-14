require_relative "task"
require_relative "task_parser"

module Gtd
  class TodoTxt
    attr_reader :file, :tasks

    def initialize(file)
      @file = file
      @tasks = (File.read(@file).split(/\n/) rescue []).each_with_index.map { |task_line,index|
        task_parser.parse(task_line,index)
      }
    end

    def task_parser
      @task_parser ||= Gtd::TaskParser.new
    end

    def complete_task(task_id)
      @tasks[task_id - 1].complete!
    end

    def remove(task_to_remove)
      @tasks = tasks.reject { |task| task == task_to_remove }
    end

    def save!
      File.open(@file,"w") do |file|
        @tasks.each do |task|
          if task.completed_on.nil?
            file.puts task.description
          else
            file.puts "x #{task.completed_on.to_s} #{task.description}"
          end
        end
      end
    end
  end
end
