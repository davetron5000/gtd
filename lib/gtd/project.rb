require "rainbow"
require "pathname"
require "fileutils"

module Gtd
  class Project
    include FileUtils

    attr_reader :name, :id, :dir, :links, :notes, :files, :global_tasks, :next_actions

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
                Pathname(@dir).basename
              end
      @notes = if File.exists?(@notes_file)
                 File.read(@notes_file)
               else
                 ""
               end
      @links = if File.exists?(@links_file)
                 File.open(@links_file).readlines.map(&:chomp)
               else
                 []
               end
      @next_actions = TodoTxt.new(@tasks_file,force_project: code)
      @files = Dir[@dir / "*"].reject { |file|
        ["name.txt","notes.txt","tasks.txt",".",".."].include?(file)
      }
    end

    def tasks
      @global_tasks + @next_actions.to_a
    end

    def code
      @dir.basename.to_s
    end

    def next_action
      if self.global_tasks[0]
        self.global_tasks[0]
      elsif self.next_actions.next
        self.next_actions.next
      else
        nil
      end
    end

    def save!
      mkdir_p @dir, verbose: true
      File.open(@name_file,"w")  { |file| file.puts(@name)  }
      File.open(@notes_file,"w") { |file| file.puts(@notes) }
      File.open(@links_file,"w") { |file| file.puts(@links.join("\n")) }
      @next_actions.save!
    end

    def add_task(task_name)
      @next_actions.add_task(task_name)
    end

  end
end
