require "date"

module Gtd
  class Task
    attr_reader :description, :completed_on, :id, :contexts
    def initialize(description:, id: nil, completed_on: nil, contexts: [])
      @description  = description
      @id           = id
      @completed_on = completed_on
      @contexts     = contexts
    end

    def complete!
      @completed_on = Date.today
    end

    def completed?
      !@completed_on.nil?
    end
  end
end
