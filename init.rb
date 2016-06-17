require 'git_revision_info_patch'

Rails.configuration.to_prepare do
  unless RepositoriesHelper.included_modules.include? RepositoriesHelperPatch
    RepositoriesHelper.send(:include, RepositoriesHelperPatch)
  end

  unless Redmine::Scm::Adapters::GitAdapter.included_modules.include? GitAdapterPatch
    Redmine::Scm::Adapters::GitAdapter.send(:include, GitAdapterPatch)
  end
end

Redmine::Plugin.register :git_revision_info do
  name 'Git Revision Information plugin'
  author 'Yuki Yoshinoya'
  description 'Display git information from git revision id in repository page.'
  version '0.0.1'
  url 'https://github.com/y-yoshinoya/redmine_git_revision_info'
  author_url 'https://github.com/y-yoshinoya'
end
