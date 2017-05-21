require "rainbow"

module Gtd
  class Task
    attr_reader :id, :task, :contexts, :projects
    def initialize(id,line,completed)
      @id        = id
      @line      = line
      @completed = completed
      @contexts  = line.split(/\s/).select { |word| word =~ /^@/ }
      @projects  = line.split(/\s/).select { |word| word =~ /^\+/ }

      @task = line.split(/\s/).reject { |word|
        @contexts.include?(word)
      }.reject { |word|
        @projects.include?(word)
      }.join(" ")
    end

    def projects
      @projects.map { |_| _.gsub(/^\+/,'') }
    end

    def completed?
      @completed
    end

    def complete!
      @completed = true
    end

    def serialize
      if @completed
        "x #{@line}"
      else
        @line
      end
    end

    def in_context?(context)
      return true if context.nil?
      context = "@#{context}" if context !~ /^@/
      @contexts.include?(context)
    end

    def in_project?(project)
      return true if project.nil?
      project = "+#{project}" if project.to_s !~ /^\+/
      @projects.include?(project)
    end
  end
end
