require "rainbow"
module Gtd
  class Task
    attr_reader :task
    def initialize(id,line)
      @id       = id
      @line     = line
      @contexts = line.split(/\s/).select { |word| word =~ /^@/ }
      @projects = line.split(/\s/).select { |word| word =~ /^\+/ }

      @task = line.split(/\s/).reject { |word|
        @contexts.include?(word)
      }.reject { |word|
        @projects.include?(word)
      }.join(" ")
    end

    def projects
      @projects.map { |_| _.gsub(/^\+/,'') }
    end

    def to_s
      Rainbow("[#{@id}]: ").faint + @task + " " + Rainbow(@contexts.join(" ")).yellow + " " + Rainbow(@projects.join(" ")).cyan
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
