Rails.application.routes.draw do
  get 'home/new'
  post 'home/create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get 'home/new_with_invalid_transaction' => 'home#new_with_invalid_transaction'
  post 'home/create_with_invalid_transaction' => 'home#create_with_invalid_transaction'

  get 'home/new_with_valid_transaction' => 'home#new_with_valid_transaction'
  post 'home/create_with_valid_transaction' => 'home#create_with_valid_transaction'

  get 'home/new_with_nest_transaction' => 'home#new_with_nest_transaction'
  post 'home/create_with_nest_transaction' => 'home#create_with_nest_transaction'

  get 'home/new_with_new_transaction' => 'home#new_with_new_transaction'
  post 'home/create_with_new_transaction' => 'home#create_with_new_transaction'
end
