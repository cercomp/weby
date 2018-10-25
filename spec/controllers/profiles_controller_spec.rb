require "rails_helper"

describe ProfilesController do
  let(:user) { FactoryGirl.create(:user) }

  it "GET #show"
  it "GET history"
  it "GET #edit"

  it "PUT #update" do
    sign_in user

    patch :update, id: user.login, user: { :login => "newlogin", :email => "email@updated.com" }

    expect(response).to redirect_to(profile_path('newlogin'))
    expect(flash[:success]).to eq ' Conta atualizada, um email foi enviado para confirmar o novo endereço de email'
  end
end
