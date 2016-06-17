require 'redmine_git_revision_info'

Rails.configuration.to_prepare do
  RedmineGitRevisionInfo.apply_patch
end

Redmine::Plugin.register :git_revision_info do
  name 'Git Revision Information plugin'
  author 'Yuki Yoshinoya'
  description 'Display git information from git revision id in repository page.'
  version '0.0.2'
  url 'https://github.com/y-yoshinoya/redmine_git_revision_info'
  author_url 'https://github.com/y-yoshinoya'
end
