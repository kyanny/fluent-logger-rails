class MessagesController < ApplicationController
  def index
    logger.debug   "This is going to the logger"
    logger.info    "This is going to the logger"
    logger.warn    "This is going to the logger"
    logger.error   "This is going to the logger"
    logger.unknown "This is going to the logger"
    render :text => "nothing"
  end

end
