require "spec_helper"
require "gtd/task"

RSpec.describe Gtd::Task do
  describe "complete!" do
    it "sets completed_on" do
      task = Gtd::Task.new(description: "foo")
      task.complete!
      expect(task.completed_on).to be_within(60).of(Date.today)
    end
  end

  describe "#completed?" do
    it "is completed when there is a completed_on_date" do
      task = Gtd::Task.new(description: "foo", completed_on: nil)
      expect(task).not_to be_completed
    end
    it "is not completed when there is no completed_on_date" do
      task = Gtd::Task.new(description: "foo", completed_on: Date.today)
      expect(task).to be_completed
    end
  end

end
