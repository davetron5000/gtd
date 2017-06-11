require "spec_helper"
require "gtd/task"

RSpec.describe Gtd::Task do
  describe "#projects" do
    it "parses projects by checking for values preceded by a plus sign" do
      task = described_class.new(1,"This is a task +project +other_project",false)
      expect(task.projects.sort).to eq(["other_project","project"])
    end
    it "can handle words with plusses in them" do
      task = described_class.new(1,"This is a ta+sk +project +other_project",false)
      expect(task.projects.sort).to eq(["other_project","project"])
    end
    it "de-dupes projects" do
      task = described_class.new(1,"This is a ta+sk +project +project",false)
      expect(task.projects.sort).to eq(["project"])
    end
  end
  describe "#complete!" do
    it "completes an un-completed task" do
      task = described_class.new(1,"This is a task",false)
      task.complete!
      expect(task.completed?).to eq(true)
    end
  end

  describe "#serialize" do
    it "returns the line originally parsed for non-completed tasks" do
      task = described_class.new(1,"This is a task +with_projects @and_contexts",false)
      expect(task.serialize).to eq("This is a task +with_projects @and_contexts")
    end
    it "returns the line originally parsed, preceded with an x for completed tasks" do
      task = described_class.new(1,"This is a task +with_projects @and_contexts",true)
      expect(task.serialize).to eq("x This is a task +with_projects @and_contexts")
    end
  end

  describe "#in_context?" do
    it "returns true if the task has the context @'ed in its description" do
      task = described_class.new(1,"This is a task @work @mobile",false)
      expect(task.in_context?("work")).to eq(true)
    end
    it "ignores a preceding at sign" do
      task = described_class.new(1,"This is a task @work @mobile",false)
      expect(task.in_context?("@work")).to eq(true)
    end
    it "returns false if the task does not have the context @'ed in its description" do
      task = described_class.new(1,"This is a task @work @mobile",false)
      expect(task.in_context?("home")).to eq(false)
    end
    it "returns true for a nil context" do
      task = described_class.new(1,"This is a task @work @mobile",false)
      expect(task.in_context?(nil)).to eq(true)
    end
  end

  describe "#in_project?" do
    it "returns true if the task has the project +'ed in its description" do
      task = described_class.new(1,"This is a task +project",false)
      expect(task.in_project?("project")).to eq(true)
    end
    it "ignores a preceding plus sign" do
      task = described_class.new(1,"This is a task +project",false)
      expect(task.in_project?("+project")).to eq(true)
    end
    it "returns false if the task does not have the project +'ed in its description" do
      task = described_class.new(1,"This is a task +project",false)
      expect(task.in_project?("other_project")).to eq(false)
    end
    it "returns true for a nil project" do
      task = described_class.new(1,"This is a task +project",false)
      expect(task.in_project?(nil)).to eq(true)
    end
  end

  describe "#task" do
    it "returns the content of the task without any projects or contexts" do
      task = described_class.new(1,"This is a task +project that requires @work stuff",false)
      expect(task.task).to eq("This is a task that requires stuff")
    end
  end

  describe "#contexts" do
    it "returns the names of all contexts" do
      task = described_class.new(1,"This is a task @work @mobile",false)
      expect(task.contexts.sort).to eq(["mobile","work"])
    end
  end
end
