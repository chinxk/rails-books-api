# frozen_string_literal: true

# Books API Controller
require 'rest-client'
module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate!, except: :init

      def init
        # if no openid, try to get it via code
        openid = params[:openid] || get_open_id
        if openid.nil?
          render json: { status: 'error', error: 'no openid!' }
        else
          # get/create user via openid
          user = User.find_by(openid:)
          if user.nil?
            user = User.new(openid:)
            user.save
          end
          token = Token.encode(user:)
          my_books = []
          user&.user_books&.each do |ub|
            my_books.push({ book: ub.book, read_date: ub.read_date, readed: ub.read_date? })
          end
          render json: { status: 'ok', error: '', user:,
                         token:, my_books: }
        end
      end

      def index
        Rails.logger.debug('-----Start to get all books')
        render json: Book.all
      end

      def create
        Rails.logger.debug('-----Start to create book')
        Rails.logger.debug(book_params)
        book = Book.new(book_params)
        if book.save
          render json: { book:, status: 'ok' }
        else
          render json: { status: 'error', error: book.errors }
        end
      end

      def by_isbn
        isbn = params[:isbn]
        Rails.logger.debug("-----Start to search book by isbn: #{isbn}")
        # fetch local
        book = Book.find_by(isbn:)
        if book.present?
          Rails.logger.debug("-----found book in local db, isbn: #{isbn}")
          render json: { book:, status: 'ok' }
        else
          # fetch remote
          Rails.logger.debug("-----fetch book from remote, isbn: #{isbn}")
          options = {
            method: :get,
            url: ENV['JD_ISBN_API_PATH'].gsub('{isbn}', isbn)
          }
          begin
            res = JSON.parse(RestClient::Request.execute(options))
            if res['code'] == '10000' && (res['result']['showapi_res_body']['ret_code']).zero?
              Rails.logger.debug("-----found book from remote, isbn: #{isbn}, try to save it.")
              new_book = res['result']['showapi_res_body']['data']
              new_book = Book.new(new_book)
              render json: { book: new_book, status: 'ok', error: nil } if new_book.save
            else
              Rails.logger.error("-----get error from remote, isbn: #{isbn}")
              # TODO: handle error from remote
              Rails.logger.error(res)
              render json: { status: 'error', error: res }
            end
          rescue RestClient::ExceptionWithResponse => e
            Rails.logger.error('ExceptionWIthResponse')
            Rails.logger.error(e)
            render json: { status: 'error', error: e }
          rescue SocketError => e
            Rails.logger.error('ExceptionWIthResponse')
            Rails.logger.error(e)
            render json: { status: 'error', error: e }
          rescue StandardError => e
            Rails.logger.error('StandardError')
            Rails.logger.error(e)
            render json: { status: 'error', error: e }
          end
        end
      end

      private

      def book_params
        params.require(:book).permit(
          :produce, :binding, :page, :author, :paper,
          :gist, :edition, :title, :price, :isbn, :pubdate,
          :img, :format, :publisher
        )
      end

      def get_open_id
        return unless params[:code]

        code = params[:code]
        options = {
          method: :get,
          url: ENV['WX_J2A_API_PATH'],
          headers: {
            params: {
              appid: ENV['WX_APPID'],
              secret: ENV['WX_SECRET'],
              js_code: code,
              grant_type: ENV['WX_GRANT_TYPE']
            }
          }
        }
        begin
          res = JSON.parse(RestClient::Request.execute(options))
          openid = res['openid']
        rescue StandardError => e
          Rails.logger.error('StandardError')
          Rails.logger.error(e)
        end
      end
    end
  end
end
