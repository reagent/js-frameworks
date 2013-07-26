require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Comments", :type => :integration do

  describe "fetching" do
    requires_content_type_header_for(:get, '/comments/1')

    it "returns a 404 when the comment can't be found" do
      api_get('/comments/1').should have_api_status(:not_found).and_have_no_body
    end

    it "returns the comment" do
      comment = Factory(:comment, :body => 'HI THERE.')

      Factory(:vote, :target => comment)

      api_get("/comments/#{comment.id}")

      last_response.should have_api_status(:ok)
      last_response.should have_response_body({
        :id            => comment.id,
        :body          => 'HI THERE.',
        :user_id       => comment.user_id,
        :username      => comment.user.username,
        :points        => 1,
        :comment_count => 0
      })
    end

  end

  context "for an Article" do
    describe "fetching" do
      requires_content_type_header_for(:get, '/articles/1/comments')

      it "returns a 404 when the article does not exist" do
        api_get('/articles/1/comments').should have_api_status(:not_found)
      end

      context "with an article" do
        let(:article)  { Factory(:article) }
        let(:endpoint) { "/articles/#{article.id}/comments" }

        it "returns an empty comment list when there are no comments" do
          api_get(endpoint).should have_api_status(:ok).and_response_body([])
        end

        it "returns comments for the article" do
          comment = Factory(:comment, :parent => article, :body => 'OMGHI2U!')

          api_get(endpoint)

          last_response.should have_api_status(:ok)
          last_response.should have_response_body([
            {
              :id            => comment.id,
              :body          => 'OMGHI2U!',
              :user_id       => comment.user_id,
              :username      => comment.user.username,
              :points        => 0,
              :comment_count => 0
            }
          ])
        end
      end
    end

    describe "creating" do
      let(:token)   { Factory(:token) }
      let(:headers) { {'HTTP_X_USER_TOKEN' => token.value} }

      requires_content_type_header_for(:post, '/articles/1/comments')
      requires_authentication_for(:post, '/articles/1/comments')

      it "returns 404 when the article does not exist" do
        token = Factory(:token)

        api_post('/articles/1/comments', {}, headers)
        last_response.should have_api_status(:not_found).and_have_no_body
      end

      it "creates a new comment for the article" do
        article = Factory(:article)

        expect do
          api_post("/articles/#{article.id}/comments", {:body => 'OMGHI2U'}, headers)
        end.to change { article.reload.comments.count }.from(0).to(1)

        last_comment = Comment.last

        last_response.should have_api_status(:created)
        last_response.should have_response_body({
          :id            => last_comment.id,
          :body          => 'OMGHI2U',
          :user_id       => last_comment.user_id,
          :username      => last_comment.user.username,
          :points        => 0,
          :comment_count => 0
        })

        last_comment.user.should == token.user
      end

      it "returns errors when creation fails" do
        article = Factory(:article)

        expect do
          api_post("/articles/#{article.id}/comments", {}, headers)
        end.to_not change { article.reload.comments.count }

        last_response.should have_api_status(:unprocessable_entity)
        last_response.should have_response_body({
          :errors => {
            :keyed => {:body => ['Body must not be blank']},
            :full  => ['Body must not be blank']
          }
        })
      end
    end
  end

  context "for a Comment" do
    describe "fetching" do
      requires_content_type_header_for(:get, '/comments/1/comments')

      it "returns a 404 when the comment does not exist" do
        api_get('/comments/1/comments').should have_api_status(:not_found)
      end

      context "with a comment" do
        let(:comment)  { Factory(:comment) }
        let(:endpoint) { "/comments/#{comment.id}/comments" }

        it "returns an empty comment list when there are no comments" do
          api_get(endpoint).should have_api_status(:ok).and_response_body([])
        end

        it "returns comments for the comment" do
          child = Factory(:comment, :parent => comment, :body => 'OMGHI2U!')

          api_get(endpoint)

          last_response.should have_api_status(:ok)
          last_response.should have_response_body([
            {
              :id            => child.id,
              :body          => 'OMGHI2U!',
              :user_id       => child.user_id,
              :username      => child.user.username,
              :points        => 0,
              :comment_count => 0
            }
          ])
        end
      end
    end

    describe "creating" do
      let(:token)   { Factory(:token) }
      let(:headers) { {'HTTP_X_USER_TOKEN' => token.value} }

      requires_content_type_header_for(:post, '/comments/1/comments')
      requires_authentication_for(:post, '/comments/1/comments')

      it "returns 404 when the comment does not exist" do
        token = Factory(:token)

        api_post('/comments/1/comments', {}, headers)
        last_response.should have_api_status(:not_found).and_have_no_body
      end

      it "creates a new reply for the comment" do
        comment = Factory(:comment)

        expect do
          api_post("/comments/#{comment.id}/comments", {:body => 'OMGHI2U'}, headers)
        end.to change { comment.reload.comments.count }.from(0).to(1)

        last_comment = Comment.last

        last_response.should have_api_status(:created)
        last_response.should have_response_body({
          :id            => last_comment.id,
          :body          => 'OMGHI2U',
          :user_id       => last_comment.user_id,
          :username      => last_comment.user.username,
          :points        => 0,
          :comment_count => 0
        })

        last_comment.user.should == token.user
      end

      it "returns errors when creation fails" do
        comment = Factory(:comment)

        expect do
          api_post("/comments/#{comment.id}/comments", {}, headers)
        end.to_not change { comment.reload.comments.count }

        last_response.should have_api_status(:unprocessable_entity)
        last_response.should have_response_body({
          :errors => {
            :keyed => {:body => ['Body must not be blank']},
            :full  => ['Body must not be blank']
          }
        })
      end
    end
  end

  describe "deleting" do
    let(:token)   { Factory(:token) }
    let(:headers) { {'HTTP_X_USER_TOKEN' => token.value} }

    requires_content_type_header_for(:delete, '/comments/1')
    requires_authentication_for(:delete, '/comments/1')

    it "returns a 404 if the comment does not exist" do
      api_delete('/comments/1', headers).should have_api_status(:not_found).and_have_no_body
    end

    it "does not allow deletion by someone other than the poster" do
      comment = Factory(:comment)
      api_delete("/comments/#{comment.id}", headers)

      last_response.should have_api_status(:forbidden)
      last_response.should have_response_body({:errors => ["You may not delete others' comments"]})
    end

    it "removes the comment's content" do
      comment = Factory(:comment, :body => 'SOMETHING', :user => token.user)

      expect do
        api_delete("/comments/#{comment.id}", headers)
      end.to change { comment.reload.body }.from('SOMETHING').to('[removed]')

      last_response.should have_api_status(:ok).and_have_no_body
    end
  end

  describe "fetching a User's posted comments" do
    requires_content_type_header_for(:get, '/users/1/comments')

    it "returns a 404 when the user does not exist" do
      api_get('/users/1/articles').should have_api_status(:not_found).and_have_no_body
    end

    it "returns the user's comments" do
      user_1 = Factory(:user)
      user_2 = Factory(:user)

      comment_1 = Factory(:comment, :user => user_1, :body => 'OMGHI2U!')
      comment_2 = Factory(:comment, :user => user_2)

      api_get("/users/#{user_1.id}/comments")

      last_response.should have_api_status(:ok)
      last_response.should have_response_body([
        {
          :id            => comment_1.id,
          :body          => 'OMGHI2U!',
          :user_id       => comment_1.user_id,
          :username      => comment_1.user.username,
          :points        => 0,
          :comment_count => 0
        }
      ])
    end
  end

  describe "fetching the current user's comments" do
    requires_content_type_header_for(:get, '/account/comments')
    requires_authentication_for(:get, '/account/comments')

    it "returns the list of comments" do
      token  = Factory(:token)

      user_1 = token.user
      user_2 = Factory(:user)

      comment_1 = Factory(:comment, :user => user_1, :body => 'OMGHI2U!')
      comment_2 = Factory(:comment, :user => user_2)

      api_get('/account/comments', {}, {'HTTP_X_USER_TOKEN' => token.value})

      last_response.should have_api_status(:ok)
      last_response.should have_response_body([
        {
          :id            => comment_1.id,
          :body          => 'OMGHI2U!',
          :user_id       => comment_1.user_id,
          :username      => comment_1.user.username,
          :points        => 0,
          :comment_count => 0
        }
      ])
    end
  end

end