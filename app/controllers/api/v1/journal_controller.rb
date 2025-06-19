class Api::V1::JournalController < ApplicationController
	skip_before_action :verify_authenticity_token
  # GET /api/v1/Journal
  def index
  	journal_entries = JournalEntries.all.order(entry_date: :desc)
    render json: journal_entries
  end

  # GET /api/v1/Journal/:id
  def show
    journal_entries = JournalEntries.find_by(id: params[:id])
    if journal_entries
      render json: journal_entries
    else
      render json: { error: "Journal not found" }, status: :not_found
    end
  end

#   # POST /api/v1/Journal/
  def create
    journal = JournalEntries.new(journal_params)
    if journal.save
      render json: journal, status: :created
    else
      #render json: journal.errors, status: :unprocessable_entity
      render json: { error: "error" }, status: :unprocessable_entity
    end
  end

  private

  def journal_params
    params.permit(:entry_date, :debit_subject ,:debit_amount ,:credit_subject ,:credit_amount)
  end
end


					