require "rainbow"
require "pathname"
require "fileutils"
require_relative "todo_txt"

module Gtd
  class Project
    include FileUtils

    attr_reader :id, :dir, :links, :notes, :global_tasks
    attr_accessor :name

    def initialize(id,dir,global_tasks, name: nil)
      @id           = id
      @dir          = Pathname(dir)
      @global_tasks = global_tasks

      @name_file  = @dir / "name.txt"
      @notes_file = @dir / "notes.txt"
      @tasks_file = @dir / "tasks.txt"
      @links_file = @dir / "links.txt"

      @name = if name
                name
              elsif File.exists?(@name_file)
                File.read(@name_file).chomp
              else
                Pathname(@dir).basename.to_s
              end
      @notes = if File.exists?(@notes_file)
                 File.open(@notes_file).readlines.map(&:chomp).join("\n")
               else
                 ""
               end
      @links = if File.exists?(@links_file)
                 File.open(@links_file).readlines.map(&:chomp).reject {|link| link.to_s.strip == "" }
               else
                 []
               end
      @next_actions = TodoTxt.new(@tasks_file,force_project: code)
    end

    def tasks
      @global_tasks + @next_actions.to_a
    end

    def code
      @dir.basename.to_s
    end

    def remove_task(task)
      @next_actions.remove_task(task)
      @global_tasks = @global_tasks.reject { |global_task|
        task.task == global_task.task
      }
    end

    def add_note(note)
      if @notes.strip == ""
        @notes = note
      else
        @notes << "\n\n"
        @notes << note
      end
    end

    def next_action
      if self.global_tasks[0]
        self.global_tasks[0]
      elsif @next_actions.next
        @next_actions.next
      else
        nil
      end
    end

    def save!
      mkdir_p @dir, verbose: true
      File.open(@name_file,"w")  { |file| file.puts(@name)  }
      File.open(@notes_file,"w") { |file| file.puts(@notes) }
      File.open(@links_file,"w") { |file| file.puts(@links.join("\n")) } if @links.size > 0
      @next_actions.save!
    end

    def add_task(task_name)
      @next_actions.add_task(task_name)
    end

  end
end
