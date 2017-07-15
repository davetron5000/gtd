require_relative "task"

module Gtd
  class TaskParser
    def initialize(add_project_code: nil)
      @add_project_code = add_project_code
    end

    def parse(line,line_number)
      id = line_number + 1
      description, completed_on = if line =~ /^x\s(\d\d\d\d-\d\d-\d\d)\s+(.*$)/
                                    [$2, Date.parse($1)]
                                  else
                                    [line,nil]
                                  end

      contexts      , description = parse_tagged_code(description,/^@/)
      project_codes , description = parse_tagged_code(description,/^\+/)

      project_codes << @add_project_code unless @add_project_code.nil?

      Task.new(description: description, project_codes: project_codes.uniq, contexts: contexts, completed_on: completed_on, id: id)
    end

    def serialize(task)
      contexts      = task.contexts.map      { |context| "@" + context.to_s }.join(" ")
      project_codes = task.project_codes.map { |project_code| "+" + project_code.to_s }.join(" ")

      serialized = ("#{task.description} " + contexts + " " + project_codes).strip
      if task.completed?
        "x #{task.completed_on.to_s} #{serialized}"
      else
        serialized
      end
    end

  private

    def parse_tagged_code(description,tag_regexp)
      with_tag         = -> (word)        { tag_regexp.match(word) }
      remove_tag_sigil = -> (tagged_word) { tagged_word.gsub(tag_regexp,"") }

      words = description.split(/\s+/)

      [
        words.select(&with_tag).map(&remove_tag_sigil),
        words.reject(&with_tag).join(" "),
      ]
    end
  end

end
