require File.expand_path("../../../../base", __FILE__)

require Vagrant.source_root.join("plugins/kernel_v2/config/vm_trigger")

describe VagrantPlugins::Kernel_V2::VagrantConfigTrigger do
  include_context "unit"

  let(:command) { :up }

  subject { described_class.new(command) }

  let(:machine) { double("machine") }

  def assert_invalid
    errors = subject.validate(machine)
    if !errors.empty? { |v| !v.empty? }
      raise "No errors: #{errors.inspect}"
    end
  end

  def assert_valid
    errors = subject.validate(machine)
    if !errors.empty? { |v| v.empty? }
      raise "Errors: #{errors.inspect}"
    end
  end

  before do
    env = double("env")
    allow(env).to receive(:root_path).and_return(nil)
    allow(machine).to receive(:env).and_return(env)
    allow(machine).to receive(:provider_config).and_return(nil)
    allow(machine).to receive(:provider_options).and_return({})

    subject.name = "foo"
  end

  describe "with defaults" do
    it "is valid with test defaults" do
      subject.finalize!
      assert_valid
    end

    it "sets a command" do
      expect(subject.command).to eq(command)
    end
  end

  describe "defining a new config that needs to match internal restraints" do
    let(:cmd) { :destroy }
    let(:cfg) { described_class.new(cmd) }
    let(:arr_cfg) { described_class.new(cmd) }

    before do
      cfg.only_on = :guest
      cfg.ignore = "up"
      arr_cfg.only_on = [:guest, :other]
      arr_cfg.ignore = ["up", "destroy"]
    end

    it "ensures only_on is an array of strings" do
      cfg.finalize!
      arr_cfg.finalize!

      expect(cfg.only_on).to be_a(Array)
      expect(arr_cfg.only_on).to be_a(Array)

      cfg.only_on.each do |a|
        expect(a).to be_a(String)
      end

      arr_cfg.only_on.each do |a|
        expect(a).to be_a(String)
      end
    end

    it "ensures ignore is an array of symbols" do
      cfg.finalize!
      arr_cfg.finalize!

      expect(cfg.ignore).to be_a(Array)
      expect(arr_cfg.ignore).to be_a(Array)

      cfg.ignore.each do |a|
        expect(a).to be_a(Symbol)
      end

      arr_cfg.ignore.each do |a|
        expect(a).to be_a(Symbol)
      end
    end
  end

  describe "defining a basic trigger config" do
    let(:cmd) { :up }
    let(:cfg) { described_class.new(cmd) }

    before do
      cfg.info = "Hello there"
      cfg.warn = "Warning!!"
      cfg.on_error = :continue
      cfg.ignore = :up
      cfg.only_on = "guest"
    end

    it "sets the options" do
      cfg.finalize!
      expect(cfg.info).to eq("Hello there")
      expect(cfg.warn).to eq("Warning!!")
      expect(cfg.on_error).to eq(:continue)
      expect(cfg.ignore).to eq([:up])
      expect(cfg.only_on).to eq(["guest"])
    end
  end

end
