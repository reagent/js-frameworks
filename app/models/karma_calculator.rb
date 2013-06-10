class KarmaCalculator

  def initialize(user)
    @user = user
  end

  def points
    @user.new? ? 0 : points_from_database
  end

  private

  def points_from_database
    results.inject(0, &:+)
  end

  def results
    adapter.select("#{article_query} UNION #{comment_query}")
  end

  def adapter
    DataMapper.repository.adapter
  end

  def article_query
    "
      SELECT COUNT(votes.id)
      FROM   votes
      JOIN   articles ON articles.id = votes.target_id
      WHERE  votes.target_type = 'Article'
      AND    articles.user_id = #{@user.id}
    "
  end

  def comment_query
    "
      SELECT COUNT(votes.id)
      FROM   votes
      JOIN   comments ON comments.id = votes.target_id
      WHERE  votes.target_type = 'Comment'
      AND    comments.user_id = #{@user.id}
    "
  end
end
