require "spec_helper"
require "support/bin_helper"
require "support/matchers/have_tasks"
require "support/matchers/have_completed_tasks"
require "support/matchers/have_printed"

RSpec.describe "project management" do
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

  it "can list projects" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "foo"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"

    stdout = gtd "p"
    expect(stdout).to have_printed("foo")
    expect(stdout).to have_printed("bar")
  end
  it "can omits the archive" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    FileUtils.mkdir test_gtd_path / "projects" / "__archive__"

    stdout = gtd "p"
    expect(stdout).not_to have_printed("__archive__")
  end
  it "can list a project's tasks" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    File.open(test_gtd_path / "projects" / "bar" / "tasks.txt","w") do |file|
      file.puts "This is a task"
      file.puts "This is another task"
    end

    stdout = gtd "p tasks 1"
    expect(stdout).to have_printed("This is a task")
    expect(stdout).to have_printed("This is another task")
  end
  it "can move a project's next action to the main task list" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    File.open(test_gtd_path / "projects" / "bar" / "tasks.txt","w") do |file|
      file.puts "This is a task"
      file.puts "This is another task"
    end

    gtd "init"
    gtd "new -p 1"

    stdout = gtd "ls"

    expect(stdout).to have_printed("This is a task")

    stdout = gtd "p tasks 1"
    expect(stdout).not_to have_printed("This is a task")
    expect(stdout).to have_printed("This is another task")

  end
end
