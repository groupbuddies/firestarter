require "spec_helper"

RSpec.describe "ignite a new project with default configuration" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_firestarter
    setup_app_dependencies
  end

  it "passes the specs" do
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        expect(`rake`).to include("0 failures")
      end
    end
  end

  it "inherits the staging config from production" do
    staging_file = IO.read("#{project_path}/config/environments/staging.rb")
    config_stub = "Dummy::Application.configure do"
    expect(staging_file).to match(/^require_relative "production"/)
    expect(staging_file).to match(/#{config_stub}/), staging_file
  end

  it "creates .ruby-version from Suspenders .ruby-version" do
    ruby_version_file = IO.read("#{project_path}/.ruby-version")
    expect(ruby_version_file).to eq "#{RUBY_VERSION}\n"
  end

  it "downloads a .rubocop.yml" do
    rubocop_file = IO.read(File.join(project_path), ".rubocop.yml"))

    expect(rubocop_file).to match %r{Style/StringLiterals}
  end

  it "downloads a README.md" do
    readme_file = IO.read(File.join(project.path, "README.md"))

    expect(readme_file).not_to be_empty
  end
end
