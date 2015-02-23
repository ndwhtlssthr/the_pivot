class UsersController < ApplicationController
  def new
    if request.original_url != login_for_cart_url && request.original_url != new_user_url
      session[:return_to] ||= request.referer
    end
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:success] = "Please check your email to activate your account!"
      redirect_to root_url
    else
      flash[:errors] = @user.errors.full_messages.uniq.join("<br>")
      redirect_to :back
    end
  end

  def show
    @user = User.find_by(slug: params[:slug])
    @items = Item.active.available.where.not(id: session[:cart]).where(user_id: @user.id)
    @user_events = @user.group_events
  end

  private

  def user_params
    params.require(:user).permit(
      :full_name,
      :display_name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
