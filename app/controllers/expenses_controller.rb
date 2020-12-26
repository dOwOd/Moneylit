require 'date'

class ExpensesController < ApplicationController
  skip_before_action :join_required, only: [:index]
  
  def index
    if params[:group_id] != nil
      session[:group_id] = params[:group_id]
    end

    if params[:select_date] == nil
      @search_date = Date.today
    elsif !params[:select_date].kind_of?(Date)
      @search_date = params[:select_date].to_date
    else
      @search_date = params[:select_date]
    end

    case params[:months]
    when 'prev'
      @search_date = @search_date.prev_month(1)
    when 'next'
      @search_date = @search_date.next_month(1)
    when 'home'
      @search_date = Date.today
    end
    @expenses = Expense.joins(:group_expenses).where(group_expenses:{group_id:current_group.id}).where(expenses:{paid_at:@search_date.in_time_zone.all_month}).order("expense DESC")
    @users = User.joins(:group_users).where(group_users: {group_id: current_group.id}).order("user_id ASC")
  end

  def show
    @expense = Expense.find(params[:id])
  end

  def new
    @expense = Expense.new
  end

  def edit
    @expense = Expense.find(params[:id])
  end

  def update
    expense = Expense.find(params[:id])
    
    if !expense.name.present?
      expense.name = "名称未設定"
    end 

    if !expense.expense.present?
      expense.expense =groups 0
    end

    if !expense.paid_at.present?
      expense.paid_at = Time.now
    end

    expense.update!(expense_params)
    redirect_to expenses_url, notice: "経費「#{expense.name}」を更新しました。"
  end

  def destroy
    expense = Expense.find(params[:id])
    expense.destroy
    redirect_to expenses_url, notice: "経費「#{expense.name}」を削除しました。"
  end

  def create
    @expense = Expense.new(expense_params)

    if !@expense.name.present?
      @expense.name = "名称未設定"
    end

    if @expense.expense == nil
      @expense.expense = 0
    end

    if @expense.paid_at == nil
      @expense.paid_at = Time.now
    end

    if @expense.save
      redirect_to expenses_url, notice: "経費「#{@expense.name}」を登録しました．"
    else
      render :new
    end
  end

  

  private

  def expense_params
    params.require(:expense).permit(:name, :expense, :paid_at, :description, :user_id,  group_ids: [] )
  end

  def group_params
    params.require(:group).permit(:id)
  end 

end
