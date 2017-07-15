require "pathname"
require_relative "todo_txt"

module Gtd
  class Project
    attr_reader :name, :id, :todo_txt, :code
    def initialize(name: , todo_txt:, id: nil, code: )
      @name     = name
      @id       = id
      @todo_txt = todo_txt
      @code     = code
    end
  end
end
