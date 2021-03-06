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

  it "can archive a project" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    File.open(test_gtd_path / "projects" / "bar" / "tasks.txt","w") do |file|
      file.puts "This is a task"
      file.puts "This is another task"
    end

    gtd "p archive 1"

    stdout = gtd "p"
    expect(stdout).not_to have_printed("bar")
    expect(Dir.exist?(test_gtd_path / "projects" / "__archive__" / "bar")).to eq(true)
  end

  it "can move a project's next action to the main task list" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    File.open(test_gtd_path / "projects" / "bar" / "tasks.txt","w") do |file|
      file.puts "This is a task"
      file.puts "This is another task"
    end

    File.open(test_gtd_path / "projects" / "bar" / "context.txt","w") do |file|
      file.puts "work"
    end

    gtd "init"
    gtd "new -p 1"

    stdout = gtd "ls"

    expect(stdout).to have_printed("This is a task")
    expect(stdout).to have_printed("+bar")
    expect(stdout).to have_printed("@work")

    stdout = gtd "p tasks 1"
    expect(stdout).not_to have_printed("This is a task")
    expect(stdout).to have_printed("This is another task")

  end

  it "can edit the project directory" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"

    ENV["EDITOR"] = "echo"
    stdout = gtd "p vi 1"

    expect(stdout).to have_printed("#{test_gtd_path / "projects" / "bar"}")
  end

  it "can audit the main todo list for tasks from every project" do
    FileUtils.mkdir test_gtd_path / "projects"
    FileUtils.mkdir test_gtd_path / "projects" / "bar"
    File.open(test_gtd_path / "projects" / "bar" / "tasks.txt","w") do |file|
      file.puts "This is a task"
      file.puts "This is another task"
    end
    FileUtils.mkdir test_gtd_path / "projects" / "baz"
    FileUtils.mkdir test_gtd_path / "projects" / "foo"
    File.open(test_gtd_path / "projects" / "foo" / "tasks.txt","w") do |file|
      file.puts "This is a foo task"
      file.puts "This is another foo task"
    end

    gtd "init"
    gtd "new -p 3"

    stdout = gtd "p audit"

    expect(stdout).to have_printed("bar")
    expect(stdout).not_to have_printed("baz")
    expect(stdout).not_to have_printed("foo")
  end

end
