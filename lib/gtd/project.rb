require "pathname"
require_relative "todo_txt"

module Gtd
  class Project
    attr_reader :dir, :id
    def initialize(dir: , id: nil)
      @dir      = Pathname(dir)
      @id       = id
      @todo_txt = Gtd::TodoTxt.new(@dir / "tasks.txt")
    end

    def name
      @dir.basename.to_s
    end

    def todo_txt
      @todo_txt
    end
  end
end
