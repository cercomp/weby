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
end
