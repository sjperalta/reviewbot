require "spec_helper"

RSpec.describe Reviewbot::Config::Loader do
  subject(:loader) { described_class.new }

  before do
    ENV["GITHUB_TOKEN"] = "test-token"
    ENV["DEEPSEEK_API_KEY"] = "test-key"
  end

  after do
    ENV.delete("GITHUB_TOKEN")
    ENV.delete("DEEPSEEK_API_KEY")
  end

  describe "#load!" do
    it "returns self" do
      expect(loader.load!).to eq(loader)
    end

    it "merges multiple .env files so the cwd file wins on duplicate keys" do
      Dir.mktmpdir do |tmpdir|
        path_home = File.join(tmpdir, "home.env")
        path_cwd = File.join(tmpdir, "cwd.env")
        File.write(path_home, "REVIEWBOT_MERGE_KEY=from_home\nREVIEWBOT_MERGE_ONLY_HOME=1")
        File.write(path_cwd, "REVIEWBOT_MERGE_KEY=from_cwd")

        allow(loader).to receive(:env_search_paths).and_return([path_cwd, path_home])
        loader.send(:load_env_file)

        expect(ENV["REVIEWBOT_MERGE_KEY"]).to eq("from_cwd")
        expect(ENV["REVIEWBOT_MERGE_ONLY_HOME"]).to eq("1")

        ENV.delete("REVIEWBOT_MERGE_KEY")
        ENV.delete("REVIEWBOT_MERGE_ONLY_HOME")
      end
    end
  end

  describe "#get" do
    it "returns environment variable value" do
      expect(loader.get("GITHUB_TOKEN")).to eq("test-token")
    end

    it "returns default when not set" do
      expect(loader.get("MISSING", default: "default")).to eq("default")
    end
  end

  describe "#validate!" do
    it "passes when required vars are set" do
      expect { loader.validate! }.not_to raise_error
    end

    it "raises when GITHUB_TOKEN is missing" do
      ENV.delete("GITHUB_TOKEN")
      expect { loader.validate! }.to raise_error(Reviewbot::Utils::ErrorHandler::ConfigError)
    end
  end

  describe "#deepseek_key_present?" do
    it "returns true when key is set" do
      expect(loader.deepseek_key_present?).to be true
    end

    it "returns false when key is not set" do
      ENV.delete("DEEPSEEK_API_KEY")
      expect(loader.deepseek_key_present?).to be false
    end
  end

  describe "#base_branch" do
    it "returns default when not configured" do
      expect(loader.base_branch).to eq("main")
    end
  end
end
