require "pathname"
require_relative "project"
require_relative "todo_txt"

module Gtd
  class ProjectParser
    def parse(project_dir, index)
      dir      = Pathname(project_dir)
      name     = parse_name(dir)
      code     = dir.basename.to_s
      default_context = parse_context(dir)
      todo_txt = Gtd::TodoTxt.new(dir / "tasks.txt", add_project_code: code, add_context: default_context)
      Gtd::Project.new(name: name,
                       code: code,
                       todo_txt: todo_txt,
                       default_context: default_context,
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

    def parse_context(dir)
      if File.exists?(dir / "context.txt")
        File.read(dir / "context.txt").chomp.strip
      else
        nil
      end
    end
  end
end
