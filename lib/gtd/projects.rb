require "pathname"
require "fileutils"

require_relative "project"

module Gtd
  class Projects
    include Enumerable
    include FileUtils


    def initialize(todo_txt, project_dir)
      @todo_txt    = todo_txt
      @project_dir = Pathname(project_dir)
      @archive_dir = @project_dir / "__archive__"

      @projects = Dir[@project_dir / "*"].map { |dir|
        Pathname(dir)
      }.reject { |dir|
        dir == @archive_dir
      }.each_with_index.map { |dir,index|
        project_code = dir.basename
        Project.new(index+1,dir,@todo_txt.search(project: project_code).to_a)
      }
    end

    def find(id)
      $projects.detect { |_| _.id == id.to_i }.tap { |project|
        exit_now!("No project with id #{id}") if project.nil?
      }
    end

    def find_by_code(project_code)
      @projects.detect { |project|
        project.code == project_code
      }
    end

    def archive(project_id)
      project = self.find(project_id)
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