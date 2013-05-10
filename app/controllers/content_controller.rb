class ContentController < ApplicationController
  before_filter :authenticate_user!
  
  def member
    authorize! :view, :member, :message => 'Access limited to members.'
  end
  
end