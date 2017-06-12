require "spec_helper"
require "gtd/todo_txt"
require "fileutils"
require "support/matchers/be_task"

RSpec.describe Gtd::TodoTxt do
  let(:task_names) {
    [
      "This is a task",
      "This is another task",
      "This is a completed task",
    ]
  }
  let(:completed_task) { task_names[2] }

  let(:dir) { dir = Dir.mktmpdir("todo_gtd") }
  let(:file) {
    filename = File.join(dir,"todo.txt")
    File.open(filename,"w") do |file|
      task_names.each do |task_name|
        if task_name == completed_task
          file.puts "x #{task_name}"
        else
          file.puts task_name
        end
      end
    end
    filename
  }

  after do
    FileUtils.rm_rf dir
  end

  subject(:todo_txt) { described_class.new(file) }

  describe "#file" do
    it "wraps it in a Pathname" do
      expect(todo_txt.file.class).to eq(Pathname)
      expect(todo_txt.file.to_s).to eq(file)
    end
  end
  describe "#each" do
    context "without specifying a project" do
      it "vends all tasks parsed from the file" do
        tasks = todo_txt.each.to_a
        expect(tasks.size).to eq(task_names.size)
        task_names.each_with_index do |name,i|
          expect(tasks[i]).to be_task(name)
        end
      end
      it "knows which have been completed" do
        tasks = todo_txt.each.to_a
        task_names.each_with_index do |name,i|
          if name == completed_task
            expect(tasks[i]).to be_completed
          else
            expect(tasks[i]).not_to be_completed
          end
        end
      end
      it "assigns unique ids" do
        tasks = todo_txt.each.to_a
        ids = tasks.map(&:id).compact.uniq
        expect(ids.size).to eq(tasks.size)
      end
    end
    context "specifying a project" do
      it "vends all tasks parsed from the file, each task having the given project specified" do
        todo_txt = described_class.new(file, force_project: "foobar")
        tasks = todo_txt.each.to_a
        expect(tasks.size).to eq(task_names.size)
        task_names.each_with_index do |name,i|
          expect(tasks[i]).to be_task(name)
          expect(tasks[i].projects).to include("foobar")
        end
      end
      context "when a task is already annotated with the forced project" do
        let(:task_names) {
          [
            "This is a task",
            "This is another task +foobar",
            "This is a completed task +bleorgh",
          ]
        }
        it "does not assign the project twice" do
          todo_txt = described_class.new(file, force_project: "foobar")
          tasks = todo_txt.each.to_a
          expect(tasks[1].projects).to include("foobar")
          expect(tasks[1].serialize).not_to match(/foobar.*foobar/)
          expect(tasks[2].projects).to include("bleorgh")
          expect(tasks[2].projects).to include("foobar")
        end
      end
    end
  end
  describe "#next" do
    it "returns the first task in the list" do
      expect(todo_txt.next).to be_task(task_names.first)
    end
  end
  describe "#search" do
    let(:task_names) {
      [
        "task one +foo",
        "task two +foo @bar",
        "three task three @bar +foo", # this one will be completed
        "task three two @bar",
      ]
    }
    it "returns tasks with matching context" do
      tasks = todo_txt.search(context: "bar").to_a
      expect(tasks.size).to eq(2)
      expect(tasks[0]).to be_task("task two")
      expect(tasks[1]).to be_task("task three two")
    end
    it "returns tasks with matching project" do
      tasks = todo_txt.search(project: "foo").to_a
      expect(tasks.size).to eq(2)
      expect(tasks[0]).to be_task("task one")
      expect(tasks[1]).to be_task("task two")
    end
    it "returns completed tasks" do
      tasks = todo_txt.search(completed: true).to_a
      expect(tasks.size).to eq(1)
      expect(tasks[0]).to be_task("three task three")
    end
    it "returns non-completed tasks" do
      tasks = todo_txt.search(completed: false).to_a
      expect(tasks.size).to eq(3)
      expect(tasks[0]).to be_task("task one")
      expect(tasks[1]).to be_task("task two")
      expect(tasks[2]).to be_task("task three two")
    end
    it "returns tasks whose name matches the given string" do
      tasks = todo_txt.search(match: "TWO").to_a
      expect(tasks.size).to eq(2)
      expect(tasks[0]).to be_task("task two")
      expect(tasks[1]).to be_task("task three two")
    end
    it "requires all criteria be true to get a result" do
      tasks = todo_txt.search(match: "TWO", project: "foo").to_a
      expect(tasks.size).to eq(1)
      expect(tasks[0]).to be_task("task two")
    end
  end
  describe "#projects" do
    let(:task_names) {
      [
        "This is a task +project1 +project2",
        "This is another task +project2",
        "This is a completed task +project3 +project4",
      ]
    }
    it "returns the names of all projects across all tasks" do
      expect(todo_txt.projects.sort).to eq([
        "project1",
        "project2",
        "project3",
        "project4",
      ])
    end
  end
  describe "#complete_task" do
    it "marks the task complete" do
      task = todo_txt.complete_task(2)
      expect(task).to be_completed
    end
    it "converts the id to an int" do
      task = todo_txt.complete_task("2")
      expect(task).to be_completed
    end
    it "saves itself" do
      todo_txt.complete_task(2)
      reloaded_todo_txt = described_class.new(file)
      task = reloaded_todo_txt.each.to_a.detect { |_| _.id == 2 }
      expect(task).to be_completed
    end
    it "blows up if the id is invalid" do
      expect {
        todo_txt.complete_task(99999)
      }.to raise_error(/No such task 99999/)
    end
  end
  describe "#add_task" do
    context "given a Gtd::Task" do
      context "task already on list" do
        it "does nothing" do
          todo_txt.add_task(todo_txt.each.to_a.first)
          expect(todo_txt.each.to_a.size).to eq(task_names.size)
        end
      end
      context "task not on the list" do
        it "assigns it the next id" do
          in_use_id = todo_txt.each.to_a.first.id
          new_task = Gtd::Task.new(in_use_id,"New task!!",false)
          todo_txt.add_task(new_task)
          expect(todo_txt.each.to_a[-1].id).not_to eq(in_use_id)
        end
        it "puts it last on the list" do
          in_use_id = todo_txt.each.to_a.first.id
          new_task = Gtd::Task.new(in_use_id,"New task!!",false)
          todo_txt.add_task(new_task)
          expect(todo_txt.each.to_a.size).to eq(task_names.size + 1)
          expect(todo_txt.each.to_a[-1]).to be_task(new_task)
        end
      end
    end
    context "given a string" do
      context "task already on list" do
        it "does nothing" do
          todo_txt.add_task(todo_txt.each.to_a.first.task)
          expect(todo_txt.each.to_a.size).to eq(task_names.size)
        end
      end
      context "task not on the list" do
        it "puts it last on the list" do
          todo_txt.add_task("New task!!")
          expect(todo_txt.each.to_a.size).to eq(task_names.size + 1)
          expect(todo_txt.each.to_a[-1]).to be_task("New task!!")
        end
      end
    end
  end
  describe "#save!" do
    it "updates the file with each task on one line" do
      todo_txt.add_task("NEW TASK!!!!")
      todo_txt.next.projects << "new_project"
      todo_txt.save!

      reload_todo_txt = described_class.new(file)
      tasks = reload_todo_txt.each.to_a
      expect(tasks.size).to eq(task_names.size + 1)
      expect(tasks[-1]).to be_task("NEW TASK!!!!")
      expect(todo_txt.next.projects).to include("new_project")
    end
  end
end
