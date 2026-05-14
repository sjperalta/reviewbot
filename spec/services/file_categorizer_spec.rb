require "spec_helper"

RSpec.describe Reviewbot::Services::FileCategorizer do
  subject(:categorizer) { described_class.new }

  describe "#determine_category" do
    it "categorizes .rb files as source" do
      expect(categorizer.determine_category("app/models/user.rb")).to eq("source")
    end

    it "categorizes _spec.rb files as test" do
      expect(categorizer.determine_category("spec/models/user_spec.rb")).to eq("test")
    end

    it "categorizes .png files as binary" do
      expect(categorizer.determine_category("assets/logo.png")).to eq("binary")
    end

    it "categorizes Gemfile.lock as lockfile" do
      expect(categorizer.determine_category("Gemfile.lock")).to eq("lockfile")
    end

    it "categorizes vendor files" do
      expect(categorizer.determine_category("vendor/bundle/foo.rb")).to eq("vendor")
    end

    it "categorizes config files" do
      expect(categorizer.determine_category(".github/workflows/test.yml")).to eq("config")
    end

    it "categorizes snapshot files" do
      expect(categorizer.determine_category("__snapshots__/test.snap")).to eq("snapshot")
    end
  end
end
