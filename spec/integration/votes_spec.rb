require 'spec_helper'

describe "Voting", :type => :integration do

  context "on an Article" do
    let(:token)   { Factory(:token) }
    let(:headers) { {'HTTP_X_USER_TOKEN' => token.value} }

    requires_content_type_header_for(:post, '/articles/1/votes')
    requires_authentication_for(:post, '/articles/1/votes')

    it "returns a 404 when the article can't be found" do
      api_post('/articles/1/votes', {}, headers)
      last_response.should have_api_status(:not_found).and_have_no_body
    end

    it "creates a vote for the article" do
      article = Factory(:article)

      expect do
        api_post("/articles/#{article.id}/votes", {}, headers)
      end.to change { article.votes.count }.from(0).to(1)

      last_response.should have_api_status(:created)
      last_response.should have_response_body({'id' => Vote.last.id})
    end

    it "returns errors when creation fails" do
      article = Factory(:article)
      vote    = Factory(:vote, :target => article, :user => token.user)

      expect do
        api_post("/articles/#{article.id}/votes", {}, headers)
      end.to_not change { article.votes.count }

      last_response.should have_api_status(:bad_request)
      last_response.should have_response_body({'errors' => ["You've already voted for this item"]})
    end
  end

  context "on a Comment" do
    let(:token)   { Factory(:token) }
    let(:headers) { {'HTTP_X_USER_TOKEN' => token.value} }

    requires_content_type_header_for(:post, '/comments/1/votes')
    requires_authentication_for(:post, '/comments/1/votes')

    it "returns a 404 when the comment can't be found" do
      api_post('/comments/1/votes', {}, headers)
      last_response.should have_api_status(:not_found).and_have_no_body
    end

    it "creates a vote for the comment" do
      comment = Factory(:comment)

      expect do
        api_post("/comments/#{comment.id}/votes", {}, headers)
      end.to change { comment.votes.count }.from(0).to(1)

      last_response.should have_api_status(:created)
      last_response.should have_response_body({'id' => Vote.last.id})
    end

    it "returns errors when creation fails" do
      comment = Factory(:comment)
      vote    = Factory(:vote, :target => comment, :user => token.user)

      expect do
        api_post("/comments/#{comment.id}/votes", {}, headers)
      end.to_not change { comment.votes.count }

      last_response.should have_api_status(:bad_request)
      last_response.should have_response_body({'errors' => ["You've already voted for this item"]})
    end
  end

end