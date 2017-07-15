require "spec_helper"
require "fileutils"
require "pathname"
require "gtd/projects"

RSpec.describe Gtd::Projects do
  let(:project_root) { Pathname(Dir.mktmpdir) }
  before do
    FileUtils.mkdir_p project_root / "foo"
    FileUtils.mkdir_p project_root / "bar"
    FileUtils.mkdir_p project_root / "__archive__"
    FileUtils.mkdir_p project_root / "__archive__" / "baz"
  end

  subject(:projects) { described_class.new(project_root) }

  describe "#each" do
    it "vends each project not in the archive" do
      returned_projects = []
      projects.each do |project|
        returned_projects << project
      end

      expect(returned_projects.size).to eq(2)
      expect(returned_projects.map(&:name)).to include("foo")
      expect(returned_projects.map(&:name)).to include("bar")
    end
  end
  describe "#find" do
    it "locates an existing project" do
      project = projects.find(2)
      expect(project.name).to eq("foo")
    end
    it "returns nil for a non-exsitent project" do
      project = projects.find(100)
      expect(project).to eq(nil)
    end
  end
end
