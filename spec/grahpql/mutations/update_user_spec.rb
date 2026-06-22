require "rails_helper"

RSpec.describe "UpdateUser Mutation" do

  let(:mutation) do
    ->(id:, first_name: nil, last_name: nil, email: nil) {
      attrs = { firstName: first_name, lastName: last_name, email: email }
        .compact
        .map { |k, v| "#{k}: \"#{v}\"" }
        .join("\n")

      <<~GQL
        mutation {
          updateUser(input: {
            id: "#{id}"
            #{attrs}
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

  def execute_mutation(**args)
    GraphqlPlaygroundSchema.execute(mutation.call(**args)).to_h
  end

  context "when user exists" do
    let!(:user) { User.create!(first_name: "Nitin", last_name: "-", email: "nitin@pasricha.com") }

    context "when update is successful" do
      it "returns the updated user" do
        result = execute_mutation(id: user.id, last_name: "Pasricha")

        expect(result["data"]["updateUser"]["user"]).to include(
          "id" => user.id.to_s,
          "fullName" => "Nitin Pasricha",
          "email" => "nitin@pasricha.com"
        )
      end
    end

    context "when no attributes are provided" do
      it "returns an error" do
        result = execute_mutation(id: user.id)

        expect(result["errors"]).to be_present
        expect(result["errors"][0]["message"]).to eq("No attributes to update")
      end
    end

    context "when email is already taken" do
      let!(:_) { User.create!(first_name: "Jaymin", last_name: "Shah", email: "jaymin@shah.com") }

      it "returns a validation error" do
        result = execute_mutation(id: user.id, email: "jaymin@shah.com")

        expect(result["errors"]).to be_present
        expect(result["errors"][0]["message"]).to eq("Email has already been taken")
      end
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
