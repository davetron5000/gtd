require "stringio"

module Gtd
  module Formatters
  end
end

class Gtd::Formatters::ProjectDetails
  def initialize(project)
    @project = project
  end
  def to_s
    io = StringIO.new
    io.puts
    io.puts Rainbow(@project.name).bright
    io.puts
    if @project.next_action.nil?
      io.puts Rainbow("⛔️  No Next Action").red
    end
    if @project.links.any?
      io.puts
      io.puts Rainbow("⛓  Links").cyan.bold
      io.puts
      @project.links.each do |link|
        io.puts "* " + Rainbow("#{link}").cyan.underline
      end
    end
    if @project.notes.strip != ""
      io.puts
      io.puts Rainbow("📋  Notes").yellow.bold
      io.puts
      io.puts @project.notes
    end
    if @project.tasks.any?
      io.puts
      io.puts Rainbow("☑️  Tasks").green.bold
      io.puts
      @project.tasks.each do |task|
        if task.task == @project.next_action.task
          io.puts "👉  " + Rainbow(task.task).bright
        else
          io.puts "*  " + Rainbow(task.task).bright
        end
      end
    end
    io.string
  end
end
