require "spec_helper"
require "gtd/project"
require "fileutils"
require "support/matchers/be_task"

RSpec.describe Gtd::Project do
  let(:project_name) { "some-project" }
  let(:id)  { 1 }
  let(:dir) {
    dir = Dir.mktmpdir("projects")
    File.join(dir,project_name).tap { |dir_name|
      FileUtils.mkdir dir_name
    }
  }

  after do
    FileUtils.rm_rf dir
  end

  let(:global_tasks) { [] }

  subject(:project) {
    described_class.new(id,dir,global_tasks)
  }

  describe "#name" do
    it "uses the name given to the constructor" do
      project = described_class.new(id,dir,global_tasks, name: "foo")
      expect(project.name).to eq("foo")
    end
    it "uses the basename of the dir when there is no name.txt file" do
      expect(project.name).to eq(project_name)
    end
    it "uses the first line of the name.txt file" do
      File.open(File.join(dir,"name.txt"),"w") do |file|
        file.puts "Project Awesome"
      end
      described_class.new(id,dir,global_tasks)
      expect(project.name).to eq("Project Awesome")
    end
  end
  describe "#dir" do
    it "wraps it in a Pathname" do
      expect(project.dir).to eq(Pathname(dir))
    end
  end
  describe "#links" do
    it "is empty when there is no links.txt file" do
      expect(project.links).to eq([])
    end
    it "is the list of lines from the links.txt file" do
      links = [
        "http://foo.com",
        "http://bar.com",
        "http://blah.com",
      ]
      File.open(File.join(dir,"links.txt"),"w") do |file|
        links.each do |link|
          file.puts link
        end
      end
      described_class.new(id,dir,global_tasks)
      expect(project.links).to eq(links)

    end
  end
  describe "#notes" do
    it "are empty if there is no notes.txt file" do
      expect(project.notes).to eq("")
    end
    it "is the context of a notes.txt file" do
      notes = %{
        These are some notes.

        I hope they make sense.
      }
      File.open(File.join(dir,"notes.txt"),"w") do |file|
        file.puts notes
      end
      project = described_class.new(id,dir,global_tasks)
      expect(project.notes).to eq(notes)
    end
  end
  describe "#code" do
    it "is the baseaname of the directory" do
      expect(project.code).to eq(project_name)
    end
  end
  describe "#tasks" do
    it "is the list of tasks from the main task list first, followed by any from the internal task list" do
      global_tasks = [
        Gtd::Task.new(1,"Do this",false),
        Gtd::Task.new(2,"Then do that",false),
      ]
      File.open(File.join(dir,"tasks.txt"),"w") do |file|
        file.puts "Also don't forget this"
        file.puts "Finally, do this"
      end
      project = described_class.new(id,dir,global_tasks)
      expect(project.tasks[0]).to be_task(global_tasks[0])
      expect(project.tasks[1]).to be_task(global_tasks[1])
      expect(project.tasks[2]).to be_task("Also don't forget this")
      expect(project.tasks[3]).to be_task("Finally, do this")
    end
  end
  describe "#remove_task" do
    it "removes the task from the internal task list" do
      global_tasks = [
        Gtd::Task.new(1,"Do this",false),
        Gtd::Task.new(2,"Then do that",false),
      ]
      File.open(File.join(dir,"tasks.txt"),"w") do |file|
        file.puts "Also don't forget this"
        file.puts "Finally, do this"
      end
      project = described_class.new(id,dir,global_tasks)
      project.remove_task(Gtd::Task.new(1,"Finally, do this",false))
      expect(project.tasks.size).to eq(3)
      expect(project.tasks[0]).not_to be_task("Finally, do this")
      expect(project.tasks[1]).not_to be_task("Finally, do this")
      expect(project.tasks[2]).not_to be_task("Finally, do this")
    end
    it "removes the task from the global task list" do
      global_tasks = [
        Gtd::Task.new(1,"Do this",false),
        Gtd::Task.new(2,"Then do that",false),
      ]
      File.open(File.join(dir,"tasks.txt"),"w") do |file|
        file.puts "Also don't forget this"
        file.puts "Finally, do this"
      end
      project = described_class.new(id,dir,global_tasks)
      project.remove_task(Gtd::Task.new(1,"Do this",false))
      expect(project.tasks.size).to eq(3)
      expect(project.tasks[0]).not_to be_task("Do this")
      expect(project.tasks[1]).not_to be_task("Do this")
      expect(project.tasks[2]).not_to be_task("Do this")
    end
  end
  describe "#add_task" do
    it "creates a task and adds it to the end of the next_actions list" do
      global_tasks = [
        Gtd::Task.new(1,"Do this",false),
        Gtd::Task.new(2,"Then do that",false),
      ]
      File.open(File.join(dir,"tasks.txt"),"w") do |file|
        file.puts "Also don't forget this"
        file.puts "Finally, do this"
      end
      project = described_class.new(id,dir,global_tasks)
      project.add_task("One more thing")
      expect(project.tasks[4]).to be_task("One more thing")
    end
  end
  describe "#next_action" do
    context "when there are tasks in the main todo.txt" do
      it "is the first task in the todo.txt list" do
        global_tasks = [
          Gtd::Task.new(1,"Do this",false),
          Gtd::Task.new(2,"Then do that",false),
        ]
        File.open(File.join(dir,"tasks.txt"),"w") do |file|
          file.puts "Also don't forget this"
          file.puts "Finally, do this"
        end
        project = described_class.new(id,dir,global_tasks)
        expect(project.next_action).to be_task(global_tasks[0])
      end
    end
    context "when there are no tasks in the main todo.txt" do
      context "when there are internal tasks" do
        it "is the first task in the internal task list" do
          global_tasks = []
          File.open(File.join(dir,"tasks.txt"),"w") do |file|
            file.puts "Also don't forget this"
            file.puts "Finally, do this"
          end
          project = described_class.new(id,dir,global_tasks)
          expect(project.next_action).to be_task("Also don't forget this")
        end
      end
      context "when there are no internal tasks" do
        it "is nil" do
          expect(project.next_action).to be_nil
        end
      end
    end
  end
  describe "#add_note" do
    context "when there are no notes" do
      it "sets the notes to be the new note" do
        project.add_note("This is a new note")
        expect(project.notes).to eq("This is a new note")
      end
    end
    context "when there are existing notes" do
      it "appends the note after a couple of newlines" do
        notes = %{
          These are some notes.

          I hope they make sense.
        }
        File.open(File.join(dir,"notes.txt"),"w") do |file|
          file.puts notes
        end
        project = described_class.new(id,dir,global_tasks)
        project.add_note("This is a new note")

        expect(project.notes).to eq(notes + "\n\nThis is a new note")
      end
    end
  end
  describe "#save!" do
    it "writes everything out to disk" do
      project.links << "http://foo.bar"
      project.links << "http://blah.com"
      project.add_note("These are some amazing notes")
      project.name = "New name!"
      project.add_task("This is a new task")
      project.add_task("This is another new task")
      project.save!

      reloaded_project = described_class.new(id,dir,global_tasks)
      expect(reloaded_project.links).to eq([
        "http://foo.bar",
        "http://blah.com",
      ])
      expect(project.name).to eq("New name!")
      expect(project.notes).to eq("These are some amazing notes")
      expect(project.tasks[0]).to be_task("This is a new task")
      expect(project.tasks[1]).to be_task("This is another new task")
    end
  end
end
