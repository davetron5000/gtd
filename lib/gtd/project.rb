require "rainbow"
require "pathname"
require "fileutils"

module Gtd
  class Project
    include FileUtils

    attr_reader :name, :id, :dir

    def initialize(id,dir,global_tasks, name: nil)
      @id           = id
      @dir          = Pathname(dir)
      @global_tasks = global_tasks

      @name_file  = @dir / "name.txt"
      @notes_file = @dir / "notes.txt"
      @tasks_file = @dir / "tasks.txt"

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
      @next_actions = TodoTxt.new(@tasks_file)
      @files = Dir[@dir / "*"].reject { |file|
        ["name.txt","notes.txt","tasks.txt",".",".."].include?(file)
      }
    end

    def to_s
      next_action = if @global_tasks[0]
                      Rainbow("➡️  #{@global_tasks[0].task}").green
                    elsif @next_actions.next
                      Rainbow("➡️  #{@next_actions.next.task}").green
                    else
                      Rainbow("⛔️  No Next Action").red
                    end
      formatted_id = if @id < 10
                       " #{@id}"
                     else
                       @id.to_s
                     end
      Rainbow("[#{formatted_id}]: ").faint + @name + "\n      " + next_action
    end

    def save!
      mkdir_p @dir, verbose: true
      File.open(@name_file,"w")  { |file| file.puts(@name)  }
      File.open(@notes_file,"w") { |file| file.puts(@notes) }
      @next_actions.save!
    end

  end
end
