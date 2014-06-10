class Admin::BaseController < ApplicationController
  before_action :require_user
  before_action :is_admin
end
