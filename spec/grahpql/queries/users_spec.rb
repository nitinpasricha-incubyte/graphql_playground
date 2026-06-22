require "rails_helper"

RSpec.describe "Users Query" do

  let(:query) do
    <<~GQL
      query {
        users {
          id
          fullName
          email
        }
      }
    GQL
  end

  def execute_query
    GraphqlPlaygroundSchema.execute(query).to_h
  end

  context "when there are no users" do
    it "returns an empty list" do
      result = execute_query

      expect(result["data"]["users"]).to eq([])
    end
  end

  context "when users exist" do
    let!(:user1) { User.create!(first_name: "Nitin", last_name: "Pasricha", email: "nitin@pasricha.com") }
    let!(:user2) { User.create!(first_name: "Jaymin", last_name: "Shah", email: "jaymin@shah.com") }

    it "returns all users" do
      result = execute_query

      expect(result["data"]["users"].length).to eq(2)
    end

    it "returns correct fields for each user" do
      result = execute_query

      expect(result["data"]["users"]).to include(
        { "id" => user1.id.to_s, "fullName" => "Nitin Pasricha", "email" => "nitin@pasricha.com" },
        { "id" => user2.id.to_s, "fullName" => "Jaymin Shah", "email" => "jaymin@shah.com" }
      )
    end
  end
end
