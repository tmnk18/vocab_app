class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    @folders = current_user.folders
  end
end