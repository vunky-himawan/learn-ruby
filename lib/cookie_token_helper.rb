module CookieTokenHelper
  def set_refresh_token_cookie(token, cookies)
    cookie_store = Rails.env.production? ? cookies.encrypted : cookies
    cookie_store[:refresh_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict,
      expires: 30.days.from_now
    }
  end
end
