require "date"

module Gtd
  class Task
    attr_reader :description, :completed_on, :id, :contexts, :project_codes
    def initialize(description:, id: nil, completed_on: nil, contexts: [], project_codes: [])
      @description   = description
      @id            = id
      @completed_on  = completed_on
      @contexts      = contexts
      @project_codes = project_codes
    end

    def complete!
      @completed_on = Date.today
    end

    def completed?
      !@completed_on.nil?
    end
  end
end
