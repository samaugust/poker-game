class ApplicationController < ActionController::Base
  require Rails.root.join('lib', 'assets', 'hand_calculator').to_s
  protect_from_forgery with: :exception
end
