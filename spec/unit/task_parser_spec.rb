require "spec_helper"
require "gtd/task_parser"

RSpec.describe Gtd::TaskParser do
  subject(:task_parser) { described_class.new }
  describe "#parse" do
    it "sets the id to one greater than the line number" do
      task = task_parser.parse("x 2015-01-01 This was a task",1)
      expect(task.id).to eq(2)
    end
    it "parses the description" do
      task = task_parser.parse("x 2015-01-01 This was a task",1)
      expect(task.description).to eq("This was a task")
    end
    it "parses the completed date for completed tasks" do
      task = task_parser.parse("x 2015-01-01 This was a task",1)
      expect(task.completed_on.to_s).to eq("2015-01-01")
    end
    it "parses uncompleted tasks as not completed" do
      task = task_parser.parse("This was a task",1)
      expect(task.completed_on).to be_nil
    end
    it "parses contexts" do
      task = task_parser.parse("This was a @work task @remote",1)
      expect(task.description).to eq("This was a task")
      expect(task.contexts.map(&:to_s).sort).to eq(["remote","work"])
    end
  end
end
