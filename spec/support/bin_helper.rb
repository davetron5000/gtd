require "open3"
require "pathname"
RSpec.shared_context "running the app" do
  after do
    if Dir.exists?(test_gtd_path)
      FileUtils.rm_r test_gtd_path
    end
  end
end
module BinHelper
  def gtd(command_string)
    binary = (Pathname(__FILE__).dirname / ".." / ".." / "bin" / "gtd").expand_path
    command = "#{binary} --root #{test_gtd_path} --no-color #{command_string}"
    stdout,stderr,status = Open3.capture3({ "GLI_DEBUG" => "true" },command)
    unless status.success?
      raise "Problem running #{command}:\n#{stdout}\n#{stderr}"
    end
    stdout
  end

end
