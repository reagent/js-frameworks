RSpec::Matchers.define :have_response_body do |expected|
  def body_for(content)
    JSON.generate(content)
  end

  match do |actual|
    actual.body.should == body_for(expected)
  end

  failure_message_for_should do |actual|
    "expected response body to == '#{body_for(expected)}', was '#{actual.body}'"
  end
end

RSpec::Matchers.define :have_content_type do |expected_content_type|
  def content_type_for(response)
    actual.headers['Content-Type']
  end

  match do |actual|
    content_type = content_type_for(actual)

    if expected_content_type == 'application/json'
      content_type.should == expected_content_type
    else
      # Handle text/html;charset=utf-8
      content_type.should =~ /#{expected_content_type}/
    end
  end

  failure_message_for_should do |actual|
    "expected response to have content type of '#{expected_content_type}', was '#{content_type_for(actual)}'"
  end

  failure_message_for_should_not do |actual|
    "expected response to not have content type of '#{expected_content_type}'"
  end
end

RSpec::Matchers.define :have_status do |status_name|
  def status_codes
    {
      :ok                   => 200,
      :created              => 201,
      :not_modified         => 304,
      :unauthorized         => 401,
      :forbidden            => 403,
      :not_found            => 404,
      :not_acceptable       => 406,
      :unprocessable_entity => 422
    }
  end

  def status_for_code(code)
    status_codes.invert[code] || 'unknown'
  end

  def status_code_not_found(status_name)
    raise("status code for :#{status_name} not found")
  end

  match do |actual|
    status_code = status_codes[status_name.to_sym] || status_code_not_found(status_name)
    actual.status.should == status_code
  end

  failure_message_for_should do |actual|
    "expected status of :#{status_name}, was :#{status_for_code(actual.status)}"
  end

  failure_message_for_should_not do |actual|
    "expected status to not be :#{status_name}"
  end
end

RSpec::Matchers.define :have_api_status do |status_name|
  def expected_content_type
    'application/json'
  end

  match do |actual|
    actual.body.should == @body unless @body.nil?

    actual.should have_content_type(expected_content_type)
    actual.should have_status(status_name)
  end

  chain :and_have_no_body do
    @body = ''
  end

  chain :and_response_body do |expected_hash|
    @body = JSON.generate(expected_hash)
  end

  failure_message_for_should do |actual|
    message = "expected response to have status of :#{status_name}, content-type of: '#{expected_content_type}'"

    if @body
      if @body.length > 0
        message << " and body of '#{@body}'"
      else
        message << " and no body"
      end
    end

    message << ", but did not."

    message
  end
end