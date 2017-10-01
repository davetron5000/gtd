require "spec_helper"
require "pathname"
require "fileutils"
require "gtd/project_parser"

RSpec.describe Gtd::ProjectParser do
  subject(:project_parser) { described_class.new }
  describe "#parse" do
    let(:project_dir) { Pathname(Dir.mktmpdir) / "foo" }
    let(:tasks) {
      [
        "This is a task",
        "This is another task",
      ]
    }

    before do
      FileUtils.mkdir_p project_dir
      File.open(project_dir / "tasks.txt","w") do |file|
        tasks.each do |task|
          file.puts task
        end
      end
    end

    it "sets the id one greater than the index" do
      project = project_parser.parse(project_dir,2)
      expect(project.id).to eq(3)
    end

    it "sets the name to the dir's basename" do
      project = project_parser.parse(project_dir,2)
      expect(project.name).to eq("foo")
    end

    it "sets the name to the value of name.txt if it's there" do
      File.open(project_dir / "name.txt","w") do |file|
        file.puts "The Best Project"
      end
      project = project_parser.parse(project_dir,2)
      expect(project.name).to eq("The Best Project")
    end

    it "parses the task list from tasks.txt" do
      project = project_parser.parse(project_dir,2)
      expect(project.todo_txt.tasks.size).to eq(2)
      expect(project.todo_txt.tasks.map(&:description)).to include("This is a task")
      expect(project.todo_txt.tasks.map(&:description)).to include("This is another task")
    end

    it "parses the task list from tasks.txt given each the default context" do
      File.open(project_dir / "context.txt","w") do |file|
        file.puts "foo"
      end
      project = project_parser.parse(project_dir,2)
      expect(project.todo_txt.tasks.size).to eq(2)
      expect(project.todo_txt.tasks[0].contexts).to include("foo")
      expect(project.todo_txt.tasks[1].contexts).to include("foo")
    end
  end
end
