require 'core_ext/kernel/silence'

module GemRelease
  class VersionFile
    include GemRelease::Helpers

    def initialize(options = {})
      @path = gem_name
      @old_version = options.fetch(:old_version) do
        @has_data = false
      end
      @file_path = find_file
      validate_file_data
    end

    def has_data?
      @has_data
    end

    def git_diff
      @git_diff = `git diff #{old_version} -- #{file_path}`
    end

    def commit_list
      @commit_list = `git log --oneline #{old_version}..HEAD`
    end

    protected

    def existing_tags
      @existing_tags ||= `git tag`.split("\n").map(&:chomp)
    end

    def validate_data
      return unless has_data?
      return if existing_tags.find { |t| t == @old_verision } && File.exist?(@file_path)
      @has_data = false
    end

    def find_file
      path = gem_name
      path = path.gsub('-', '/') unless File.exist?(path_to_changelog_file(path))
      path = path.gsub('/', '_') unless File.exist?(path_to_changelog_file(path))
      File.expand_path(path_to_changelog_file(path))
    end

    def path_to_changelog_file(path)
      "lib/#{path}/CHANGELOG.md"
    end
  end
end
