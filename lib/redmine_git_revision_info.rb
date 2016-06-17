require_dependency 'repositories_helper'
require_dependency 'redmine/scm/adapters/git_adapter'

module RedmineGitRevisionInfo
  def self.apply_patch
    unless ::RepositoriesHelper.included_modules.include? RepositoriesHelperPatch
      ::RepositoriesHelper.send(:include, RepositoriesHelperPatch)
    end

    unless ::Redmine::Scm::Adapters::GitAdapter.included_modules.include? GitAdapterPatch
      ::Redmine::Scm::Adapters::GitAdapter.send(:include, GitAdapterPatch)
    end
  end

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
          branch_names = repository.scm.branch_contains(revision.revision)
          s += " (#{branch_names.join(', ')})" if branch_names.present?
          s
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
      def branch_contains(id)
        result = nil
        git_cmd(["branch", "--no-color", "--contains", id]) do |io|
          result = io.readlines.map{|line| line.gsub("*", "").strip}.reverse
        end
        result
      rescue ScmCommandAborted
        nil
      end
    end
  end
end
