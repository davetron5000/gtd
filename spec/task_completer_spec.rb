require "spec_helper"
require "gtd/task_completer"
require "gtd/todo_txt"
require "gtd/projects"

RSpec.describe Gtd::TaskCompleter do
  let(:todo_list) { instance_double(Gtd::TodoTxt) }
  let(:projects)  { instance_double(Gtd::Projects) }
  let(:task)      { Gtd::Task.new(1,"This is a task",false) }
  let(:project)   { nil }

  subject(:task_completer) { described_class.new(todo_list,projects) }

  before do
    allow(todo_list).to receive(:complete_task).and_return(task)
    allow(todo_list).to receive(:add_task)
    allow(todo_list).to receive(:save!)
    allow(projects).to receive(:find_by_code).and_return(project)
  end

  describe "#complete_task" do
    it "marks the task as complete" do
      task_completer.complete_task(task.id)
      expect(todo_list).to have_received(:complete_task).with(task.id)
    end
    context "when the task is part of a project" do
      let(:task) { Gtd::Task.new(1,"This is a task +some_project",false) }
      context "When the task's project doesn't exist" do
        it "returns a string explaining that the project doesn't exist" do
          result = task_completer.complete_task(task.id)
          expect(result.to_s).to match(/some_project/)
          expect(result.to_s).to match(/isn't a tracked project/)
        end
      end
      context "When the task's project exists" do
        let(:project) { instance_double(Gtd::Project) }
        let(:next_action) { nil }
        before do
          allow(project).to receive(:remove_task)
          allow(project).to receive(:next_action).and_return(next_action)
        end

        context "the project has a next action" do
          let(:next_action) { Gtd::Task.new(1,"Some new task",false) }
          it "moves the next action to the main todo list" do
            task_completer.complete_task(task.id)
            expect(todo_list).to have_received(:add_task).with(next_action)
            expect(todo_list).to have_received(:save!)
          end
          it "returns a string indicate what the next action is" do
            result = task_completer.complete_task(task.id)
            expect(result.to_s).to match(/Some new task/)
          end
        end
        context "the project has no next action" do
          let(:next_action) { nil }
          it "returns a string indicating there is no natural next action" do
            result = task_completer.complete_task(task.id)
            expect(result.to_s).to match(/some_project/)
            expect(result.to_s).to match(/no next action/)
          end
        end
      end
    end
    context "when the task is not part of a project" do
      it "returns a blank string result" do
        result = task_completer.complete_task(task.id)
        expect(result.to_s).to eq("")
      end
    end
  end

end
