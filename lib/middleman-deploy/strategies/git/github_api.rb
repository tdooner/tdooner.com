require 'github_api'

module Middleman
  module Deploy
    module Strategies
      module Git
        class GithubApi < Middleman::Deploy::Strategies::Git::Base
          def process
            Dir.chdir(self.build_dir) do
              initialize_git_repo
              checkout_branch
              commit_without_push
              create_github_trees
            end
          end

        private

          def github
            @github ||= Github.new(oauth_token: ENV['GITHUB_AUTH_TOKEN'])
          end

          def upload_blobs(files)
            files.each do |file|
              mode, type, sha, path = file
              next unless type == 'blob'

              puts 'uploading ' + path
              github.git_data.blobs.create({
                user: 'tdooner',
                repo: 'tdooner.com',
                content: Base64.encode64(File.read(path)),
                encoding: 'base64',
              })
            end
          end

          def create_tree(files)
            github.git_data.trees.create({
              user: 'tdooner',
              repo: 'tdooner.com',
              tree: files.map do |file|
                mode, type, sha, path = file

                {
                  type: type,
                  path: path,
                  sha: sha,
                  mode: mode,
                }
              end
            })
          end

          def create_github_trees
            files = `git ls-tree HEAD -rt`.each_line.map(&:split)

            upload_blobs(files)
            tree = create_tree(files)
            create_commit_and_update_branch(tree)
          end


          def create_commit_and_update_branch(tree)
            c = github.git_data.commits.create({
              user: 'tdooner',
              repo: 'tdooner.com',
              message: 'Deploy',
              tree: tree.sha,
              parents: [],
              name: 'Tom Dooner',
              email: 'tomdooner@gmail.com',
              date: Time.now.iso8601,
            })

            github.git_data.references.update({
              user: 'tdooner',
              repo: 'tdooner.com',
              ref: 'heads/gh-pages',
              sha: c.sha,
              force: true,
            })
          end

          def initialize_git_repo
            return if File.directory?('.git')

            run_or_fail('git init')
          end

          def commit_without_push
            run_or_fail('git add -A')
            run_or_fail("git commit --allow-empty -am \"Automated Commit\"")
          end

          def run_or_fail(command)
            system(command) || raise("ERROR running command #{command}")
          end

          # def parse_remote_url
          #   owner, repo = [nil, nil]
          #   uri = `git config --get remote.#{self.remote}.url`.chomp

          #   if uri.start_with?('git@')
          #     _, path = uri.split(':', 2)
          #     path = path.chomp('.git')

          #     owner, repo = path.split('/', 2)
          #   elsif uri.start_with?('http')
          #     path = URI(uri).path
          #     path = path[1..-1] # remove the leading slash

          #     owner, repo = path.split('/', 2)
          #   end

          #   [owner, repo]
          # end
        end
      end
    end
  end
end
