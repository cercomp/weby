require "rails_helper"

RSpec.describe "User Registration", type: :request do
  describe "GET /signup" do
    it "renders the signup page with modern captcha and form fields" do
      get "/signup"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("weby-captcha-wrapper")
      expect(response.body).to include("weby-captcha-img")
      expect(response.body).to include("btn-refresh-captcha")
      expect(response.body).to include("toggle-password-btn")
    end
  end

  describe "POST /signup" do
    let(:valid_user_params) do
      {
        login: "specuser",
        email: "specuser@example.com",
        first_name: "Spec",
        last_name: "Tester",
        password: "Password1",
        password_confirmation: "Password1"
      }
    end

    it "rejects registration when captcha is invalid" do
      allow(SimpleCaptcha).to receive(:always_pass).and_return(false)
      get "/signup"
      key = SimpleCaptcha::SimpleCaptchaData.last.key

      post "/signup", params: {
        user: valid_user_params,
        captcha: "INVALID",
        captcha_key: key
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("O código digitado não confere com a imagem")
      expect(User.find_by(login: "specuser")).to be_nil
    end

    it "successfully registers user when captcha and attributes are valid" do
      get "/signup"
      key = SimpleCaptcha::SimpleCaptchaData.last.key
      val = SimpleCaptcha::SimpleCaptchaData.last.value

      post "/signup", params: {
        user: valid_user_params,
        captcha: val,
        captcha_key: key
      }

      expect(response).to have_http_status(:redirect)
      created_user = User.find_by(login: "specuser")
      expect(created_user).to be_present
      expect(created_user.email).to eq("specuser@example.com")
      created_user.destroy
    end
  end

  describe "GET /simple_captcha" do
    it "serves an image for a valid captcha code" do
      get "/signup"
      key = SimpleCaptcha::SimpleCaptchaData.last.key

      get "/simple_captcha", params: { code: key, time: Time.current.to_i }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("image/jpeg")
      expect(response.headers["Cache-Control"]).to include("no-cache")
      expect(response.body.bytesize).to be > 500
    end

    it "auto-heals and generates an image even if code does not exist in database" do
      get "/simple_captcha", params: { code: "nonexistent_code_12345" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("image/jpeg")
      expect(response.body.bytesize).to be > 500
      expect(SimpleCaptcha::Utils.simple_captcha_value("nonexistent_code_12345")).to be_present
    end

    it "serves javascript refresh code when requested with id" do
      get "/simple_captcha", params: { id: "simple_captcha-test_element" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/javascript")
      expect(response.body).to include("simple_captcha-test_element")
      expect(response.body).to include("/simple_captcha?code=")
    end
  end
end
