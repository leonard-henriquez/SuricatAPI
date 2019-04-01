module V1
  # User controller
  class UsersController < ApplicationController
    include RenderJson

    before_action :set_user, only: [:show, :update, :destroy]

    # GET /users
    def index
      @users = User.all
      render_json @users
    end

    # POST /users
    def create
      @user = User.create!(user_params)
      render_json @user,
                    status: :created
    end

    # GET /users/:id
    def show
      render_json @user
    end

    # PUT /users/:id
    def update
      @user.update(user_params)
      head :no_content
    end

    # DELETE /users/:id
    def destroy
      @user.destroy
      head :no_content
    end

    private

    def user_params
      # whitelist params
      params.permit(:title, :created_by)
    end

    def set_user
      @user = User.find(params[:id])
    end
  end
end
