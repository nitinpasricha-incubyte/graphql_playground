require "rails_helper"

RSpec.describe "DeleteUser Mutation" do
  let(:mutation) do
    ->(id:) {
      <<~GQL
        mutation {
          deleteUser(input: {
            id: "#{id}"
          }) {
            user {
              id
              fullName
              email
            }
          }
        }
      GQL
    }
  end

  def execute_mutation(id:)
    GraphqlPlaygroundSchema.execute(mutation.call(id:)).to_h
  end

  context "when user exists" do
    let!(:user) { User.create!(first_name: "Nitin", last_name: "Pasricha", email: "nitin@pasricha.com") }

    it "deletes the user" do
      expect { execute_mutation(id: user.id) }.to change(User, :count).by(-1)
    end

    it "returns the deleted user" do
      result = execute_mutation(id: user.id)

      expect(result["data"]["deleteUser"]["user"]).to include(
        "id" => user.id.to_s,
        "fullName" => "Nitin Pasricha",
        "email" => "nitin@pasricha.com"
      )
    end
  end

  context "when user does not exist" do
    it "returns an error" do
      result = execute_mutation(id: 0)

      expect(result["errors"]).to be_present
      expect(result["errors"][0]["message"]).to eq("User not found with id: 0")
    end
  end
end
