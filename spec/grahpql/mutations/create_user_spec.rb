require "rails_helper"

RSpec.describe "CreateUser mutation" do

  let(:mutation) do
    ->(first_name:, last_name:, email:) {
      <<~GQL
        mutation {
          createUser(input: {
            firstName: "#{first_name}"
            lastName: "#{last_name}"
            email: "#{email}"
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

  def execute_mutation(first_name: "Nitin", last_name: "Pasricha", email: "nitin@pasricha.com")
    GraphqlPlaygroundSchema.execute(mutation.call(first_name:, last_name:, email:)).to_h
  end

  context "when input is valid" do
    it "creates a user" do
      expect { execute_mutation }.to change(User, :count).by(1)
    end

    it "returns the created user" do
      result = execute_mutation

      expect(result["data"]["createUser"]["user"]).to include(
        "fullName" => "Nitin Pasricha",
        "email" => "nitin@pasricha.com"
      )
    end
  end

  context "when a required field is missing" do
    it "returns a validation error" do
      result = execute_mutation(email: "")

      expect(result["errors"]).to be_present
      expect(result["errors"][0]["message"]).to eq("Email can't be blank")
    end
  end

  context "when email is already taken" do
    let!(:_) { User.create!(first_name: "Nitin", last_name: "Pasricha", email: "nitin@pasricha.com") }

    it "returns a uniqueness error" do
      result = execute_mutation

      expect(result["errors"]).to be_present
      expect(result["errors"][0]["message"]).to eq("Email has already been taken")
    end
  end

end
