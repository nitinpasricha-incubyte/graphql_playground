require 'rails_helper'

RSpec.describe GithubUserService do
  describe '#call' do
    context 'when the user exists on GitHub' do
      it 'returns user data', vcr: { cassette_name: 'github/user_found' } do
        result = GithubUserService.new('Nitin-Pasricha').call

        expect(result[:login]).to eq('Nitin-Pasricha')
        expect(result[:name]).to be_present
        expect(result[:avatar_url]).to be_present
        expect(result[:public_repos]).to be_a(Integer)
      end
    end

    context 'when the user does not exist on GitHub' do
      it 'raises UserNotFoundError', vcr: { cassette_name: 'github/user_not_found' } do
        expect {
          GithubUserService.new('this_username_does_not_exist_xyz_404').call
        }.to raise_error(GithubUserService::UserNotFoundError)
      end
    end
  end
end
