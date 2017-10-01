require_relative "task"
require_relative "task_parser"

module Gtd
  class TodoTxt
    attr_reader :file, :tasks

    def initialize(file, add_project_code: nil, add_context: nil)
      @file = file
      task_parser = Gtd::TaskParser.new(add_project_code: add_project_code, add_context: add_context)
      @tasks = (File.read(@file).split(/\n/) rescue []).each_with_index.map { |task_line,index|
        task_parser.parse(task_line,index)
      }
    end

    def complete_task(task_id)
      @tasks[task_id - 1].complete!
    end

    def remove(task_to_remove)
      @tasks = tasks.reject { |task| task == task_to_remove }
    end

    def save!
      task_parser = Gtd::TaskParser.new
      File.open(@file,"w") do |file|
        @tasks.each do |task|
          file.puts task_parser.serialize(task)
        end
      end
    end
  end
end
