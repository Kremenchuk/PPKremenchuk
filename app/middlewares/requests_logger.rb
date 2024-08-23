class RequestsLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    app_request = create_app_request(env)

    status, headers, response = @app.call(env)

    app_request.update!(
      response_status: status,
      response_headers: headers,
      response_info: response
    )

    [status, headers, response]
  end

  private

  def create_app_request(env)
    AppRequest.create!(
      request_url: env['REQUEST_PATH'],
      request_type: env['REQUEST_METHOD'],
      request_params: ''
    )
  end

end