class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid']).first 

    if (user)
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Signed in!"
    else
      info = {
        :provider => auth['provider'],
        :uid => auth['uid']
      }

      if auth['info']
         info[:name] = auth['info']['name'] || ""
         info[:email] = auth['info']['email'] || ""
      end

      session[:auth_info] = info
      redirect_to new_user_registration_path(:plan => 'member')
    end
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def new
    redirect_to '/auth/twitter'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
