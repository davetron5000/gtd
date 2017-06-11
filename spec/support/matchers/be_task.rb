RSpec::Matchers.define :be_task do |expected|
  match do |actual|
    actual.task == task_to_string(expected)
  end

  failure_message do |actual|
    "Expected a task named '#{task_to_string(expected)}', but got '#{actual.task}'"
  end

  failure_message_when_negated do |actual|
    "Did not expect a task name '#{actual.task}'"
  end

  def task_to_string(task_or_string)
    if task_or_string.kind_of?(Gtd::Task)
      task_or_string.task
    else
      task_or_string
    end
  end
end
