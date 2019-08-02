Rails.application.routes.draw do
  resources :payments
  post 'webhook', to: 'payments#create'
end
