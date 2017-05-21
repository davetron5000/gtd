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
    next_action = if @project.next_action.nil?
                    Rainbow("⛔️  No Next Action").red
                  else
                    Rainbow("👉  #{@project.next_action.task}").green
                  end
    io = StringIO.new
    io.puts
    io.puts Rainbow(@project.name).bright
    io.puts
    io.puts next_action
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
    io.string
  end
end
