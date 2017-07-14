RSpec::Matchers.define :have_tasks do |*expected|
  match do |path_to_todo_txt|
    tasks = File.read(path_to_todo_txt / "todo.txt").split(/\n/).map(&:strip)
    expected.all? { |task|
      (tasks.detect { |_| _ =~ /#{Regexp.escape(task)}/ } != nil)
    }
  end

  failure_message do |path_to_todo_txt|
    "Expected to find:\n#{expected.join('\n')}\n\ntask list was:\n#{File.read(path_to_todo_txt / "todo.txt")}"
  end
end
