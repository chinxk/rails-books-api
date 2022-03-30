# frozen_string_literal: true

# Users API Controller
module Api
  module V1
    class UsersController < ApplicationController

      before_action :authenticate!

      def storage
        openid = params[:openid]
        user = User.find_by(openid: openid)
        if user.present?
          i = 0
          params[:book_ids]&.split(',')&.each do |book_id|
            i+=1
            user.books << Book.find(book_id)
          end
          if user.save
            json = {status: 0, message: "add #{i} books to #{user.nick_name} successfully"}
          else
            json = {status: -1, message: "add #{i} books to #{user.nick_name} failed"}
          end
        else
          json = { status: -1, message: 'user not found'}
        end
        render json: json
      end
    end
  end
end
