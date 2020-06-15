guard :rspec, cmd: "bundle exec rspec" do
  watch('Gemfile')
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { "spec/ampel_spec.rb" }
  watch('spec_helper.rb') { "spec" }
end
