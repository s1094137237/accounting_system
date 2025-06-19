class Api::V1::AccountController < ApplicationController
  # GET /api/v1/account
  def index
  	account_subject = AccountSubject.all
    render json: account_subject
  end

  # GET /api/v1/Journal/:id
#   def show
#     journal_entries = AccountSubject.find_by(id: params[:id])
#     if journal_entries
#       render json: journal_entries
#     else
#       render json: { error: "Journal not found" }, status: :not_found
#     end
#   end
# 
# #   # POST /api/v1/Journals
#   def create
#     user = AccountSubject.new(user_params)
#     if AccountSubject.save
#       render json: user, status: :created
#     else
#       render json: user.errors, status: :unprocessable_entity
#     end
#   end
# 
#   private
# 
#   def user_params
#     params.require(:AccountSubject).permit(:entry_date, :debit_subject ,:debit_amount ,:credit_subject ,:credit_amount)
#   end
  
end