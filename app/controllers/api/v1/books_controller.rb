# frozen_string_literal: true

# Books API Controller
require 'rest-client'
module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate!, except: :token

      def token
        render json: {
          token: Token.encode(aaaa: 'aaaa')
        }
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
            # url: "https://way.jd.com/showapi/isbn?isbn=#{isbn}&appkey=#{appkey}"
            url: ENV['JD_ISBN_API_PATH'].gsub('{isbn}', isbn)
          }
          begin
            res = JSON.parse(RestClient::Request.execute(options))
            if res['code'] == '10000' && (res['result']['showapi_res_body']['ret_code']).zero?
              Rails.logger.debug("-----found book from remote, isbn: #{isbn}, try to save it.")
              new_book = res['result']['showapi_res_body']['data']
              render json: { data: new_book, status: 'ok', error: nil } if Book.new(new_book).save
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
    end
  end
end
