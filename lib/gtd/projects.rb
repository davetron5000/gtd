require "pathname"
require_relative "project"

module Gtd
  class Projects
    def initialize(root)
      @root = Pathname(root)
      @projects = Dir[@root / "*"].select { |dir|
        File.directory?(dir)
      }.reject { |dir|
        [".","..","__archive__"].include?(Pathname(dir).basename.to_s)
      }.each_with_index.map { |dir,index|
        Gtd::Project.new(dir: dir, id: index + 1)
      }
    end

    def each(&block)
      @projects.each do |project|
        block.(project)
      end
    end

    def find(id)
      @projects.detect { |project| project.id == id }
    end

    def project_dirs
      @projects.map(&:dir)
    end

  end
end
