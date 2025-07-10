module TokenHelper
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

  def read_refresh_token(cookies)
    cookie_store = Rails.env.production? ? cookies.encrypted : cookies
    cookie_store[:refresh_token]
  end

  def delete_refresh_token_cookie(cookies)
    cookie_store = Rails.env.production? ? cookies.encrypted : cookies
    cookie_store.delete(:refresh_token)
  end

  def create_token(user_id, application_id, scopes: "public", expires_in: 2.hours)
    Doorkeeper::AccessToken.create!(
      application_id: application_id,
      resource_owner_id: user_id,
      expires_in: expires_in,
      scopes: scopes,
      use_refresh_token: true
    )
  end
end
