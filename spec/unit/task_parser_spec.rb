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
    it "parses projects" do
      task = task_parser.parse("This was a @work task @remote +proj1 +a_proj",1)
      expect(task.description).to eq("This was a task")
      expect(task.project_codes.map(&:to_s).sort).to eq(["a_proj","proj1"])
    end
  end
  describe "#serialize" do
    it "serialized uncompleted tasks with their description" do
      task = Gtd::Task.new(description: "This is a task")
      expect(task_parser.serialize(task)).to eq("This is a task")
    end
    it "serializes completed tasks with an x, the date, and then the regular serialization format" do
      task = Gtd::Task.new(description: "This is a task", completed_on: Date.parse("2013-01-04"))
      expect(task_parser.serialize(task)).to eq("x 2013-01-04 This is a task")
    end
  end
end
