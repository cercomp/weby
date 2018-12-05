require 'spec'
require 'spec/rake/spectask'
desc "Run all specs"
task :spec => ['spec:dirge', 'spec:load_path_find', 'spec:callsite']
namespace(:spec) do
  Spec::Rake::SpecTask.new(:dirge) do |t|
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << '-r./lib/dirge'
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['spec/**/dirge_spec.rb']
  end

  Spec::Rake::SpecTask.new(:load_path_find) do |t|
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << '-r./lib/load_path_find'
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['spec/**/load_path_find_spec.rb']
  end

  Spec::Rake::SpecTask.new(:callsite) do |t|
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << '-r./lib/load_path_find'
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['spec/**/callsite_spec.rb']
  end

end

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec