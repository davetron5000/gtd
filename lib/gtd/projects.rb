require "pathname"
require "fileutils"

require_relative "project"

module Gtd
  class Projects
    include Enumerable
    include FileUtils


    def initialize(project_dir)
      @project_dir = Pathname(project_dir)
      @archive_dir = @project_dir / "__archive__"

      @projects = Dir[@project_dir / "*"].map { |dir|
        Pathname(dir)
      }.reject { |dir|
        dir == @archive_dir
      }.each_with_index.map { |dir,index|
        Project.new(index+1,dir)
      }
    end

    def archive(project)
      mkdir_p @archive_dir, verbose: true
      mv project.dir,@archive_dir, verbose: true
    end

    def new(name)
      next_id = (@projects.map(&:id).max || 0) + 1
      dir = @project_dir / name.gsub(/\W/,"-").downcase
      project = Project.new(next_id,dir, name: name)
      project.save!
      @projects << project
    end

    def each(&block)
      @projects.each(&block)
    end
  end
end
