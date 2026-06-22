require "rails_helper"

RSpec.describe "User Query" do
  let(:query) do
    ->(id) {
      <<~GQL
        query {
          user(id: "#{id}") {
            id
            fullName
            email
          }
        }
      GQL
    }
  end

  def execute_query(id)
    GraphqlPlaygroundSchema.execute(query.call(id)).to_h
  end

  context "when user does not exist" do
    it "returns nil for data" do
      result = execute_query(0)

      expect(result["data"]["user"]).to be_nil
    end

    it "returns an error message" do
      result = execute_query(0)

      expect(result["errors"][0]["message"]).to eq("User not found with id: 0")
    end
  end

  context "when user exists" do
    let!(:user) { User.create!(first_name: "Nitin", last_name: "Pasricha", email: "nitin@pasricha.com") }

    it "returns the user" do
      result = execute_query(user.id)

      expect(result["data"]["user"]).to eq(
        { "id" => user.id.to_s, "fullName" => "Nitin Pasricha", "email" => "nitin@pasricha.com" }
      )
    end
  end
end
