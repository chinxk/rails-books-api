# frozen_string_literal: true

# Users API Controller
module Api
  module V1
    class UsersController < ApplicationController

      before_action :authenticate!

      def avatar
        Rails.logger.debug(params)
        openid = params[:openid]
        user = User.find_by(openid: openid)
        if user.present?
          if user.update(user_params)
            json = {status: 0, message: "update user #{user.nick_name} successfully"}
          else
            json = {status: -1, message: "update user #{user.nick_name} failed"}
          end
        else
          json = { status: -1, message: 'user not found'}
        end
        render json: json
      end

      def stock
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

      def remove
        openid = params[:openid]
        user = User.find_by(openid: openid)
        Rails.logger.debug(params)
        Rails.logger.debug(user.id)
        if user.present?
          i = 0
          params[:book_ids]&.each do |book_id|
            i+=1
            ub = UserBook.find_by(user_id:user.id, book_id: book_id)
            unless ub.nil? || ub.destroy
              json = {status: -1, message: "remove book from #{user.nick_name} failed"}
              render json: json
            end
          end
          json = {status: 0, message: "remove #{i} books from #{user.nick_name} successfully"}
        else
          json = { status: -1, message: 'user not found'}
        end
        render json: json
      end

      def read
        openid = params[:openid]
        user = User.find_by(openid: openid)
        if user.present?
          i = 0
          params[:book_ids]&.each do |book_id|
            i+=1
            ub = UserBook.find_by(user_id:user.id, book_id: book_id)
            unless ub.nil? || ub.update_column(:read_date, Date.today)
              json = {status: -1, message: "mark #{ub.book.title} as readed for #{user.nick_name || user.id} failed"}
              render json: json
            end
          end
          json = {status: 0, message: "mark #{i} books as readed for #{user.nick_name || user.id} successfully"}
        else
          json = { status: -1, message: 'user not found'}
        end
        render json: json
      end

      def unread
        openid = params[:openid]
        user = User.find_by(openid: openid)
        if user.present?
          i = 0
          params[:book_ids]&.each do |book_id|
            i+=1
            ub = UserBook.find_by(user_id:user.id, book_id: book_id)
            unless ub.nil? || ub.update_column(:read_date, nil)
              json = {status: -1, message: "mark #{ub.book.title} as unreaded for #{user.nick_name || user.id} failed"}
              render json: json
            end
          end
          json = {status: 0, message: "mark #{i} books as unreaded for #{user.nick_name || user.id} successfully"}
        else
          json = { status: -1, message: 'user not found'}
        end
        render json: json
      end

      private
      
      def user_params
        params.require(:user).permit(
          :nick_name, :avatar_url
        )
      end
    end
  end
end
