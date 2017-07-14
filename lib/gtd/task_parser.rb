require_relative "task"

module Gtd
  class TaskParser
    def parse(line,line_number)
      id = line_number + 1
      raw_description, completed_on = if line =~ /^x\s(\d\d\d\d-\d\d-\d\d)\s+(.*$)/
                                        [$2, Date.parse($1)]
                                      else
                                        [line,nil]
                                      end
      contexts,description = parse_contexts(raw_description)
      Task.new(description: description, contexts: contexts, completed_on: completed_on, id: id)
    end

  private

    def parse_contexts(raw_description)
      context =        -> (word)    { word =~ /^@/ }
      remove_at_sign = -> (context) { context.gsub(/^@/,"") }

      words = raw_description.split(/\s+/)

      [
        words.select(&context).map(&remove_at_sign),
        words.reject(&context).join(" "),
      ]
    end
  end

end
