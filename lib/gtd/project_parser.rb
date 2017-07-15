require "pathname"
require_relative "project"
require_relative "todo_txt"

module Gtd
  class ProjectParser
    def parse(project_dir, index)
      dir      = Pathname(project_dir)
      name     = parse_name(dir)
      code     = dir.basename.to_s
      todo_txt = Gtd::TodoTxt.new(dir / "tasks.txt", add_project_code: code)
      Gtd::Project.new(name: name,
                       code: code,
                       todo_txt: todo_txt,
                       id: index + 1)
    end

  private

    def parse_name(dir)
      if File.exists?(dir / "name.txt")
        File.read(dir / "name.txt").chomp.strip
      else
        dir.basename.to_s
      end
    end
  end
end
