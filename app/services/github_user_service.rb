require "net/http"
require "json"

class GithubUserService
  UserNotFoundError = Class.new(StandardError)

  GITHUB_API_URL = "https://api.github.com/users"

  def initialize(username)
    @username = username
  end

  def call
    uri = URI("#{GITHUB_API_URL}/#{@username}")
    response = Net::HTTP.get_response(uri)

    raise UserNotFoundError, "GitHub user '#{@username}' not found" if response.code == "404"

    data = JSON.parse(response.body, symbolize_names: true)

    {
      login:        data[:login],
      name:         data[:name],
      avatar_url:   data[:avatar_url],
      public_repos: data[:public_repos]
    }
  end
end
