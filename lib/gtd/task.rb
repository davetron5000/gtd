require "rainbow"

module Gtd
  class Task
    attr_reader :id, :task, :contexts, :projects
    def initialize(id,line,completed)
      @id        = id
      @line      = line
      @completed = completed
      raw_contexts  = line.split(/\s/).select { |word| word =~ /^@/ }
      raw_projects  = line.split(/\s/).select { |word| word =~ /^\+/ }

      @task = line.split(/\s/).reject { |word|
        raw_contexts.include?(word)
      }.reject { |word|
        raw_projects.include?(word)
      }.join(" ")

      @contexts = raw_contexts.map { |_| _.gsub(/^@/,'') }.uniq
      @projects = raw_projects.map { |_| _.gsub(/^\+/,'') }.uniq
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
      context = context.gsub(/^@/,'')
      @contexts.include?(context)
    end

    def in_project?(project)
      return true if project.nil?
      project = project.to_s.gsub(/^\+/,'')
      @projects.include?(project)
    end
  end
end
