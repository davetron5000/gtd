require "spec_helper"
require "gtd/task_formatter"
require "gtd/task"

RSpec.describe Gtd::TaskFormatter do
  before do
    Rainbow.enabled = false
  end
  after do
    Rainbow.enabled = true
  end

  subject(:task_formatter) { described_class.new }

  describe "#format" do
    it "includes the id" do
      task = Gtd::Task.new(description: "this is a task", completed_on: Date.parse("2015-02-03"), id: 4)
      expect(task_formatter.format(task)).to match(/^\[4\] /)
    end
    it "includes the description" do
      task = Gtd::Task.new(description: "this is a task", completed_on: Date.parse("2015-02-03"), id: 4)
      expect(task_formatter.format(task)).to match(/this is a task/)
    end
    it "includes the contexts" do
      task = Gtd::Task.new(description: "this is a task", completed_on: Date.parse("2015-02-03"), id: 4, contexts: [ "foo", "bar" ])
      expect(task_formatter.format(task)).to match(/@bar @foo/)
    end
    it "includes the project codes" do
      task = Gtd::Task.new(description: "this is a task", completed_on: Date.parse("2015-02-03"), id: 4, project_codes: [ "foo", "bar" ])
      expect(task_formatter.format(task)).to match(/\+bar \+foo/)
    end
    it "includes the completion date for completed tasks" do
      task = Gtd::Task.new(description: "this is a task", completed_on: Date.parse("2015-02-03"), id: 4)
      expect(task_formatter.format(task)).to match(/completed: 2015-02-03/)
    end
  end
end
