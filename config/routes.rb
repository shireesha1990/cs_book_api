require "sidekiq/web" # require the web UI

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq
  resources :books
  resources :authors
end