module CustomTokenErrorResponse
  def body
    {
      status_code: 401,
      message: "Username or password is incorrect",
      result: []
    }
  end
end
