require_dependency 'repositories_helper'
require_dependency 'changeset'
require_dependency 'repository/git'
require_dependency 'redmine/scm/adapters/git_adapter'

module RepositoriesHelperPatch
  def self.included(base)
    base.send(:include, RepositoriesHelperMethodsGitBranch)
    base.class_eval do
      alias_method_chain :format_revision, :git_branch
    end
  end
end

module RepositoriesHelperMethodsGitBranch
  def format_revision_with_git_branch(revision)
    if revision.respond_to? :format_identifier
      revision.format_identifier
      if params[:action] == "revision" && revision.repository.scm_name == "Git"
        revision.format_identifier_for_revision
      else
        revision.format_identifier
      end
    else
      revision.to_s
    end
  end
end

module ChangesetPatch
  def self.included(base)
    base.send(:include, ChangesetMethodsGitBranch)
  end
end

module ChangesetMethodsGitBranch
  def format_identifier_for_revision
    if repository.respond_to? :format_changeset_identifier_for_revision
      repository.format_changeset_identifier_for_revision self
    else
      identifier
    end
  end
end

module GitPatch
  def self.included(base)
    base.send(:include, GitMethodsGitBranch)
  end
end

module GitMethodsGitBranch
  def format_changeset_identifier_for_revision(changeset)
    begin
      branch_name = changeset.repository.scm.name_rev(changeset.revision)
      changeset.revision[0, 8] + " (#{branch_name})"
    rescue => e
      changeset.revision[0, 8]
    end
  end
end

module GitAdapterPatch
  def self.included(base)
    base.send(:include, GitAdapterMethodsGitBranch)
  end
end

module GitAdapterMethodsGitBranch
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
