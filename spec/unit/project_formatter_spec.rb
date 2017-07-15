require "spec_helper"
require "gtd/project_formatter"
require "gtd/project"
require "gtd/todo_txt"

RSpec.describe Gtd::ProjectFormatter do
  before do
    Rainbow.enabled = false
  end
  after do
    Rainbow.enabled = true
  end

  subject(:project_formatter) { described_class.new }
  let(:tasks) {
    [
      "This is a task",
      "This is another task",
    ]
  }
  let(:tmp_file) {
    filename = Pathname(Dir.mktmpdir) / "todo.txt"
    File.open(filename,"w") do |file|
      tasks.each do |task|
        file.puts task
      end
    end
    filename
  }
  let(:todo_txt) {
    Gtd::TodoTxt.new(tmp_file)
  }

  describe "#format" do
    it "includes the id" do
      project = Gtd::Project.new(name: "foo", id: 1, todo_txt: todo_txt, code: "foo")
      expect(project_formatter.format(project)).to match(/^\[1\] /)
    end
    it "includes the name" do
      project = Gtd::Project.new(name: "foo", id: 1, todo_txt: todo_txt, code: "foo")
      expect(project_formatter.format(project)).to match(/foo/)
    end
    it "includes the tasks" do
      project = Gtd::Project.new(name: "foo", id: 1, todo_txt: todo_txt, code: "foo")
      expect(project_formatter.format(project)).to match(/Tasks/)
      expect(project_formatter.format(project)).to match(/This is a task/)
      expect(project_formatter.format(project)).to match(/This is another task/)
    end
    context "when there are no tasks" do
      let(:tasks) { [] }
      it "excludes the tasks header when there are no tasks" do
        project = Gtd::Project.new(name: "foo", id: 1, todo_txt: todo_txt, code: "foo")
        expect(project_formatter.format(project)).not_to match(/Tasks/)
      end
      it "gives a suggestion to archive the project" do
        project = Gtd::Project.new(name: "foo", id: 1, todo_txt: todo_txt, code: "foo")
        expect(project_formatter.format(project)).to match(/no next actions/i)
        expect(project_formatter.format(project)).to match(/archive/i)
      end
    end
  end
end
