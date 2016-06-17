require_dependency 'repositories_helper'
require_dependency 'redmine/scm/adapters/git_adapter'

module RepositoriesHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :format_revision, :git_branch
    end
  end

  module InstanceMethods
    def format_revision_with_git_branch(revision)
      repository = revision.repository
      if params[:action] == "revision" && repository.is_a?(Repository::Git)
        s = repository.class.format_changeset_identifier(revision)
        branch_name = repository.scm.name_rev(revision.revision)
        s += " (#{branch_name})" if branch_name.present?
      else
        format_revision_without_git_branch(revision)
      end
    end
  end
end

module GitAdapterPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def name_rev(id)
      branch_names = []
      cmd_args = ["branch", "--no-color", "--contains", id]
      git_cmd(cmd_args) do |io|
        branch_names = io.readlines.map{|line| line.gsub("*", "").strip}
      end
      branch_names.include?("master") ? "master" : branch_names.first
    rescue ScmCommandAborted
      nil
    end
  end
end
