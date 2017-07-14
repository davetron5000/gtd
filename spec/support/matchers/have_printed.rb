RSpec::Matchers.define :have_printed do |text|
  match do |string|
    string.split(/\n/).detect { |line|
      line =~ /#{Regexp.escape(text)}/
    } != nil
  end

  failure_message do |string|
    "Didn't find '#{text}' in:\n#{string}"
  end
end

