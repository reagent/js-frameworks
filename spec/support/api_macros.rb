module ApiMacros

  def requires_authentication_for(method, endpoint)
    instance_eval do
      it "requires authentication for a :#{method} to '#{endpoint}'" do
        send("api_#{method}", endpoint)

        last_response.should have_api_status(:unauthorized)
        last_response.should have_response_body({'errors' => ['Authentication is required']})
      end
    end
  end

  def requires_content_type_header_for(method, endpoint)
    instance_eval do
      it "requires the content type to be set for a :#{method} to '#{endpoint}'" do
        send(method, endpoint).should have_api_status(:not_acceptable).and_have_no_body
      end
    end
  end

end