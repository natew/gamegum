class SessionsController < ApplicationController
  def new
  end

  def create
    if request.post?
      self.current_user = User.authenticate(params[:login], params[:password])
      if logged_in? and !self.current_user.banned
        if params[:remember_me] == "1"
          current_user.remember_me unless current_user.remember_token?
          cookies[:auth_token] = {
            :value => self.current_user.remember_token,
            :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default('/')
        
        flash[:notice] = "Logged in!"
      elsif logged_in? and self.current_user.banned
        self.current_user.forget_me
        cookies.delete :auth_token
        reset_session
        redirect_back_or_default('/')
        flash[:notice] = "This account and IP address has been banned"
      else
        flash[:notice] = "Incorrect username or password"
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end
  
  def forgot
    if request.post?
      @user = User.find_by_login(params[:login])
      if !@user.nil? and @user.email === params[:email]
        UserMailer.reset_email(@user).deliver
        flash[:notice] = "Login information sent to #{@user.email}"
        render :action => 'new'
      else
        flash[:notice] = "Incorrect username or email address"
      end 
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
    reset_session
  end
end