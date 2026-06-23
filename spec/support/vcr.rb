require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'     # dir where cassette files are stored
  config.hook_into :webmock                         # webmock intercepts HTTP
  config.configure_rspec_metadata!                  # enables :vcr tag in RSpec

  config.ignore_localhost = true                    # don't record localhost calls
  config.default_cassette_options = {
    record: :new_episodes                           # record mode(here set as new_epsiodes)
  }

  config.filter_sensitive_data('<API_KEY>') {ENV['MY_API_KEY']}
end



# Mode                  Behavior
# :once             Records once, then always replays. Errors if cassette missing.
# :new_episodes     Replays existing, records new requests
# :none             Never records — fails if no cassette match
# :all              Always re-records (ignores existing cassette)