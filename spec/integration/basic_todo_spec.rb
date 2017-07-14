require "spec_helper"
require "support/bin_helper"
require "support/matchers/have_tasks"
require "support/matchers/have_completed_tasks"
require "support/matchers/have_printed"

RSpec.describe "basic todo list management" do
  include BinHelper
  include_context "running the app" do
    let(:test_gtd_path) { Pathname(Dir.mktmpdir) }
  end

  before do
    @editor = ENV["EDITOR"]
  end

  after do
    ENV["EDITOR"] = @editor
  end

  it "can create a new todo list" do
    gtd "init"
    expect(test_gtd_path).to have_tasks("Capture some tasks or projects")
  end
  it "will not overwrite an existing todo list" do
    gtd "init"
    expect {
      gtd "init"
    }.to raise_error(/already exists/)
  end
  it "can add and list items in the todo list" do
    gtd "init"

    gtd "new 'This is a test task'"
    gtd "new 'This is another task'"

    expect(test_gtd_path).to have_tasks(
      'This is a test task',
      'This is another task'
    )
  end
  it "can complete items in the todo list" do
    gtd "init"

    gtd "new 'This is a test task'"
    gtd "new 'This is another task'"
    gtd "complete 2"

    expect(test_gtd_path).to have_completed_tasks(
      'This is a test task'
    )
  end
  it "can list outstanding tasks" do
    gtd "init"
    gtd "new 'This is a test task'"
    gtd "new 'This is another task'"
    gtd "complete 2"

    stdout = gtd "ls"

    expect(stdout).to have_printed("Capture some tasks or projects")
    expect(stdout).to have_printed("This is another task")
    expect(stdout).not_to have_printed("This is a test task")
  end
  it "can list completed tasks" do
    gtd "init"
    gtd "new 'This is a test task'"
    gtd "new 'This is another task'"
    gtd "complete 2"

    stdout = gtd "ls --completed"

    expect(stdout).not_to have_printed("Capture some tasks or projects")
    expect(stdout).not_to have_printed("This is another task")
    expect(stdout).to have_printed("This is a test task")
  end

  it "can open up the todo list in your editor" do
    ENV["EDITOR"] = "echo"
    gtd "init"
    stdout = gtd "vi"

    expect(stdout).to have_printed("#{test_gtd_path}/todo.txt")

  end
end
