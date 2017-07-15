require "pathname"
require_relative "project_parser"

module Gtd
  class Projects
    def initialize(root)
      @root = Pathname(root)
      @projects = Dir[@root / "*"].sort.select { |dir|
        File.directory?(dir)
      }.reject { |dir|
        [".","..","__archive__"].include?(Pathname(dir).basename.to_s)
      }.each_with_index.map { |dir,index|
        project_parser.parse(dir,index)
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

    def archive(id)
      project = find(id)
      project_dir = @root / project.code

      FileUtils.mkdir_p @root / "__archive__"
      FileUtils.mv project_dir, @root / "__archive__"
    end

    def dir_for(id)
      project = find(id)
      @root / project.code
    end

  private

    def project_parser
      @project_parser ||= Gtd::ProjectParser.new
    end
  end
end
