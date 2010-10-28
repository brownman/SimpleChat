class UserController < ApplicationController
  before_filter :login_required, :only => :me
  # The resister form
  def register
    render "register"
  end

  # Save a new user
  def new
    #get the parameters
    name = params[:name]
    imgurl = params[:imgurl]
    if imgurl
      imgurl = (imgurl[0..6]=='http://' ? imgurl : 'http://'+imgurl)
    end
    password = params[:password]
    # create a user
    @user = User.new(:name => name, :password => password, :imgurl => imgurl)
    @user.encryptPassword
    # save it if there is no other user with the same name
    if name != '' and password != '' and @user.save
      session[:name]=name
      redirect_to "/chat/"
    else
      flash[:error] = "Sorry, a user with name " + name + " already exists."
      redirect_to :action => "register"
    end
  end
  
  # The join form
  def join
    if User.where(:name => session[:name]).first
      redirect_to "/chat/"
    else
      render "join"
    end
  end
  
  # clear the session
  def logout
    if session[:name]
      reset_session
    end
    redirect_to '/'
  end
  
  # Authenticate the user
  def authenticate
    @user = User.where(:name => params[:name]).first
    if @user and @user.authenticate(params[:name],params[:password])
      session[:name]=@user.name
      redirect_to "/chat/"
    else
      flash[:error] = "Try again"
      redirect_to '/'
    end
  end

  # Show the user
  def show
    @user = User.where(:name => params[:name]).first
    render "show"
  end

  # Show the loged in user
  def me
    @user = User.where(:name => session[:name]).first
    render "show"
  end
  
  private

  def login_required
    if not User.where(:name => session[:name]).first
      redirect_to "/"
    end
  end
  
end