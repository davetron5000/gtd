require "pathname"
require_relative "todo_txt"

module Gtd
  class Project
    attr_reader :name, :id, :todo_txt, :code, :default_context
    def initialize(name: , todo_txt:, id: nil, code: ,default_context: nil)
      @name            = name
      @id              = id
      @todo_txt        = todo_txt
      @code            = code
      @default_context = default_context
    end
  end
end
