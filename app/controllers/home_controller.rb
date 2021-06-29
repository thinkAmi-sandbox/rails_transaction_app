class HomeController < ApplicationController
  def new
    @post_path = home_create_path
  end

  def create
    fruit = Fruit.new(create_params)
    fruit.save!

    flash[:message] = '保存に成功しました'

    redirect_to home_new_path
  end

  def new_with_invalid_transaction
    @post_path = home_create_with_invalid_transaction_path
    render 'home/new'
  end

  def create_with_invalid_transaction
    if Fruit.save_with_invalid_transaction(create_params, 'invalid')
      flash[:message] = '保存に成功しました'
    else
      flash[:message] = '保存に失敗しました'
    end

    redirect_to home_new_with_invalid_transaction_path
  end

  def new_with_valid_transaction
    @post_path = home_create_with_valid_transaction_path
    render 'home/new'
  end

  def create_with_valid_transaction
    if Fruit.save_with_valid_transaction(create_params, 'valid')
      flash[:message] = '保存に成功しました'
    else
      flash[:message] = '保存に失敗しました'
    end

    redirect_to home_new_with_valid_transaction_path
  end

  def new_with_nest_transaction
    @post_path = home_create_with_nest_transaction_path
    render 'home/new'
  end

  def create_with_nest_transaction
    is_success = false
    ActiveRecord::Base.transaction do
      is_success = Fruit.save_with_valid_transaction(create_params, 'nest')
    end

    if is_success
      flash[:message] = '保存に成功しました'
    else
      flash[:message] = '保存に失敗しました'
    end

    redirect_to home_new_with_nest_transaction_path
  end

  def new_with_new_transaction
    @post_path = home_create_with_new_transaction_path
    render 'home/new'
  end

  def create_with_new_transaction
    is_success = false
    ActiveRecord::Base.transaction do
      is_success = Fruit.save_with_new_transaction(create_params, 'new')
    end

    if is_success
      flash[:message] = '保存に成功しました'
    else
      flash[:message] = '保存に失敗しました'
    end

    redirect_to home_new_with_new_transaction_path
  end

  private

  def create_params
    params.permit('name')
  end
end
