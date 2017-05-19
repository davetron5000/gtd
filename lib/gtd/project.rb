require "rainbow"
require "pathname"
require "fileutils"

module Gtd
  class Project
    include FileUtils

    attr_reader :name, :id, :dir

    def initialize(id,dir, name: nil)
      @id = id
      @dir = Pathname(dir)
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
      @tasks = TodoTxt.new(@tasks_file)
      @files = Dir[@dir / "*"].reject { |file|
        ["name.txt","notes.txt","tasks.txt",".",".."].include?(file)
      }
    end

    def save!
      mkdir_p @dir, verbose: true
      File.open(@name_file,"w")  { |file| file.puts(@name)  }
      File.open(@notes_file,"w") { |file| file.puts(@notes) }
      @tasks.save!
    end

  end
end
